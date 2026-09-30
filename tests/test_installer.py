#!/usr/bin/env python3
"""Closed contracts for the release-bound CLI acquisition bootstrap."""

from __future__ import annotations

import hashlib
import os
import platform
import shlex
import stat
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = ROOT / "static" / "install.sh"
SCRIPT = SCRIPT_PATH.read_text(encoding="utf-8")
CADDY = (ROOT / "Caddyfile").read_text(encoding="utf-8")


def check(condition: object, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def test_bootstrap_is_small_posix_and_self_describing() -> None:
    check(SCRIPT.startswith("#!/bin/sh\n\nset -eu\n"), "bootstrap is fail-fast POSIX shell")
    check(len(SCRIPT.splitlines()) <= 280, "bootstrap remains a small acquisition boundary")
    check(SCRIPT_PATH.stat().st_mode & stat.S_IXUSR, "published bootstrap is executable")
    syntax = subprocess.run(["sh", "-n", str(SCRIPT_PATH)], capture_output=True, text=True, check=False)
    check(syntax.returncode == 0, f"bootstrap passes sh -n: {syntax.stderr}")
    help_result = subprocess.run(["sh", str(SCRIPT_PATH), "--help"], capture_output=True, text=True, check=False)
    check(help_result.returncode == 0, "help needs no Docker or network")
    for contract in (
        "curl -fsSL https://install.shimpz.com | sh",
        "shimpz status",
        "shimpz start",
        "shimpz reset",
        "Linux amd64",
        "Apple Silicon macOS arm64",
    ):
        check(contract in help_result.stdout, f"help includes {contract}")
    version = subprocess.run(["sh", str(SCRIPT_PATH), "--version"], capture_output=True, text=True, check=False)
    check(version.returncode == 0 and version.stdout.strip() == "2.0.0", "version is exact")
    check(
        "/Applications/Docker.app/Contents/Resources/bin/docker" in SCRIPT,
        "bootstrap admits Docker Desktop's exact macOS executable",
    )


def test_bootstrap_has_one_closed_digest_verified_handoff() -> None:
    for contract in (
        'RELEASE_REPOSITORY="ghcr.io/theshimpz/shimpz-local-release"',
        'RELEASE_CHANNEL="stable"',
        'platform="linux/amd64"',
        'member="/cli/x86_64-unknown-linux-musl/shimpz"',
        'member="/cli/aarch64-apple-darwin/shimpz"',
        '[ "$(wc -l < "$release_metadata" | tr -d \' \')" -eq 10 ]',
        '[ "$(one_metadata_value schema)" = "local-v2" ]',
        '[ "$(file_hash "$candidate_cli")" = "$expected_hash" ]',
        '"$candidate_cli" install --release "$release_ref"',
    ):
        check(contract in SCRIPT, f"bootstrap preserves {contract}")
    check(SCRIPT.count('"$docker" pull') == 1, "bootstrap pulls only the atomic release")
    check("docker compose up" not in SCRIPT, "bootstrap does not own lifecycle or graph execution")
    check("--reset" not in SCRIPT, "bootstrap does not retain the retired reset option")
    check("eval " not in SCRIPT, "bootstrap never evaluates dynamically assembled shell")
    check(SCRIPT.count("curl -fsSL") == 1, "curl appears only in the usage example")


def test_bootstrap_hides_successful_docker_details_without_hiding_failures() -> None:
    for contract in (
        'pull --quiet --platform "$platform" "$selector" >/dev/null 2>&1 || fail',
        "image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' \"$selector\" 2>/dev/null",
        'create --platform "$platform" "$release_ref" "$member" 2>/dev/null)" || fail',
        'cp "$container_id:/release.env" "$release_metadata" >/dev/null 2>&1 || fail',
        'cp "$container_id:$member" "$candidate_cli" >/dev/null 2>&1 || fail',
        'rm "$container_id" >/dev/null 2>&1 || fail',
    ):
        check(contract in SCRIPT, f"bootstrap keeps successful Docker details private: {contract}")
    for action in (
        "verify access to ghcr.io and retry",
        "verify Docker storage and retry",
        "retry the installation",
    ):
        check(action in SCRIPT, f"bootstrap failure gives the next action: {action}")


def test_bootstrap_delegates_executable_activation_and_preserves_foreign_commands() -> None:
    for retired in ("shimpz.previous", "shimpz.candidate", "lifecycle_started", "activated=", 'mv "$'):
        check(retired not in SCRIPT, f"the native lifecycle alone activates the managed CLI: {retired}")
    for contract in (
        '"$candidate_cli" --version >/dev/null 2>&1 ||',
        "set TMPDIR to a private directory that allows execution and retry",
        '[ -f "$managed_cli" ] && [ ! -L "$managed_cli" ] && [ -x "$managed_cli" ] ||',
        "confirm_public_replace() {",
        "[ -r /dev/tty ] && [ -w /dev/tty ] || return 1",
        '[ "$answer" = "Yes" ]',
        "Preserved the existing command",
        'ln -s "$managed_cli" "$public_cli"',
    ):
        check(contract in SCRIPT, f"bootstrap preserves acquisition contract {contract}")
    check(
        SCRIPT.index('"$candidate_cli" install --release "$release_ref"')
        < SCRIPT.index('public_dir="$HOME/.local/bin"'),
        "the public command is linked only after the release-bound CLI completed its installation",
    )


DOCKER_SEARCH = (
    "for candidate in /usr/bin/docker /Applications/Docker.app/Contents/Resources/bin/docker "
    "/usr/local/bin/docker /opt/homebrew/bin/docker; do"
)
FAKE_DIGEST = "ab" * 32
FAKE_REF = f"ghcr.io/theshimpz/shimpz-local-release@sha256:{FAKE_DIGEST}"


def run_bootstrap(root: Path, cli_body: str, version_status: int = 0) -> tuple[subprocess.CompletedProcess[str], Path]:
    """Run the bootstrap against a fake Docker whose release carries a stub release-bound CLI."""
    home = root / "home"
    home.mkdir(exist_ok=True)
    cli = root / "release-cli"
    cli.write_text(
        "#!/bin/sh\n"
        f'[ "$1" = --version ] && exit {version_status}\n'
        f'printf \'%s\\n\' "$0" "$*" >> {shlex.quote(str(root / "calls"))}\n'
        f"{cli_body}"
    )
    digest = hashlib.sha256(cli.read_bytes()).hexdigest()
    metadata = root / "release.env"
    fields = (
        ("schema", "local-v2"),
        ("ordinal", "2"),
        ("umbrella_revision", "a" * 40),
        ("cli_revision", "b" * 40),
        ("cli_linux_amd64_sha256", digest),
        ("cli_macos_arm64_sha256", digest),
        ("admin", "admin"),
        ("team", "team"),
        ("brain", "brain"),
        ("egress", "egress"),
    )
    metadata.write_text("".join(f"{key}={value}\n" for key, value in fields))
    docker = root / "docker"
    docker.write_text(
        "#!/bin/sh\n"
        'case "$1" in\n'
        "  info|pull|rm|compose) exit 0 ;;\n"
        f"  image) printf '%s\\n' '{FAKE_REF}' ;;\n"
        f"  create) printf '%s\\n' {'c' * 64} ;;\n"
        f'  cp) case "$2" in *:/release.env) cp {shlex.quote(str(metadata))} "$3" ;;'
        f' *) cp {shlex.quote(str(cli))} "$3" ;; esac ;;\n'
        "  *) exit 1 ;;\n"
        "esac\n"
    )
    docker.chmod(0o755)
    script = root / "install.sh"
    check(SCRIPT.count(DOCKER_SEARCH) == 1, "the fixture replaces the complete Docker search list")
    script.write_text(SCRIPT.replace(DOCKER_SEARCH, f"for candidate in {shlex.quote(str(docker))}; do"))
    environment = {**os.environ, "HOME": str(home), "TMPDIR": str(root)}
    result = subprocess.run(["sh", str(script)], env=environment, capture_output=True, text=True, check=False)
    return result, home


def behavioral_host() -> bool:
    return (platform.system(), platform.machine()) in {("Linux", "x86_64"), ("Darwin", "arm64")}


def test_refused_native_admission_leaves_the_managed_cli_untouched() -> None:
    if not behavioral_host():
        return
    with tempfile.TemporaryDirectory() as raw:
        root = Path(raw)
        (root / "home" / ".shimpz" / "bin").mkdir(parents=True)
        managed = root / "home" / ".shimpz" / "bin" / "shimpz"
        managed.write_text("previous managed CLI\n")
        managed.chmod(0o700)
        result, home = run_bootstrap(
            root,
            'echo "another Shimpz lifecycle operation is already running" >&2\nexit 1\n',
        )
        check(result.returncode != 0, "a refused native install is reported as a failure")
        check("another Shimpz lifecycle operation is already running" in result.stderr, "the refusal stays visible")
        check(managed.read_text() == "previous managed CLI\n", "the previous managed CLI stays byte-identical")
        check(sorted(path.name for path in managed.parent.iterdir()) == ["shimpz"], "no activation residue remains")
        check(not (home / ".local" / "bin" / "shimpz").exists(), "no public command is linked after failure")


def test_bootstrap_runs_the_verified_cli_from_outside_the_space_and_links_its_installation() -> None:
    if not behavioral_host():
        return
    with tempfile.TemporaryDirectory() as raw:
        root = Path(raw)
        result, home = run_bootstrap(
            root,
            'mkdir -p "$HOME/.shimpz/bin"\ncp "$0" "$HOME/.shimpz/bin/shimpz"\nchmod 700 "$HOME/.shimpz/bin/shimpz"\n',
        )
        check(result.returncode == 0, f"bootstrap succeeds: {result.stderr}")
        calls = (root / "calls").read_text().splitlines()
        check(len(calls) == 2, "the release-bound CLI runs exactly once")
        executable, arguments = calls
        check(arguments == f"install --release {FAKE_REF}", "the CLI receives the exact verified release")
        check(not executable.startswith(str(home)), "the bootstrap never runs the CLI from inside the Space")
        public = home / ".local" / "bin" / "shimpz"
        check(public.readlink() == home / ".shimpz" / "bin" / "shimpz", "the public command links the CLI")


def test_bootstrap_stops_before_installing_when_the_verified_cli_cannot_run() -> None:
    if not behavioral_host():
        return
    with tempfile.TemporaryDirectory() as raw:
        root = Path(raw)
        managed = root / "home" / ".shimpz" / "bin" / "shimpz"
        managed.parent.mkdir(parents=True)
        managed.write_text("previous managed CLI\n")
        managed.chmod(0o700)
        result, home = run_bootstrap(root, "exit 0\n", version_status=126)
        check(result.returncode != 0, "an unrunnable release-bound CLI is reported as a failure")
        check("set TMPDIR to a private directory that allows execution" in result.stderr, "the next action is named")
        check(not (root / "calls").exists(), "the installation never starts")
        check(managed.read_text() == "previous managed CLI\n", "the previous managed CLI stays byte-identical")
        check(not os.path.lexists(home / ".local" / "bin" / "shimpz"), "no public command is linked")


def test_bootstrap_refuses_to_link_a_missing_managed_cli() -> None:
    if not behavioral_host():
        return
    with tempfile.TemporaryDirectory() as raw:
        result, home = run_bootstrap(Path(raw), "exit 0\n")
        check(result.returncode != 0, "a completed install without its managed CLI is not reported as success")
        check("did not install the managed command" in result.stderr, "the missing managed CLI is named")
        check(not os.path.lexists(home / ".local" / "bin" / "shimpz"), "no dangling public command is created")


def test_bootstrap_rejects_a_stale_docker_group_session() -> None:
    for contract in (
        "[ -S /var/run/docker.sock ]",
        "candidate_group=\"$(/usr/bin/stat -c '%G' /var/run/docker.sock)\"",
        'account_name="$(/usr/bin/id -un)"',
        'has_group "$candidate_group" $(/usr/bin/id -Gn "$account_name") || return 1',
        '! has_group "$candidate_group" $(/usr/bin/id -Gn)',
        "sign out and back in (or restart), confirm docker version works without sudo",
        '[ "$(/usr/bin/id -g)" != "$(/usr/bin/id -g "$(/usr/bin/id -un)")" ]',
        "not a switched group such as sg docker",
        '"$candidate_cli" install --release "$release_ref"',
    ):
        check(contract in SCRIPT, f"bootstrap rejects a stale Docker group session: {contract}")
    for retired in ("/usr/bin/sg", "run_command", "SHIMPZ_RUN_", "docker_group"):
        check(retired not in SCRIPT, f"bootstrap never switches groups for Docker or the Local CLI: {retired}")


def test_public_origin_serves_only_the_bootstrap_for_installer_host() -> None:
    check("host install.shimpz.com" in CADDY, "installer hostname has an exact matcher")
    check("path / /install.sh" in CADDY, "only root and canonical bootstrap path are served")
    check('header Content-Type "text/plain; charset=utf-8"' in CADDY, "bootstrap is plain text")
    check('header Cache-Control "no-store"' in CADDY, "bootstrap is never cached")
    check("@installer_missing host install.shimpz.com" in CADDY, "other installer paths are 404")


def main() -> None:
    tests = [value for name, value in sorted(globals().items()) if name.startswith("test_") and callable(value)]
    for test in tests:
        test()
    print(f"{len(tests)} CLI bootstrap contracts passed")


if __name__ == "__main__":
    main()
