#!/usr/bin/env python3
"""Contracts for the pull-only, digest-pinned Shimpz Space installer."""

import re
import stat
import subprocess
import tempfile
from pathlib import Path

from installer_egress_contract import (
    assert_account_egress_initializer,
    assert_account_egress_runtime,
    assert_assistant_egress_runtime,
    assert_assistant_release_runtime,
    assert_brain_egress_runtime,
)
from installer_project_contract import assert_project_validator_contract
from installer_project_harness import run_project_validator
from installer_reset_contract import assert_reset_contract

ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = ROOT / "static" / "install.sh"
SCRIPT = SCRIPT_PATH.read_text(encoding="utf-8")
CADDY = (ROOT / "Caddyfile").read_text(encoding="utf-8")
DOCKERIGNORE = (ROOT / ".dockerignore").read_text(encoding="utf-8")
def check(condition: object, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def _shell_functions(start_name: str, end_name: str) -> str:
    """Return the shipped function block without reimplementing installer logic."""
    start = SCRIPT.index(f"{start_name}() {{")
    end = SCRIPT.index(f"{end_name}() {{", start)
    return SCRIPT[start:end]


def _run_previous_ref_validator(image: str, repository: str) -> subprocess.CompletedProcess[str]:
    function = _shell_functions("validate_pinned_release_ref", "load_previous_release")
    command = (
        "set -eu\n"
        "die() { printf '%s\\n' \"$*\" >&2; exit 1; }\n"
        f"{function}\n"
        'validate_pinned_release_ref "$TEST_IMAGE" "$TEST_REPOSITORY"\n'
    )
    return subprocess.run(
        ["/bin/sh", "-c", command],
        check=False,
        capture_output=True,
        text=True,
        env={"TEST_IMAGE": image, "TEST_REPOSITORY": repository},
    )


def _run_project_validator(
    records: list[str],
    *,
    controller_environments: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    """Drive the exact shipped validator through a tiny executable Docker fake."""
    return run_project_validator(
        records,
        validator_functions=_shell_functions("validate_space_id", "dynamic_container_ids"),
        controller_environments=controller_environments,
    )


def _run_dynamic_validator(record: str) -> subprocess.CompletedProcess[str]:
    """Exercise the shipped Space-label validator against one fake container."""
    with tempfile.TemporaryDirectory() as raw_home:
        home = Path(raw_home)
        binary_dir = home / "bin"
        binary_dir.mkdir()
        docker = binary_dir / "docker"
        docker.write_text(
            """#!/bin/sh
case "$1 $2" in
    "ps --all") printf '%s\n' proxy ;;
    "network ls") : ;;
    "inspect --type=container") printf '%s\n' "$FAKE_DYNAMIC_RECORD" ;;
    *) exit 72 ;;
esac
""",
            encoding="utf-8",
        )
        docker.chmod(0o700)
        shell = home / "validator.sh"
        shell.write_text(
            """#!/bin/sh
set -eu
PROJECT_NAME="shimpz-space"
LOCAL_PROFILE="local-v1"
SPACE_LABEL="com.shimpz.local.space-id"
reset_space_id="space-111111111111111111111111"
die() { printf '%s\n' "$*" >&2; exit 1; }
"""
            + _shell_functions("dynamic_container_ids", "remove_validated_project_resources")
            + "\nvalidate_dynamic_resources\n",
            encoding="utf-8",
        )
        shell.chmod(0o700)
        return subprocess.run(
            ["/bin/sh", str(shell)],
            check=False,
            capture_output=True,
            text=True,
            env={
                "PATH": f"{binary_dir}:/usr/bin:/bin",
                "FAKE_DYNAMIC_RECORD": record,
            },
        )


def _run_reserved_name_validator(*, name: str, exists: bool, project: str) -> subprocess.CompletedProcess[str]:
    """Exercise the shipped global-name preflight against one fake collision."""
    with tempfile.TemporaryDirectory() as raw_home:
        home = Path(raw_home)
        binary_dir = home / "bin"
        binary_dir.mkdir()
        docker = binary_dir / "docker"
        docker.write_text(
            """#!/bin/sh
for argument in "$@"; do
    reserved_name="$argument"
done
[ "$reserved_name" = "$FAKE_NAME" ] || exit 1
[ "$FAKE_EXISTS" = "1" ] || exit 1
printf '%s\n' "$FAKE_PROJECT"
""",
            encoding="utf-8",
        )
        docker.chmod(0o700)
        shell = home / "validator.sh"
        reserved_names_assignment = next(
            line for line in SCRIPT.splitlines() if line.startswith("RESERVED_CONTAINER_NAMES=")
        )
        shell.write_text(
            """#!/bin/sh
set -eu
PROJECT_NAME="shimpz-space"
die() { printf '%s\n' "$*" >&2; exit 1; }
"""
            + reserved_names_assignment
            + "\n"
            + _shell_functions("validate_reserved_container_names", "validate_space_id")
            + "\nvalidate_reserved_container_names\n",
            encoding="utf-8",
        )
        shell.chmod(0o700)
        return subprocess.run(
            ["/bin/sh", str(shell)],
            check=False,
            capture_output=True,
            text=True,
            env={
                "HOME": str(home),
                "PATH": f"{binary_dir}:/usr/bin:/bin",
                "FAKE_NAME": name,
                "FAKE_EXISTS": "1" if exists else "0",
                "FAKE_PROJECT": project,
            },
        )


def test_script_is_posix_executable_and_self_describing():
    check(SCRIPT.startswith("#!/bin/sh\n\nset -eu\n"), "installer is fail-fast POSIX shell")
    check(SCRIPT_PATH.stat().st_mode & stat.S_IXUSR, "installer is executable in the published artifact")
    syntax = subprocess.run(["sh", "-n", str(SCRIPT_PATH)], check=False, capture_output=True, text=True)
    check(syntax.returncode == 0, f"installer passes sh -n: {syntax.stderr.strip()}")
    help_run = subprocess.run(["sh", str(SCRIPT_PATH), "--help"], check=False, capture_output=True, text=True)
    check(help_run.returncode == 0, "--help does not require Docker")
    check(
        "Linux amd64" in help_run.stdout
        and "Apple Silicon macOS arm64" in help_run.stdout
        and "--reset" in help_run.stdout,
        "help states both supported hosts and the lifecycle",
    )


def test_static_local_installer_contains_no_oauth_client_credentials():
    check(
        "SHIMPZ_CLOUDFLARE_OAUTH_CLIENT" not in SCRIPT,
        "local installer never requests, persists, or injects the hosted OAuth client credentials",
    )


def test_version_command_reports_the_stable_installer_release():
    version = subprocess.run(["sh", str(SCRIPT_PATH), "--version"], check=False, capture_output=True, text=True)
    check(version.returncode == 0 and version.stdout.strip() == "0.6.0", "version is an explicit stable release")


def test_brand_is_canonical_and_action_specific_for_install_and_reset():
    with tempfile.TemporaryDirectory() as raw_home:
        empty_path = Path(raw_home) / "bin"
        empty_path.mkdir()
        env = {"HOME": raw_home, "PATH": str(empty_path), "TERM": "xterm", "LC_ALL": "C"}
        install = subprocess.run(["/bin/sh", str(SCRIPT_PATH)], check=False, capture_output=True, text=True, env=env)
        reset = subprocess.run(
            ["/bin/sh", str(SCRIPT_PATH), "--reset"], check=False, capture_output=True, text=True, env=env
        )
        no_color = subprocess.run(
            ["/bin/sh", str(SCRIPT_PATH)],
            check=False,
            capture_output=True,
            text=True,
            env={**env, "NO_COLOR": ""},
        )
        dumb_terminal = subprocess.run(
            ["/bin/sh", str(SCRIPT_PATH), "--reset"],
            check=False,
            capture_output=True,
            text=True,
            env={**env, "TERM": "dumb"},
        )
        check(install.returncode != 0 and reset.returncode != 0, "brand preflights stop when Docker is absent")
        check(not (Path(raw_home) / ".shimpz").exists(), "brand preflights never create installer state")
    install_output = install.stdout + install.stderr
    reset_output = reset.stdout + reset.stderr
    check(
        "⣤⣶⣶⣤" in install_output and "|_____/|_| |_|_|_| |_| |_| .__/___|" in install_output,
        "install renders the canonical chimp and proportional wordmark",
    )
    install_brand_lines = install.stdout.splitlines()[:13]
    check(
        any("⠈⠁⠙⢦" in line and "_____ _" in line for line in install_brand_lines),
        "chimp and wordmark render side by side",
    )
    check(max(map(len, install_brand_lines)) <= 72, "combined terminal brand fits within 72 columns")
    check("space installer // stable" in install_output, "install renders its action label")
    check("safe reset // local data" in reset_output, "reset renders its action label")
    check(
        "|_____/|_|" in no_color.stdout and "|_____/|_|" in dumb_terminal.stdout,
        "disabled color never exits early",
    )
    for output in (install_output, reset_output):
        lines = [line for line in output.splitlines() if line]
        check(all(line.startswith("  ") for line in lines), "brand, status, and errors share one two-column margin")
    check(
        "\x1b" not in no_color.stdout + no_color.stderr + dumb_terminal.stdout + dumb_terminal.stderr,
        "NO_COLOR and dumb terminals stay free of terminal escapes",
    )
    check(not install_output.isascii() and not reset_output.isascii(), "both actions include the terminal symbol art")
    check("\x1b" not in install_output + reset_output, "captured action output stays free of terminal escapes")


def test_static_delivery_is_pull_only_and_content_addressed():
    repositories = {
        "ADMIN_REPOSITORY": "ghcr.io/theshimpz/shimpz-admin",
        "TEAM_REPOSITORY": "ghcr.io/theshimpz/shimpz-team-local",
        "BRAIN_REPOSITORY": "ghcr.io/theshimpz/shimpz-brain",
        "EGRESS_REPOSITORY": "ghcr.io/theshimpz/shimpz-egress",
    }
    for variable, repository in repositories.items():
        check(f'{variable}="{repository}"' in SCRIPT, f"installer owns the exact package {repository}")
    check("shimpz-space@" not in SCRIPT, "no platform artifact uses the Compose project as an OCI package")
    check('ADMIN_CHANNEL="stable"' in SCRIPT, "installer selects only the stable Admin channel")
    for channel in (
        "TEAM_CHANNEL",
        "BRAIN_CHANNEL",
        "EGRESS_CHANNEL",
    ):
        check(f'{channel}="stable"' in SCRIPT, f"installer selects only the stable {channel} channel")
    check(
        "SHIMPZ_TEAM_CHANNEL" not in SCRIPT
        and "SHIMPZ_INSTALL_PROFILE" not in SCRIPT
        and "local.shimpz.com" not in SCRIPT,
        "installer exposes no alternate release profile or channel",
    )
    for marker in (
        'docker pull --quiet --platform "$docker_platform"',
        "RepoDigests",
        "sha256:",
        '"${#digest_hex}" -eq 64',
        'admin_image_ref="$(pull_verified_ref "$admin_tag_ref" "$ADMIN_REPOSITORY")"',
        'team_image_ref="$(pull_verified_ref "$team_tag_ref" "$TEAM_REPOSITORY")"',
        'brain_image_ref="$(pull_verified_ref "$brain_tag_ref" "$BRAIN_REPOSITORY")"',
        'egress_image_ref="$(pull_verified_ref "$egress_tag_ref" "$EGRESS_REPOSITORY")"',
    ):
        check(marker in SCRIPT, f"installer derives an immutable image via {marker!r}")
    check(
        SCRIPT.count('pull_verified_ref "$') == 4,
        "all four platform artifact channels resolve independently to digests",
    )
    check("SHIMPZ_ADMIN_IMAGE=${admin_image_ref}" in SCRIPT, "the environment pins the Admin digest")
    check("SHIMPZ_TEAM_IMAGE=${team_image_ref}" in SCRIPT, "the environment pins the controller digest")
    check(
        "SHIMPZ_BRAIN_IMAGE=${brain_image_ref}" in SCRIPT,
        "the environment pins the Brain runtime digest",
    )
    check(
        "SHIMPZ_EGRESS_IMAGE=${egress_image_ref}" in SCRIPT,
        "the environment pins the shared egress digest once",
    )
    check(
        "SHIMPZ_SPACE_PLATFORM=${docker_platform}" in SCRIPT,
        "the generated environment stores the validated Docker platform",
    )
    check(
        "SHIMPZ_PROJECT_NAME=${PROJECT_NAME}" in SCRIPT
        and "SHIMPZ_ADMIN_ALLOWED_ORIGINS=${ADMIN_ALLOWED_ORIGINS}" in SCRIPT
        and "SHIMPZ_OAUTH_CALLBACK_MODE=${OAUTH_CALLBACK_MODE}" in SCRIPT
        and "name: ${SHIMPZ_PROJECT_NAME:?installer must pin SHIMPZ_PROJECT_NAME}" in SCRIPT
        and "SHIMPZ_ASSISTANT_EGRESS_CONTAINER: shimpz-assistant-egress" in SCRIPT,
        "the generated Compose project is pinned and the controller targets the named egress container",
    )
    compose = SCRIPT.split("cat >\"${COMPOSE_FILE}.tmp\" <<'COMPOSE'", 1)[1].split("\nCOMPOSE", 1)[0]
    container_names = re.findall(r"^    container_name: (\S+)$", compose, re.MULTILINE)
    check(
        container_names
        == [
            "shimpz-account-egress-init",
            "shimpz-team",
            "shimpz-assistant-egress",
            "shimpz-assistant-release",
            "shimpz-account-egress",
            "shimpz-brain-egress",
            "shimpz-brain",
            "shimpz-admin",
        ],
        "Compose assigns the eight stable, memorable container and job names exactly once",
    )
    reserved_line = next(line for line in SCRIPT.splitlines() if line.startswith("RESERVED_CONTAINER_NAMES="))
    check(
        sorted(reserved_line.split('"')[1].split()) == sorted(container_names),
        "the reserved-name preflight covers exactly the Compose container names",
    )
    check("image: ${SHIMPZ_ADMIN_IMAGE:?" in SCRIPT, "Compose fails closed without the pinned Admin reference")
    check(
        "image: ${SHIMPZ_TEAM_IMAGE:?" in SCRIPT,
        "Compose fails closed without the pinned controller reference",
    )
    check(
        "image: ${SHIMPZ_BRAIN_IMAGE:?" in SCRIPT,
        "Compose fails closed without the pinned Brain runtime reference",
    )
    check(
        SCRIPT.count("image: ${SHIMPZ_EGRESS_IMAGE:?") == 5,
        "all five egress services fail closed on the one pinned egress reference",
    )
    check(
        "platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}" in SCRIPT,
        "Compose fails closed without the pinned platform",
    )
    check("pull_policy: never" in SCRIPT and "--pull never" in SCRIPT, "Compose cannot silently replace the digest")
    check(
        'install_port="${SHIMPZ_PORT:-7777}"' in SCRIPT
        and "unset SHIMPZ_ADMIN_IMAGE SHIMPZ_TEAM_IMAGE SHIMPZ_BRAIN_IMAGE SHIMPZ_EGRESS_IMAGE" in SCRIPT
        and "unset SHIMPZ_SPACE_PLATFORM SHIMPZ_PORT" in SCRIPT
        and "unset SHIMPZ_DOCKER_GID SHIMPZ_DOCKER_SOCKET SHIMPZ_SPACE_ID SHIMPZ_CPUSET" in SCRIPT
        and "SHIMPZ_PORT=${install_port}" in SCRIPT,
        "exported shell variables cannot override install, rollback, or reset state",
    )
    for forbidden in ("git clone", "npm ", "pnpm ", "uv sync", "docker build", "build:"):
        check(forbidden not in SCRIPT, f"installer excludes source-build operation {forbidden!r}")


def test_remote_docker_endpoints_are_rejected_before_daemon_access():
    with tempfile.TemporaryDirectory() as raw_home:
        home = Path(raw_home)
        binary_dir = home / "bin"
        binary_dir.mkdir()
        calls = home / "docker.calls"
        docker = binary_dir / "docker"
        docker.write_text(
            """#!/bin/sh
printf '%s\\n' "$*" >>"$SHIMPZ_DOCKER_CALLS"
case "$*" in
  "compose version") exit 0 ;;
  "context show") printf '%s\\n' remote ;;
  "context inspect --format {{.Endpoints.docker.Host}} remote") printf '%s\\n' ssh://builder.example ;;
  "info") exit 91 ;;
  *) exit 92 ;;
esac
""",
            encoding="utf-8",
        )
        docker.chmod(0o700)
        base_env = {
            "HOME": str(home),
            "PATH": str(binary_dir),
            "TERM": "dumb",
            "SHIMPZ_DOCKER_CALLS": str(calls),
        }

        explicit = subprocess.run(
            ["/bin/sh", str(SCRIPT_PATH)],
            check=False,
            capture_output=True,
            text=True,
            env={**base_env, "DOCKER_HOST": "tcp://builder.example:2376"},
        )
        explicit_calls = calls.read_text(encoding="utf-8").splitlines()
        check(explicit.returncode != 0, "remote DOCKER_HOST is rejected")
        check("remote Docker contexts are not supported" in explicit.stderr, "remote DOCKER_HOST has a clear error")
        check(explicit_calls == ["compose version"], "DOCKER_HOST is rejected before any daemon command")

        calls.unlink()
        contextual = subprocess.run(
            ["/bin/sh", str(SCRIPT_PATH)],
            check=False,
            capture_output=True,
            text=True,
            env=base_env,
        )
        context_calls = calls.read_text(encoding="utf-8").splitlines()
        check(contextual.returncode != 0, "remote active Docker context is rejected")
        check("remote Docker contexts are not supported" in contextual.stderr, "remote context has a clear error")
        check(
            context_calls
            == [
                "compose version",
                "context show",
                "context inspect --format {{.Endpoints.docker.Host}} remote",
            ],
            "remote context is rejected before docker info or a lifecycle mutation",
        )
        check(not (home / ".shimpz").exists(), "remote endpoint rejection creates no installer state")


def _check_admin_runtime(admin: str, compose: str) -> None:
    for marker in (
        '"127.0.0.1:${SHIMPZ_PORT:-7777}:4600"',
        'user: "1000:1000"',
        "read_only: true",
        "cap_drop:",
        "- ALL",
        "no-new-privileges:true",
        "noexec,nosuid,nodev",
        'cpus: "2.0"',
        "mem_limit: 512m",
        "pids_limit: 128",
        "/api/session",
    ):
        check(marker in SCRIPT, f"generated Admin runtime enforces {marker!r}")
    check("docker.sock" not in admin, "Admin never receives the Docker socket")
    check(
        compose.count("${SHIMPZ_DOCKER_SOCKET:?installer must bind the platform Docker socket}:/var/run/docker.sock:rw")
        == 1,
        "only the controller receives the socket",
    )


def _check_controller_runtime(controller: str) -> None:
    for marker in (
        'user: "10001:10001"',
        '"${SHIMPZ_DOCKER_GID:?installer must bind the Docker socket group}"',
        "SHIMPZ_SPACE_ID: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}",
        "controller_token:/run/shimpz-local:rw",
        "controller_audit:/var/log/shimpz-local:rw",
        "controller_storage:/var/lib/shimpz-local/storage:rw",
        "controller_inference:/var/lib/shimpz-local/inference:rw",
        "controller_power_journal:/var/lib/shimpz-local/power-journal:rw",
        "controller_publications:/var/lib/shimpz-local/publications:rw",
        "controller_cosign_trust:/var/lib/shimpz-local/cosign:rw",
        "controller_assistant_integration_state:/var/lib/shimpz-local/assistant-integrations/state:rw",
        "controller_assistant_integration_key:/var/lib/shimpz-local/assistant-integrations/key:rw",
        "controller_chat_continuation_state:/var/lib/shimpz-local/chat-continuations/state:rw",
        "controller_chat_continuation_key:/var/lib/shimpz-local/chat-continuations/key:rw",
        "assistant_egress_policy:/var/lib/shimpz-local/assistant-egress:rw",
        "brain_runtime_token:/run/shimpz-brain-runtime:rw",
        "supervisor_key:/run/shimpz-local-supervisor:ro",
        "SHIMPZ_LOCAL_POWER_JOURNAL_PATH: /var/lib/shimpz-local/power-journal/journal.sqlite3",
        "SHIMPZ_LOCAL_CHAT_CONTINUATIONS_STATE_PATH: /var/lib/shimpz-local/chat-continuations/state/continuations.json",
        "SHIMPZ_LOCAL_CHAT_CONTINUATIONS_KEY_PATH: /var/lib/shimpz-local/chat-continuations/key/aes256.key",
        "SHIMPZ_BRAIN_RUNTIME_URL: http://brain:8080",
        "SHIMPZ_BRAIN_RUNTIME_TOKEN_FILE: /run/shimpz-brain-runtime/token",
        "SHIMPZ_OAUTH_CALLBACK_MODE: ${SHIMPZ_OAUTH_CALLBACK_MODE:?installer must pin the OAuth callback mode}",
        "SHIMPZ_OAUTH_BROKER_PROXY_HOST: shimpz-account-egress",
        "SHIMPZ_OAUTH_BROKER_PROXY_CAPABILITY_FILE: /run/shimpz-account-egress/token",
        "account_egress_capability:/run/shimpz-account-egress:ro",
        "SHIMPZ_ASSISTANT_EGRESS_CONTAINER: shimpz-assistant-egress",
        "SHIMPZ_ASSISTANT_EGRESS_POLICY_DIR: /var/lib/shimpz-local/assistant-egress",
        "shimpz-assistant-egress:\n        condition: service_started",
        "shimpz-assistant-release:\n        condition: service_healthy",
        "- assistant_release",
        '- "10016"',
        '- "10017"',
        '- "10021"',
        '- "10022"',
        "shimpz-account-egress-init:\n        condition: service_completed_successfully",
        'cpus: "1.0"',
        "mem_limit: 256m",
        "memswap_limit: 256m",
        "pids_limit: 128",
    ):
        check(marker in controller, f"local controller enforces {marker!r}")
    for proxy_variable in ("HTTPS_PROXY", "HTTP_PROXY", "https_proxy", "http_proxy", "NO_PROXY", "no_proxy"):
        check(proxy_variable not in controller, f"Team controller excludes global {proxy_variable}")


def _check_brain_runtime(brain_runtime: str) -> None:
    for marker in (
        "${SHIMPZ_BRAIN_IMAGE:?installer must pin SHIMPZ_BRAIN_IMAGE}",
        'user: "10001:10001"',
        '- "10016"',
        "read_only: true",
        "cap_drop:\n      - ALL",
        "no-new-privileges:true",
        'LANGCHAIN_TRACING_V2: "false"',
        'LANGSMITH_TRACING: "false"',
        "HTTPS_PROXY: http://shimpz-brain-egress:8888",
        "HTTP_PROXY: http://shimpz-brain-egress:8888",
        "https_proxy: http://shimpz-brain-egress:8888",
        "http_proxy: http://shimpz-brain-egress:8888",
        "brain_runtime_token:/run/shimpz-brain-runtime:ro",
        "brain_runtime_state:/var/lib/shimpz-brain-runtime:rw",
        "SHIMPZ_BRAIN_RUNTIME_STATE: /var/lib/shimpz-brain-runtime/checkpoints.sqlite3",
        "/tmp:rw,noexec,nosuid,nodev,size=64m",
        'cpus: "2.0"',
        "mem_limit: 1g",
        "memswap_limit: 1g",
        "pids_limit: 128",
        "condition: service_healthy",
        "shimpz-brain-egress:\n        condition: service_healthy",
        "- brain_runtime\n      - brain_egress",
    ):
        check(marker in brain_runtime, f"isolated Brain runtime enforces {marker!r}")
    check("docker.sock" not in brain_runtime, "Brain runtime never receives the Docker socket")
    check("controller_token" not in brain_runtime, "Brain runtime never receives the Admin/Controller bearer")
    check("controller_inference" not in brain_runtime, "Brain runtime never mounts Team metadata")
    check("controller_power_journal" not in brain_runtime, "Brain runtime never mounts Power execution state")
    check(
        "controller_assistant_integration_" not in brain_runtime,
        "Brain runtime never mounts encrypted Assistant OAuth state or its key",
    )
    check(
        "controller_chat_continuation_" not in brain_runtime,
        "Brain runtime never mounts encrypted chat continuations or their key",
    )


def _check_compose_isolation(admin: str, compose: str, controller: str) -> None:
    for marker in (
        'group_add:\n      - "10010"',
        "SHIMPZ_ADMIN_PROFILE: local",
        "SHIMPZ_TEAM_URL: http://team:7077",
        "SHIMPZ_TEAM_TOKEN_FILE: /run/shimpz-local/token",
        'SHIMPZ_TEAM_CREDENTIALS_ENABLED: "0"',
        "controller_token:/run/shimpz-local:ro",
        "supervisor_key:/run/shimpz-local-supervisor:rw",
        '- "10021"',
        "condition: service_healthy",
    ):
        check(marker in admin, f"Admin consumes the controller boundary via {marker!r}")
    check("control:\n    driver: bridge\n    internal: true" in compose, "the control network is internal")
    check(
        "brain_runtime:\n    driver: bridge\n    internal: true" in compose,
        "the Controller-to-Brain network is internal",
    )
    check(
        "brain_egress:\n    driver: bridge\n    internal: true" in compose,
        "Brain-to-proxy network is internal",
    )
    check("brain_egress_out:\n    driver: bridge" in compose, "Brain proxy has one dedicated outbound network")
    check("- control\n      - egress" in admin, "Admin alone bridges control to egress")
    check("- egress" not in controller, "controller has no egress network")
    check("brain_runtime" not in admin and "brain_egress" not in admin, "Admin cannot join either Brain network")
    check("brain_egress" not in controller, "Controller cannot reach provider egress")
    check("- account_egress" in controller, "Controller reaches only the internal OAuth broker proxy plane")
    check("- account_egress_out" not in controller, "Controller cannot bypass the OAuth broker proxy")
    check("controller_storage" not in admin, "Admin never mounts opaque Team storage")
    check("controller_power_journal" not in admin, "Admin never mounts Power execution state")
    check(
        "controller_assistant_integration_" not in admin,
        "Admin never mounts encrypted Assistant OAuth state or its key",
    )
    check(
        "controller_chat_continuation_" not in admin,
        "Admin never mounts encrypted chat continuations or their key",
    )
    check(SCRIPT.count("  controller_power_journal:") == 1, "Compose declares exactly one Power journal volume")
    check(
        SCRIPT.count("  controller_publications:") == 1,
        "Compose declares exactly one Assistant publication-binding volume",
    )
    check(
        SCRIPT.count("  controller_cosign_trust:") == 1,
        "Compose declares exactly one persistent private Cosign trust volume",
    )
    check(
        SCRIPT.count("  controller_assistant_integration_state:") == 1,
        "Compose declares exactly one encrypted Assistant OAuth-state volume",
    )
    check(
        SCRIPT.count("  controller_assistant_integration_key:") == 1,
        "Compose declares exactly one independent Assistant OAuth-key volume",
    )
    check(
        SCRIPT.count("  controller_chat_continuation_state:") == 1,
        "Compose declares exactly one encrypted chat-continuation state volume",
    )
    check(
        SCRIPT.count("  controller_chat_continuation_key:") == 1,
        "Compose declares exactly one independent chat-continuation key volume",
    )
    check(
        SCRIPT.count("  supervisor_key:") == 1,
        "Compose declares exactly one Local Supervisor public-key volume",
    )
    check("SHIMPZ_CLOUDFLARE_OAUTH_CLIENT" not in SCRIPT, "installer contains no OAuth client credentials")
    check("SHIMPZ_X_OAUTH_CLIENT_ID" not in SCRIPT, "installer contains no unsupported X OAuth configuration")
    check("postgres" not in SCRIPT, "bootstrap does not claim an unshipped PostgreSQL dependency")
    check("at least 12 characters" in SCRIPT, "success output states the real initial password minimum")


def test_static_runtime_separates_socketless_admin_from_local_controller():
    compose = SCRIPT.split("cat >\"${COMPOSE_FILE}.tmp\" <<'COMPOSE'", 1)[1].split("\nCOMPOSE", 1)[0]
    initializer = compose.split("  shimpz-account-egress-init:", 1)[1].split("\n  team:", 1)[0]
    controller = compose.split("  team:", 1)[1].split("\n  shimpz-assistant-egress:", 1)[0]
    assistant_egress = compose.split("\n  shimpz-assistant-egress:\n", 1)[1].split(
        "\n  shimpz-assistant-release:\n", 1
    )[0]
    assistant_release = compose.split("\n  shimpz-assistant-release:\n", 1)[1].split(
        "\n  shimpz-account-egress:\n", 1
    )[0]
    account_egress = compose.split("\n  shimpz-account-egress:\n", 1)[1].split(
        "\n  shimpz-brain-egress:\n", 1
    )[0]
    brain_egress = compose.split("\n  shimpz-brain-egress:\n", 1)[1].split("\n  brain:\n", 1)[0]
    brain_runtime = compose.split("  brain:", 1)[1].split("\n  admin:", 1)[0]
    admin = compose.split("  admin:", 1)[1].split("\nvolumes:", 1)[0]
    _check_admin_runtime(admin, compose)
    assert_account_egress_initializer(initializer, check)
    _check_controller_runtime(controller)
    assert_brain_egress_runtime(brain_egress, compose, check)
    _check_brain_runtime(brain_runtime)
    _check_compose_isolation(admin, compose, controller)
    assert_assistant_egress_runtime(assistant_egress, compose, check)
    assert_assistant_release_runtime(assistant_release, compose, check)
    assert_account_egress_runtime(account_egress, compose, check)


def test_reset_accepts_only_the_exact_space_owned_egress_proxy():
    space_id = "space-111111111111111111111111"
    valid = "|".join(
        (
            "/shimpz-assistant-egress",
            "1",
            "local-v1",
            space_id,
            "assistant-egress",
            "",
            "",
        )
    )
    accepted = _run_dynamic_validator(valid)
    check(accepted.returncode == 0, f"the exact Compose egress proxy is accepted: {accepted.stderr.strip()}")
    for label, invalid in (
        ("name", valid.replace("/shimpz-assistant-egress", "/shimpz-space-foreign-1")),
        ("profile", valid.replace("local-v1", "foreign-profile")),
        ("Space", valid.replace(space_id, "space-222222222222222222222222")),
        ("kind", valid.replace("assistant-egress", "assistant-proxy")),
    ):
        rejected = _run_dynamic_validator(invalid)
        check(rejected.returncode != 0, f"an egress proxy with a foreign {label} fails closed")

    oauth = valid.replace("/shimpz-assistant-egress", "/shimpz-account-egress").replace(
        "|assistant-egress|", "|account-egress|"
    )
    accepted_oauth = _run_dynamic_validator(oauth)
    check(
        accepted_oauth.returncode == 0,
        f"the exact Compose OAuth broker proxy is accepted: {accepted_oauth.stderr.strip()}",
    )
    for confused in (
        valid.replace("|assistant-egress|", "|account-egress|"),
        valid.replace("/shimpz-assistant-egress", "/shimpz-account-egress"),
        oauth.replace("/shimpz-account-egress", "/shimpz-space-foreign-1"),
    ):
        rejected = _run_dynamic_validator(confused)
        check(rejected.returncode != 0, "an OAuth or egress proxy with a mismatched exact name fails closed")

    release = valid.replace("/shimpz-assistant-egress", "/shimpz-assistant-release").replace(
        "|assistant-egress|",
        "|assistant-release|",
    )
    accepted_release = _run_dynamic_validator(release)
    check(
        accepted_release.returncode == 0,
        f"the exact Assistant release proxy is accepted: {accepted_release.stderr.strip()}",
    )
    for confused in (
        valid.replace("|assistant-egress|", "|assistant-release|"),
        valid.replace("/shimpz-assistant-egress", "/shimpz-assistant-release"),
        release.replace("/shimpz-assistant-release", "/shimpz-space-foreign-1"),
    ):
        rejected = _run_dynamic_validator(confused)
        check(rejected.returncode != 0, "an Assistant release proxy with a mismatched exact name fails closed")

    brain = valid.replace("/shimpz-assistant-egress", "/shimpz-brain-egress").replace(
        "|assistant-egress|",
        "|brain-egress|",
    )
    accepted_brain = _run_dynamic_validator(brain)
    check(
        accepted_brain.returncode == 0,
        f"the exact Compose Brain egress proxy is accepted: {accepted_brain.stderr.strip()}",
    )
    for confused in (
        valid.replace("|assistant-egress|", "|brain-egress|"),
        valid.replace("/shimpz-assistant-egress", "/shimpz-brain-egress"),
        brain.replace("/shimpz-brain-egress", "/shimpz-space-foreign-1"),
    ):
        rejected = _run_dynamic_validator(confused)
        check(rejected.returncode != 0, "a Brain egress proxy with a mismatched exact name fails closed")


def test_static_admin_chat_origin_allowlist_is_loopback_only():
    compose = SCRIPT.split("cat >\"${COMPOSE_FILE}.tmp\" <<'COMPOSE'", 1)[1].split("\nCOMPOSE", 1)[0]
    admin = compose.split("  admin:", 1)[1].split("\nvolumes:", 1)[0]
    loopback_port_lines = [line.strip() for line in admin.splitlines() if "SHIMPZ_ADMIN_LOOPBACK_PORT:" in line]
    origin_lines = [line.strip() for line in admin.splitlines() if "SHIMPZ_ADMIN_ALLOWED_ORIGINS:" in line]
    oauth_lines = [line.strip() for line in admin.splitlines() if "SHIMPZ_OAUTH_CALLBACK_MODE:" in line]
    check(
        loopback_port_lines == ["SHIMPZ_ADMIN_LOOPBACK_PORT: ${SHIMPZ_PORT:-7777}"],
        "local Admin derives its OAuth loopback port from the published installer port",
    )
    custom_port_admin = admin.replace("${SHIMPZ_PORT:-7777}", "8123")
    check(
        '"127.0.0.1:8123:4600"' in custom_port_admin and "SHIMPZ_ADMIN_LOOPBACK_PORT: 8123" in custom_port_admin,
        "a custom installer port drives both the published port and OAuth callback origin",
    )
    check(
        origin_lines
        == ["SHIMPZ_ADMIN_ALLOWED_ORIGINS: ${SHIMPZ_ADMIN_ALLOWED_ORIGINS:?installer must pin Admin origins}"],
        "local Admin receives only the stable loopback origins",
    )
    check(
        oauth_lines
        == [
            "SHIMPZ_OAUTH_CALLBACK_MODE: "
            "${SHIMPZ_OAUTH_CALLBACK_MODE:?installer must pin the Admin OAuth callback mode}"
        ],
        "local Admin receives the same closed OAuth callback mode as its controller",
    )
    check(
        'ADMIN_ALLOWED_ORIGINS="http://localhost:${SHIMPZ_PORT:-7777},http://127.0.0.1:${SHIMPZ_PORT:-7777}"' in SCRIPT
        and "local.shimpz.com" not in SCRIPT,
        "the stable installer remains loopback-only",
    )


def test_static_host_platform_allowlist_is_exact_and_native():
    for marker in (
        "Linux:x86_64|Linux:amd64",
        'docker_platform="linux/amd64"',
        "Darwin:arm64",
        'docker_platform="linux/arm64"',
        'Darwin:*) die "this stable installer supports Apple Silicon Macs only"',
        'Linux:*) die "this stable installer supports Linux amd64 only"',
        "supported hosts are Linux amd64 and Apple Silicon macOS arm64",
    ):
        check(marker in SCRIPT, f"host platform contract includes {marker!r}")
    check("Darwin:x86_64)" not in SCRIPT, "Intel Macs are never accepted")
    check("Linux:arm64)" not in SCRIPT, "this slice does not claim Linux ARM host support")
    check(
        "pulled_platform=" in SCRIPT and '[ "$pulled_platform" = "$docker_platform" ]' in SCRIPT,
        "installer rejects Docker platform fallback or mismatch",
    )


def test_static_space_identity_socket_access_and_cpu_set_are_runtime_derived():
    for marker in (
        "od -An -N12 -tx1 /dev/urandom",
        "printf 'space-%s\\n' \"$space_hex\"",
        '[ "${#space_hex}" -eq 24 ]',
        "space_id_from_env_file",
        "SHIMPZ_SPACE_ID=${space_id}",
        "SHIMPZ_DOCKER_GID=${docker_socket_gid}",
        "SHIMPZ_DOCKER_SOCKET=${docker_socket_source}",
        "SHIMPZ_CPUSET=${docker_cpuset}",
        "controller_socket_gid",
        'os.stat("/var/run/docker.sock").st_gid',
        "controller_can_reach_docker",
        "GET /_ping HTTP/1.0\\r\\nHost: docker",
        '--group-add "$controller_gid"',
        "docker info --format '{{.NCPU}}'",
        "half_processors=$((daemon_processors / 2))",
        'docker_cpuset="0-$((half_processors - 1))"',
    ):
        check(marker in SCRIPT, f"host-derived runtime state retains {marker!r}")
    check(
        'docker_socket_candidates="/var/run/docker.sock"' in SCRIPT
        and 'docker_socket_candidates="/var/run/docker.sock.raw /var/run/docker.sock"' in SCRIPT
        and "${SHIMPZ_DOCKER_SOCKET:?installer must bind the platform Docker socket}:/var/run/docker.sock:rw" in SCRIPT,
        "Linux uses the native socket while Docker Desktop prefers its VM socket with a validated fallback",
    )
    check(
        "stat -c '%g' /var/run/docker.sock" not in SCRIPT and "stat -f '%g' /var/run/docker.sock" not in SCRIPT,
        "socket ownership is measured inside Docker rather than from the macOS symlink",
    )
    check(
        SCRIPT.index('team_image_ref="$(pull_verified_ref "$team_tag_ref" "$TEAM_REPOSITORY")"')
        < SCRIPT.index(
            'candidate_gid="$(docker_socket_source="$socket_candidate" controller_socket_gid "$team_image_ref"'
        )
        < SCRIPT.index("had_previous=0"),
        "the digest-pinned controller proves Docker access before an existing release is touched",
    )
    check(
        'space_id="$(space_id_from_env_file || true)"' in SCRIPT,
        "updates preserve the existing generated Space identity",
    )
    check(
        'controller_space_id" = "$space_id"' in SCRIPT and 'reset_space_id="$controller_space_id"' in SCRIPT,
        "updates and orphan reset bind Docker ownership to the same Space identity",
    )


def test_static_update_rollback_and_reset_are_bounded():
    check(SCRIPT.count(".previous") >= 8, "update preserves and restores the previous Compose release")
    check("rollback also failed" in SCRIPT, "a failed rollback is surfaced rather than hidden")
    startup = "compose up -d --wait --wait-timeout 120 --no-build --pull never --remove-orphans"
    check(
        SCRIPT.count(startup) == 2,
        "candidate and rollback startup remove containers absent from the managed Compose release",
    )
    for marker in (
        "previous_env_value",
        "load_previous_release",
        "SHIMPZ_ADMIN_IMAGE",
        "previous_admin_ref",
        "SHIMPZ_TEAM_IMAGE",
        "previous_team_ref",
        "SHIMPZ_BRAIN_IMAGE",
        "previous_brain_ref",
        "SHIMPZ_EGRESS_IMAGE",
        "previous_egress_ref",
        "validate_pinned_release_ref",
        "ensure_pinned_release_ref",
        "hydrate_previous_release",
        "Pinning the previous release for safe rollback",
        "the running version was not changed",
    ):
        check(marker in SCRIPT, f"rollback availability is locked by {marker!r}")
    update_branch = SCRIPT.split("had_previous=0", 1)[1]
    candidate_branch = update_branch.split(f"if ! {startup}; then", 1)
    check(
        candidate_branch[0].index('cp "$ENV_FILE" "${ENV_FILE}.previous"')
        < candidate_branch[0].index("load_previous_release")
        < candidate_branch[0].index("hydrate_previous_release"),
        "the previous digest refs are rehydrated before candidate recreation",
    )
    failed_candidate = candidate_branch[1].split("\nfi\n\nrm -f", 1)[0]
    check(
        failed_candidate.index("compose logs --no-color --tail 20 team")
        < failed_candidate.index("compose logs --no-color --tail 20 shimpz-assistant-egress")
        < failed_candidate.index("compose logs --no-color --tail 20 shimpz-assistant-release")
        < failed_candidate.index("compose logs --no-color --tail 20 shimpz-account-egress")
        < failed_candidate.index("compose logs --no-color --tail 20 shimpz-brain-egress")
        < failed_candidate.index("compose logs --no-color --tail 20 brain >&2")
        < failed_candidate.index("hydrate_previous_release")
        < failed_candidate.index("compose down --remove-orphans")
        < failed_candidate.index('step "Restoring the previous pinned release"'),
        "candidate diagnostics and rollback refs are secured before containers are removed",
    )
    check(
        failed_candidate.index('mv "${ENV_FILE}.previous" "$ENV_FILE"')
        < failed_candidate.index("previous files were restored without deleting Docker data"),
        "a rollback preflight failure restores previous files while leaving Docker data untouched",
    )
    check("compose down --volumes" not in failed_candidate, "rollback never removes persistent volumes")
    check("umask 077" in SCRIPT and "chmod 700" in SCRIPT, "local installer state is private")
    check(SCRIPT.count("chmod 600") >= 3, "generated config, environment, and marker are owner-only")
    assert_reset_contract(SCRIPT, check)


def test_previous_release_refs_are_bound_to_their_responsibility():
    digest = "a" * 64
    admin = "ghcr.io/theshimpz/shimpz-admin"
    team = "ghcr.io/theshimpz/shimpz-team-local"
    check(
        _run_previous_ref_validator(f"{admin}@sha256:{digest}", admin).returncode == 0,
        "rollback accepts an exact responsibility-owned digest",
    )
    swapped = _run_previous_ref_validator(f"{team}@sha256:{digest}", admin)
    check(
        swapped.returncode != 0 and "responsibility-owned" in swapped.stderr,
        "rollback rejects an official image owned by another responsibility",
    )
    check(
        _run_previous_ref_validator(f"{admin}:stable", admin).returncode != 0,
        "rollback rejects mutable responsibility-owned tags",
    )


def test_project_validator_enforces_current_container_names():
    assert_project_validator_contract(_run_project_validator)


def test_reserved_container_name_preflight_is_early_and_fail_closed():
    own = _run_reserved_name_validator(name="shimpz-admin", exists=True, project="shimpz-space")
    check(own.returncode == 0, f"the managed project may retain its reserved names: {own.stderr.strip()}")

    missing = _run_reserved_name_validator(name="shimpz-admin", exists=False, project="")
    check(missing.returncode == 0, f"unused reserved names remain available: {missing.stderr.strip()}")

    for foreign_project in ("", "another-project"):
        foreign = _run_reserved_name_validator(name="shimpz-admin", exists=True, project=foreign_project)
        check(foreign.returncode != 0, "an unlabeled or foreign container cannot claim a reserved Shimpz name")
        check("another Docker container is already named shimpz-admin" in foreign.stderr, "the collision is named")

    final_name = _run_reserved_name_validator(
        name="shimpz-account-egress-init", exists=True, project="another-project"
    )
    check(final_name.returncode != 0, "the reserved-name preflight checks through its final name")
    check(
        "already named shimpz-account-egress-init" in final_name.stderr,
        "a collision on the final reserved name is identified",
    )

    docker_ready = SCRIPT.index("docker info >/dev/null 2>&1 || die")
    preflight = SCRIPT.index("\nvalidate_reserved_container_names\n")
    first_state_write = SCRIPT.index('umask 077\nmkdir -p "$SHIMPZ_HOME"')
    check(
        docker_ready < preflight < first_state_write,
        "reserved names are validated after Docker is proven and before installer state is written",
    )


def test_static_docs_origin_serves_only_the_installer_paths():
    check("!static/" in DOCKERIGNORE and "!static/**" in DOCKERIGNORE, "installer enters the Docs image context")
    check("host install.shimpz.com" in CADDY, "installer hostname has an explicit route")
    check("path / /install.sh" in CADDY, "only root and the canonical installer path are served")
    check('Content-Type "text/x-shellscript; charset=utf-8"' in CADDY, "installer has a shell media type")
    check('Cache-Control "no-store"' in CADDY, "bootstrap is never retained by intermediary caches")
    check(
        "@installer_missing host install.shimpz.com\n\thandle @installer_missing {\n\t\trespond 404\n\t}" in CADDY,
        "unknown installer-host paths are handled as real 404s before the Docs fallback",
    )


if __name__ == "__main__":
    contracts = [value for name, value in globals().items() if name.startswith("test_") and callable(value)]
    for contract in contracts:
        contract()
    print(f"{len(contracts)} Shimpz Space installer contracts passed")
