#!/usr/bin/env python3
"""Closed contracts for the release-bound CLI acquisition bootstrap."""

from __future__ import annotations

import stat
import subprocess
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
        '"$managed_cli" install --release "$release_ref"',
    ):
        check(contract in SCRIPT, f"bootstrap preserves {contract}")
    check(SCRIPT.count('run_command "$docker" pull') == 1, "bootstrap pulls only the atomic release")
    check("docker compose up" not in SCRIPT, "bootstrap does not own lifecycle or graph execution")
    check("--reset" not in SCRIPT, "bootstrap does not retain the retired reset option")
    check("eval " not in SCRIPT, "bootstrap never evaluates dynamically assembled shell")
    check(SCRIPT.count("curl -fsSL") == 1, "curl appears only in the usage example")


def test_bootstrap_compensates_activation_and_refuses_foreign_commands() -> None:
    for contract in (
        'previous_cli="$managed_dir/shimpz.previous"',
        'mv "$managed_cli" "$previous_cli"',
        'mv "$candidate_target" "$managed_cli"',
        '[ ! -e "$previous_cli" ] || mv "$previous_cli" "$managed_cli"',
        'fail "an unowned public shimpz command already exists"',
        'ln -s "$managed_cli" "$public_cli"',
    ):
        check(contract in SCRIPT, f"bootstrap preserves compensation contract {contract}")


def test_bootstrap_recovers_only_a_verified_stale_docker_group() -> None:
    for contract in (
        "[ -S /var/run/docker.sock ]",
        "candidate_group=\"$(/usr/bin/stat -c '%G' /var/run/docker.sock)\"",
        'account_name="$(/usr/bin/id -un)"',
        'has_group "$candidate_group" $(/usr/bin/id -Gn "$account_name")',
        'has_group "$candidate_group" $(/usr/bin/id -Gn) && return 1',
        'docker_group="$candidate_group"',
        '/usr/bin/sg "$docker_group" -c',
        'run_command "$managed_cli" install --release "$release_ref"',
    ):
        check(contract in SCRIPT, f"bootstrap preserves stale-session recovery {contract}")
    check("SHIMPZ_RUN_5" not in SCRIPT, "closed handoff supports only the required arities")
    check('command="' not in SCRIPT, "group handoff never assembles a command string")


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
