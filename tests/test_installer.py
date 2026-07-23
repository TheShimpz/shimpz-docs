#!/usr/bin/env python3
"""Contracts for the pull-only, digest-pinned Shimpz Space installer."""

import re
import stat
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = ROOT / "static" / "install.sh"
SCRIPT = SCRIPT_PATH.read_text(encoding="utf-8")
CADDY = (ROOT / "Caddyfile").read_text(encoding="utf-8")
DOCKERIGNORE = (ROOT / ".dockerignore").read_text(encoding="utf-8")
IMAGE_REPOSITORY_FOR_TESTS = "ghcr.io/theshimpz/shimpz-space"
PRIOR_IMAGE_REPOSITORY_FOR_TESTS = "ghcr.io/roxygens/shimpz-space"
APP_EGRESS_DIGEST = "190b8ab6bc3880071e387363c2a9a5876480cc642e7597e36b8be6365218c1c8"


def check(condition: object, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def _shell_functions(start_name: str, end_name: str) -> str:
    """Return the shipped function block without reimplementing installer logic."""
    start = SCRIPT.index(f"{start_name}() {{")
    end = SCRIPT.index(f"{end_name}() {{", start)
    return SCRIPT[start:end]


def _run_project_validator(
    records: list[str],
    *,
    prior_image: str,
    controller_environments: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    """Drive the exact shipped validator through a tiny executable Docker fake."""
    controller_environments = controller_environments or {}
    with tempfile.TemporaryDirectory() as raw_home:
        home = Path(raw_home)
        binary_dir = home / "bin"
        binary_dir.mkdir()
        docker = binary_dir / "docker"
        docker.write_text(
            """#!/bin/sh
resource_id=""
for argument in "$@"; do
    resource_id="$argument"
done
case "$*" in
    *"range .Config.Env"*)
        case "$resource_id" in
            current) printf '%s\n' "$FAKE_CURRENT_ENV" ;;
            prior) printf '%s\n' "$FAKE_PRIOR_ENV" ;;
            prior_two) printf '%s\n' "$FAKE_PRIOR_TWO_ENV" ;;
            *) exit 71 ;;
        esac
        ;;
    *)
        case "$resource_id" in
            current) printf '%s\n' "$FAKE_CURRENT_RECORD" ;;
            prior) printf '%s\n' "$FAKE_PRIOR_RECORD" ;;
            prior_two) printf '%s\n' "$FAKE_PRIOR_TWO_RECORD" ;;
            foreign) printf '%s\n' "$FAKE_FOREIGN_RECORD" ;;
            *) exit 72 ;;
        esac
        ;;
esac
""",
            encoding="utf-8",
        )
        docker.chmod(0o700)
        env_file = home / ".env"
        env_file.write_text(f"SHIMPZ_CONTROLLER_IMAGE={prior_image}\n", encoding="utf-8")
        shell = home / "validator.sh"
        prior_service_assignment = next(
            line for line in SCRIPT.splitlines() if line.startswith("PRIOR_CONTROLLER_SERVICE=")
        )
        shell.write_text(
            """#!/bin/sh
set -eu
PROJECT_NAME="shimpz-space"
IMAGE_REPOSITORY="ghcr.io/theshimpz/shimpz-space"
PRIOR_IMAGE_REPOSITORY="ghcr.io/roxygens/shimpz-space"
ENV_FILE="$TEST_ENV_FILE"
CONTAINER_IDS="$TEST_CONTAINER_IDS"
die() { printf '%s\n' "$*" >&2; exit 1; }
project_container_ids() { printf '%s\n' "$CONTAINER_IDS"; }
project_volume_ids() { :; }
project_network_ids() { :; }
"""
            + prior_service_assignment
            + "\n"
            + _shell_functions("validate_space_id", "dynamic_container_ids")
            + """
prior_controller_image_ref="$(controller_image_from_env_file)"
validate_project_resources
printf '%s|%s|%s|%s\n' \
    "$controller_id" "$controller_space_id" "$controller_seen" "$prior_controller_seen"
""",
            encoding="utf-8",
        )
        shell.chmod(0o700)
        fake_records = {record.split("|", 1)[0]: record.split("|", 1)[1] for record in records}
        environment = {
            "HOME": str(home),
            "PATH": f"{binary_dir}:/usr/bin:/bin",
            "TEST_ENV_FILE": str(env_file),
            "TEST_CONTAINER_IDS": " ".join(fake_records),
            "FAKE_CURRENT_RECORD": fake_records.get("current", ""),
            "FAKE_PRIOR_RECORD": fake_records.get("prior", ""),
            "FAKE_PRIOR_TWO_RECORD": fake_records.get("prior_two", ""),
            "FAKE_FOREIGN_RECORD": fake_records.get("foreign", ""),
            "FAKE_CURRENT_ENV": controller_environments.get("current", ""),
            "FAKE_PRIOR_ENV": controller_environments.get("prior", ""),
            "FAKE_PRIOR_TWO_ENV": controller_environments.get("prior_two", ""),
        }
        return subprocess.run(
            ["/bin/sh", str(shell)],
            check=False,
            capture_output=True,
            text=True,
            env=environment,
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
LOCAL_PROFILE="single-owner-local-v1"
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
    check(version.returncode == 0 and version.stdout.strip() == "0.4.7", "version is an explicit stable release")


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
    check('IMAGE_REPOSITORY="ghcr.io/theshimpz/shimpz-space"' in SCRIPT, "installer uses the canonical package")
    check(
        'PRIOR_IMAGE_REPOSITORY="ghcr.io/roxygens/shimpz-space"' in SCRIPT,
        "installer allowlists the retired official package only for digest-pinned migration",
    )
    check('ADMIN_CHANNEL="stable"' in SCRIPT, "installer selects only the stable Admin channel")
    check(
        'CONTROLLER_CHANNEL="team-driver-local-stable"' in SCRIPT,
        "installer selects only the stable local-controller channel",
    )
    check(
        'BRAIN_RUNTIME_CHANNEL="brain-runtime-stable"' in SCRIPT,
        "installer selects only the stable Brain runtime channel",
    )
    check(
        "SHIMPZ_CONTROLLER_CHANNEL" not in SCRIPT
        and "SHIMPZ_INSTALL_PROFILE" not in SCRIPT
        and "local.shimpz.com" not in SCRIPT,
        "installer exposes no alternate release profile or channel",
    )
    check(
        f'APP_EGRESS_RELEASE="${{IMAGE_REPOSITORY}}@sha256:{APP_EGRESS_DIGEST}"' in SCRIPT,
        "installer binds the published Assistant egress index by its exact digest",
    )
    for marker in (
        'docker pull --quiet --platform "$docker_platform"',
        "RepoDigests",
        "sha256:",
        '"${#digest_hex}" -eq 64',
        'admin_image_ref="$(pull_verified_ref "$admin_tag_ref")"',
        'controller_image_ref="$(pull_verified_ref "$controller_tag_ref")"',
        'brain_runtime_image_ref="$(pull_verified_ref "$brain_runtime_tag_ref")"',
        'ensure_pinned_release_ref "$APP_EGRESS_RELEASE" "$docker_platform"',
        'app_egress_image_ref="$APP_EGRESS_RELEASE"',
    ):
        check(marker in SCRIPT, f"installer derives an immutable image via {marker!r}")
    check(
        SCRIPT.count('pull_verified_ref "$') == 3,
        "Admin, controller, and Brain runtime stable channels are independently resolved to digests",
    )
    check(re.fullmatch(r"[0-9a-f]{64}", APP_EGRESS_DIGEST) is not None, "Assistant egress binding is a sha256")
    check("SHIMPZ_ADMIN_IMAGE=${admin_image_ref}" in SCRIPT, "the environment pins the Admin digest")
    check("SHIMPZ_CONTROLLER_IMAGE=${controller_image_ref}" in SCRIPT, "the environment pins the controller digest")
    check(
        "SHIMPZ_BRAIN_RUNTIME_IMAGE=${brain_runtime_image_ref}" in SCRIPT,
        "the environment pins the Brain runtime digest",
    )
    check(
        "SHIMPZ_APP_EGRESS_IMAGE=${app_egress_image_ref}" in SCRIPT,
        "the environment pins the Assistant egress proxy digest",
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
        and "${SHIMPZ_PROJECT_NAME:?installer must pin SHIMPZ_PROJECT_NAME}-app-egress-proxy-1" in SCRIPT,
        "the generated Compose project and controller proxy target stay inside the selected profile",
    )
    check("image: ${SHIMPZ_ADMIN_IMAGE:?" in SCRIPT, "Compose fails closed without the pinned Admin reference")
    check(
        "image: ${SHIMPZ_CONTROLLER_IMAGE:?" in SCRIPT,
        "Compose fails closed without the pinned controller reference",
    )
    check(
        "image: ${SHIMPZ_BRAIN_RUNTIME_IMAGE:?" in SCRIPT,
        "Compose fails closed without the pinned Brain runtime reference",
    )
    check(
        "image: ${SHIMPZ_APP_EGRESS_IMAGE:?" in SCRIPT,
        "Compose fails closed without the pinned Assistant egress reference",
    )
    check(
        "platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}" in SCRIPT,
        "Compose fails closed without the pinned platform",
    )
    check("pull_policy: never" in SCRIPT and "--pull never" in SCRIPT, "Compose cannot silently replace the digest")
    check(
        'install_port="${SHIMPZ_PORT:-7777}"' in SCRIPT
        and "unset SHIMPZ_ADMIN_IMAGE SHIMPZ_CONTROLLER_IMAGE SHIMPZ_BRAIN_RUNTIME_IMAGE SHIMPZ_APP_EGRESS_IMAGE"
        in SCRIPT
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


def test_static_runtime_separates_socketless_admin_from_local_controller():
    compose = SCRIPT.split("cat >\"${COMPOSE_FILE}.tmp\" <<'COMPOSE'", 1)[1].split("\nCOMPOSE", 1)[0]
    controller = compose.split("  team-driver-local:", 1)[1].split("\n  app-egress-proxy:", 1)[0]
    app_egress = compose.split("\n  app-egress-proxy:\n", 1)[1].split("\n  oauth-broker-proxy:\n", 1)[0]
    oauth_broker = compose.split("\n  oauth-broker-proxy:\n", 1)[1].split("\n  brain-runtime:\n", 1)[0]
    brain_runtime = compose.split("  brain-runtime:", 1)[1].split("\n  admin:", 1)[0]
    admin = compose.split("  admin:", 1)[1].split("\nvolumes:", 1)[0]
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
    for marker in (
        'user: "10001:10001"',
        '"${SHIMPZ_DOCKER_GID:?installer must bind the Docker socket group}"',
        "SHIMPZ_SPACE_ID: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}",
        "controller_token:/run/shimpz-local:rw",
        "controller_audit:/var/log/shimpz-local:rw",
        "controller_storage:/var/lib/shimpz-local/storage:rw",
        "controller_inference:/var/lib/shimpz-local/inference:rw",
        "controller_power_journal:/var/lib/shimpz-local/power-journal:rw",
        "controller_approval_state:/var/lib/shimpz-local/assistant-approvals:rw",
        "controller_assistant_secret_state:/var/lib/shimpz-local/assistant-secrets/state:rw",
        "controller_assistant_secret_key:/var/lib/shimpz-local/assistant-secrets/key:rw",
        "controller_assistant_account_state:/var/lib/shimpz-local/assistant-accounts/state:rw",
        "controller_assistant_account_key:/var/lib/shimpz-local/assistant-accounts/key:rw",
        "controller_chat_continuation_state:/var/lib/shimpz-local/chat-continuations/state:rw",
        "controller_chat_continuation_key:/var/lib/shimpz-local/chat-continuations/key:rw",
        "app_egress_policy:/var/lib/shimpz-local/app-egress:rw",
        "brain_runtime_token:/run/shimpz-brain-runtime:rw",
        "SHIMPZ_LOCAL_POWER_JOURNAL_PATH: /var/lib/shimpz-local/power-journal/journal.sqlite3",
        "SHIMPZ_LOCAL_APPROVAL_GRANTS_PATH: /var/lib/shimpz-local/assistant-approvals/grants.sqlite3",
        "SHIMPZ_LOCAL_CHAT_CONTINUATIONS_STATE_PATH: "
        "/var/lib/shimpz-local/chat-continuations/state/continuations.json",
        "SHIMPZ_LOCAL_CHAT_CONTINUATIONS_KEY_PATH: /var/lib/shimpz-local/chat-continuations/key/aes256.key",
        "SHIMPZ_BRAIN_RUNTIME_URL: http://brain-runtime:8080",
        "SHIMPZ_BRAIN_RUNTIME_TOKEN_FILE: /run/shimpz-brain-runtime/token",
        "SHIMPZ_OAUTH_CALLBACK_MODE: ${SHIMPZ_OAUTH_CALLBACK_MODE:?installer must pin the OAuth callback mode}",
        "SHIMPZ_OAUTH_BROKER_PROXY_HOST: oauth-broker-proxy",
        "SHIMPZ_OAUTH_BROKER_PROXY_TOKEN: "
        "${SHIMPZ_OAUTH_BROKER_PROXY_TOKEN:?installer must bind the OAuth broker proxy capability}",
        "SHIMPZ_APP_EGRESS_PROXY_CONTAINER: "
        "${SHIMPZ_PROJECT_NAME:?installer must pin SHIMPZ_PROJECT_NAME}-app-egress-proxy-1",
        "SHIMPZ_APP_EGRESS_POLICY_DIR: /var/lib/shimpz-local/app-egress",
        '- "10016"',
        '- "10017"',
        'cpus: "1.0"',
        "mem_limit: 256m",
        "memswap_limit: 256m",
        "pids_limit: 128",
    ):
        check(marker in controller, f"local controller enforces {marker!r}")
    for marker in (
        "${SHIMPZ_BRAIN_RUNTIME_IMAGE:?installer must pin SHIMPZ_BRAIN_RUNTIME_IMAGE}",
        'user: "10001:10001"',
        '- "10016"',
        "read_only: true",
        "cap_drop:\n      - ALL",
        "no-new-privileges:true",
        'LANGCHAIN_TRACING_V2: "false"',
        'LANGSMITH_TRACING: "false"',
        "brain_runtime_token:/run/shimpz-brain-runtime:ro",
        "brain_runtime_state:/var/lib/shimpz-brain-runtime:rw",
        "SHIMPZ_BRAIN_RUNTIME_STATE: /var/lib/shimpz-brain-runtime/checkpoints.sqlite3",
        "/tmp:rw,noexec,nosuid,nodev,size=64m",
        'cpus: "2.0"',
        "mem_limit: 1g",
        "memswap_limit: 1g",
        "pids_limit: 128",
        "condition: service_healthy",
        "- brain_runtime\n      - brain_egress",
    ):
        check(marker in brain_runtime, f"isolated Brain runtime enforces {marker!r}")
    check("docker.sock" not in brain_runtime, "Brain runtime never receives the Docker socket")
    check("controller_token" not in brain_runtime, "Brain runtime never receives the Admin/Controller bearer")
    check("controller_inference" not in brain_runtime, "Brain runtime never mounts Team metadata")
    check("controller_power_journal" not in brain_runtime, "Brain runtime never mounts Power execution state")
    check("controller_approval_state" not in brain_runtime, "Brain runtime never mounts remembered approvals")
    check(
        "controller_assistant_secret_" not in brain_runtime,
        "Brain runtime never mounts encrypted Assistant secret state or its key",
    )
    check(
        "controller_assistant_account_" not in brain_runtime,
        "Brain runtime never mounts encrypted Assistant OAuth state or its key",
    )
    check(
        "controller_chat_continuation_" not in brain_runtime,
        "Brain runtime never mounts encrypted chat continuations or their key",
    )
    for marker in (
        'group_add:\n      - "10010"',
        "SHIMPZ_TEAMDRIVER_URL: http://team-driver-local:7077",
        "SHIMPZ_TEAMDRIVER_TOKEN_FILE: /run/shimpz-local/token",
        'SHIMPZ_TEAM_CREDENTIALS_ENABLED: "0"',
        "controller_token:/run/shimpz-local:ro",
        "condition: service_healthy",
    ):
        check(marker in admin, f"Admin consumes the controller boundary via {marker!r}")
    check("control:\n    driver: bridge\n    internal: true" in compose, "the control network is internal")
    check(
        "brain_runtime:\n    driver: bridge\n    internal: true" in compose,
        "the Controller-to-Brain network is internal",
    )
    check("brain_egress:\n    driver: bridge" in compose, "Brain egress uses a dedicated outbound network")
    check("- control\n      - egress" in admin, "Admin alone bridges control to egress")
    check("- egress" not in controller, "controller has no egress network")
    check("brain_runtime" not in admin and "brain_egress" not in admin, "Admin cannot join either Brain network")
    check("brain_egress" not in controller, "Controller cannot reach provider egress")
    check("- oauth_broker" in controller, "Controller reaches only the internal OAuth broker proxy plane")
    check("- oauth_broker_out" not in controller, "Controller cannot bypass the OAuth broker proxy")
    check("controller_storage" not in admin, "Admin never mounts opaque Team storage")
    check("controller_power_journal" not in admin, "Admin never mounts Power execution state")
    check("controller_approval_state" not in admin, "Admin never mounts remembered approvals")
    check(
        "controller_assistant_secret_" not in admin,
        "Admin never mounts encrypted Assistant secret state or its key",
    )
    check(
        "controller_assistant_account_" not in admin,
        "Admin never mounts encrypted Assistant OAuth state or its key",
    )
    check(
        "controller_chat_continuation_" not in admin,
        "Admin never mounts encrypted chat continuations or their key",
    )
    check(SCRIPT.count("  controller_power_journal:") == 1, "Compose declares exactly one Power journal volume")
    check(
        SCRIPT.count("  controller_approval_state:") == 1,
        "Compose declares exactly one remembered-approval volume",
    )
    check(
        SCRIPT.count("  controller_assistant_secret_state:") == 1,
        "Compose declares exactly one encrypted Assistant secret-state volume",
    )
    check(
        SCRIPT.count("  controller_assistant_secret_key:") == 1,
        "Compose declares exactly one independent Assistant secret-key volume",
    )
    check(
        SCRIPT.count("  controller_assistant_account_state:") == 1,
        "Compose declares exactly one encrypted Assistant OAuth-state volume",
    )
    check(
        SCRIPT.count("  controller_assistant_account_key:") == 1,
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
    check("SHIMPZ_CLOUDFLARE_OAUTH_CLIENT" not in SCRIPT, "installer contains no OAuth client credentials")
    check("SHIMPZ_X_OAUTH_CLIENT_ID" not in SCRIPT, "installer contains no retired X OAuth configuration")
    check("postgres" not in SCRIPT, "bootstrap does not claim an unshipped PostgreSQL dependency")
    check("at least 12 characters" in SCRIPT, "success output states the real initial password minimum")

    for marker in (
        "${SHIMPZ_APP_EGRESS_IMAGE:?installer must pin SHIMPZ_APP_EGRESS_IMAGE}",
        'user: "10005:10005"',
        '- "10017"',
        "read_only: true",
        "cap_drop:\n      - ALL",
        "no-new-privileges:true",
        'com.shimpz.local.managed: "1"',
        "com.shimpz.local.profile: single-owner-local-v1",
        "com.shimpz.local.space-id: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}",
        "com.shimpz.local.kind: app-egress-proxy",
        'SHIMPZ_APP_EGRESS_PORT: "8889"',
        "SHIMPZ_APP_EGRESS_POLICY_DIR: /policy",
        "app_egress_policy:/policy:ro",
        "app_egress_audit:/var/log/app-egress-proxy:rw",
        "/tmp:rw,noexec,nosuid,nodev,size=16m",
        '["CMD", "python3", "/app/healthcheck.py"]',
        'cpus: "1.0"',
        "mem_limit: 256m",
        "memswap_limit: 256m",
        "pids_limit: 128",
        "- app_egress_out",
    ):
        check(marker in app_egress, f"Assistant egress proxy enforces {marker!r}")
    check("docker.sock" not in app_egress, "Assistant egress proxy never receives the Docker socket")
    check("controller_token" not in app_egress, "Assistant egress proxy never receives the controller bearer")
    check("brain_runtime" not in app_egress, "Assistant egress proxy cannot enter the Brain plane")
    check("- control" not in app_egress and "- egress" not in app_egress, "proxy starts only on its outbound plane")
    check("app_egress_out:\n    driver: bridge" in compose, "Assistant egress uses a dedicated outbound network")

    for marker in (
        "${SHIMPZ_APP_EGRESS_IMAGE:?installer must pin SHIMPZ_APP_EGRESS_IMAGE}",
        'user: "10005:10005"',
        "com.shimpz.local.kind: oauth-broker-proxy",
        'SHIMPZ_APP_EGRESS_PORT: "8889"',
        "SHIMPZ_APP_EGRESS_POLICY_DIR: /policy",
        "${SHIMPZ_OAUTH_BROKER_POLICY_DIR:?installer must bind the OAuth broker policy}:/policy:ro",
        "oauth_broker_egress_audit:/var/log/app-egress-proxy:rw",
        'SHIMPZ_APP_EGRESS_MAX_CONCURRENCY: "8"',
        'SHIMPZ_APP_EGRESS_MAX_SOURCE_CONCURRENCY: "2"',
        'SHIMPZ_APP_EGRESS_LISTEN_BACKLOG: "4"',
        "- oauth_broker\n      - oauth_broker_out",
        'cpus: "0.5"',
        "mem_limit: 128m",
        "pids_limit: 64",
    ):
        check(marker in oauth_broker, f"OAuth broker proxy enforces {marker!r}")
    check("docker.sock" not in oauth_broker, "OAuth broker proxy never receives the Docker socket")
    check("controller_token" not in oauth_broker, "OAuth broker proxy never receives the controller bearer")
    check("brain_runtime" not in oauth_broker, "OAuth broker proxy cannot enter the Brain plane")
    check("control" not in oauth_broker, "OAuth broker proxy cannot enter the controller API plane")
    check(
        "oauth_broker:\n    driver: bridge\n    internal: true" in compose,
        "OAuth broker ingress is internal",
    )
    check("oauth_broker_out:\n    driver: bridge" in compose, "OAuth broker egress has one outbound plane")
    for marker in (
        "generated_oauth_broker_proxy_token",
        "oauth_broker_proxy_token_from_env_file",
        "SHIMPZ_OAUTH_BROKER_PROXY_TOKEN=${oauth_broker_proxy_token}",
        "printf '[\"shimpz.com\"]\\n'",
    ):
        check(marker in SCRIPT, f"installer owns the fixed OAuth broker capability via {marker!r}")


def test_reset_accepts_only_the_exact_space_owned_egress_proxy():
    space_id = "space-111111111111111111111111"
    valid = "|".join(
        (
            "/shimpz-space-app-egress-proxy-1",
            "1",
            "single-owner-local-v1",
            space_id,
            "app-egress-proxy",
            "",
            "",
        )
    )
    accepted = _run_dynamic_validator(valid)
    check(accepted.returncode == 0, f"the exact Compose egress proxy is accepted: {accepted.stderr.strip()}")
    for label, invalid in (
        ("name", valid.replace("/shimpz-space-app-egress-proxy-1", "/shimpz-space-foreign-1")),
        ("profile", valid.replace("single-owner-local-v1", "foreign-profile")),
        ("Space", valid.replace(space_id, "space-222222222222222222222222")),
        ("kind", valid.replace("app-egress-proxy", "assistant-proxy")),
    ):
        rejected = _run_dynamic_validator(invalid)
        check(rejected.returncode != 0, f"an egress proxy with a foreign {label} fails closed")

    oauth = valid.replace("app-egress-proxy", "oauth-broker-proxy")
    accepted_oauth = _run_dynamic_validator(oauth)
    check(
        accepted_oauth.returncode == 0,
        f"the exact Compose OAuth broker proxy is accepted: {accepted_oauth.stderr.strip()}",
    )


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
        SCRIPT.index('controller_image_ref="$(pull_verified_ref "$controller_tag_ref")"')
        < SCRIPT.index(
            'candidate_gid="$(docker_socket_source="$socket_candidate" controller_socket_gid "$controller_image_ref"'
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
    check('MARKER_VALUE="shimpz-space-managed-v1"' in SCRIPT, "installer owns its state with an exact marker")
    check("refusing reset" in SCRIPT and "invalid install marker" in SCRIPT, "reset fails closed on foreign state")
    check("rm -rf" not in SCRIPT, "reset never recursively deletes a user-controlled path")
    check("down --volumes --remove-orphans" in SCRIPT, "reset removes only the managed Compose resources")
    check(
        'step "Removing verified rollback leftovers"' in SCRIPT,
        "reset revalidates and removes volumes left by a rolled-back newer Compose contract",
    )
    check(SCRIPT.count(".previous") >= 8, "update preserves and restores the prior Compose release")
    check("rollback also failed" in SCRIPT, "a failed rollback is surfaced rather than hidden")
    startup = "compose up -d --wait --wait-timeout 120 --no-build --pull never --remove-orphans"
    check(
        SCRIPT.count(startup) == 2,
        "candidate and rollback startup remove containers retired by the managed Compose release",
    )
    for marker in (
        "optional_env_value",
        "load_previous_release",
        "SHIMPZ_SPACE_IMAGE",
        "SHIMPZ_BRAIN_RUNTIME_IMAGE",
        "previous_brain_runtime_ref",
        "SHIMPZ_APP_EGRESS_IMAGE",
        "previous_app_egress_ref",
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
        failed_candidate.index("compose logs --no-color --tail 20 team-driver-local")
        < failed_candidate.index("compose logs --no-color --tail 20 app-egress-proxy")
        < failed_candidate.index("compose logs --no-color --tail 20 brain-runtime")
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
    for marker in (
        "an earlier Shimpz installation still has Docker data",
        "validate_project_resources",
        '"/${PROJECT_NAME}-admin-1|admin"',
        '"/${PROJECT_NAME}-team-driver-local-1|team-driver-local"',
        '"/${PROJECT_NAME}-brain-runtime-1|brain-runtime"',
        '"/${PROJECT_NAME}-app-egress-proxy-1|app-egress-proxy"',
        '"${PROJECT_NAME}_config|config"',
        '"${PROJECT_NAME}_data|data"',
        '"${PROJECT_NAME}_controller_token|controller_token"',
        '"${PROJECT_NAME}_controller_audit|controller_audit"',
        '"${PROJECT_NAME}_controller_storage|controller_storage"',
        '"${PROJECT_NAME}_controller_inference|controller_inference"',
        '"${PROJECT_NAME}_controller_power_journal|controller_power_journal"',
        '"${PROJECT_NAME}_controller_approval_state|controller_approval_state"',
        '"${PROJECT_NAME}_controller_assistant_secret_state|controller_assistant_secret_state"',
        '"${PROJECT_NAME}_controller_assistant_secret_key|controller_assistant_secret_key"',
        '"${PROJECT_NAME}_controller_assistant_account_state|controller_assistant_account_state"',
        '"${PROJECT_NAME}_controller_assistant_account_key|controller_assistant_account_key"',
        '"${PROJECT_NAME}_controller_chat_continuation_state|controller_chat_continuation_state"',
        '"${PROJECT_NAME}_controller_chat_continuation_key|controller_chat_continuation_key"',
        '"${PROJECT_NAME}_brain_runtime_token|brain_runtime_token"',
        '"${PROJECT_NAME}_brain_runtime_state|brain_runtime_state"',
        '"${PROJECT_NAME}_app_egress_policy|app_egress_policy"',
        '"${PROJECT_NAME}_app_egress_audit|app_egress_audit"',
        '"${PROJECT_NAME}_egress|egress"',
        '"${PROJECT_NAME}_control|control"',
        '"${PROJECT_NAME}_brain_runtime|brain_runtime"',
        '"${PROJECT_NAME}_brain_egress|brain_egress"',
        '"${PROJECT_NAME}_app_egress_out|app_egress_out"',
        "official_image_digest",
        "validate_dynamic_resources",
        'docker exec "$controller_id" /opt/venv/bin/python',
        'connection.request("DELETE","/v1/space"',
        'document.get("reset") is True',
        "the authenticated Team reset did not complete",
        "a Space-labeled container has invalid ownership labels",
        "invalid managed Assistant egress proxy name",
        "dynamic_assistant_container_ids",
        "a Space-labeled network has invalid ownership labels",
        "reset left unexpected Shimpz Space Docker resources",
    ):
        check(marker in SCRIPT, f"orphan recovery remains bounded by {marker!r}")
    reset_branch = SCRIPT.split('if [ "$action" = "reset" ]; then', 1)[1].split('\nhost_os="$(uname -s)"', 1)[0]
    check(
        reset_branch.index("reset_dynamic_space") < reset_branch.index("compose down --volumes --remove-orphans"),
        "authenticated dynamic reset runs before Compose data removal",
    )


def test_owned_prior_controller_transition_is_exact_and_fail_closed():
    old_service = "cap" + "sule-driver-local"
    prior_image = f"{IMAGE_REPOSITORY_FOR_TESTS}@sha256:{'a' * 64}"
    other_image = f"{IMAGE_REPOSITORY_FOR_TESTS}@sha256:{'b' * 64}"
    space_id = f"space-{'1' * 24}"
    prior_record = f"/shimpz-space-{old_service}-1|{old_service}|{prior_image}"
    current_record = f"/shimpz-space-team-driver-local-1|team-driver-local|{other_image}"

    accepted = _run_project_validator(
        [f"prior|{prior_record}"],
        prior_image=prior_image,
        controller_environments={"prior": f"SHIMPZ_SPACE_ID={space_id}"},
    )
    check(accepted.returncode == 0, f"the exact owned prior controller is accepted: {accepted.stderr.strip()}")
    check(
        accepted.stdout.strip() == f"prior|{space_id}|1|1",
        "the prior controller records its identity and transition state",
    )

    legacy_image = f"{PRIOR_IMAGE_REPOSITORY_FOR_TESTS}@sha256:{'c' * 64}"
    legacy_prior_record = f"/shimpz-space-{old_service}-1|{old_service}|{legacy_image}"
    accepted_legacy = _run_project_validator(
        [f"prior|{legacy_prior_record}"],
        prior_image=legacy_image,
        controller_environments={"prior": f"SHIMPZ_SPACE_ID={space_id}"},
    )
    check(
        accepted_legacy.returncode == 0 and accepted_legacy.stdout.strip() == f"prior|{space_id}|1|1",
        f"the exact digest-pinned legacy registry is accepted for migration: {accepted_legacy.stderr.strip()}",
    )

    legacy_current_record = f"/shimpz-space-team-driver-local-1|team-driver-local|{legacy_image}"
    accepted_legacy_current = _run_project_validator(
        [f"current|{legacy_current_record}"],
        prior_image=legacy_image,
        controller_environments={"current": f"SHIMPZ_SPACE_ID={space_id}"},
    )
    check(
        accepted_legacy_current.returncode == 0 and accepted_legacy_current.stdout.strip() == f"current|{space_id}|1|0",
        "a current controller pinned to the retired official registry remains updatable",
    )

    lookalike_legacy = _run_project_validator(
        [f"prior|{legacy_prior_record}"],
        prior_image=f"ghcr.io/roxygens-evil/shimpz-space@sha256:{'c' * 64}",
        controller_environments={"prior": f"SHIMPZ_SPACE_ID={space_id}"},
    )
    check(lookalike_legacy.returncode != 0, "a lookalike legacy registry remains rejected")

    digest_mismatch = _run_project_validator(
        [f"prior|/shimpz-space-{old_service}-1|{old_service}|{other_image}"],
        prior_image=prior_image,
        controller_environments={"prior": f"SHIMPZ_SPACE_ID={space_id}"},
    )
    check(digest_mismatch.returncode != 0, "a prior service with a different digest fails closed")

    ambiguous_owned_digest = _run_project_validator(
        [f"prior|{prior_record}"],
        prior_image=f"{prior_image}\nSHIMPZ_CONTROLLER_IMAGE={other_image}",
        controller_environments={"prior": f"SHIMPZ_SPACE_ID={space_id}"},
    )
    check(ambiguous_owned_digest.returncode != 0, "ambiguous owned controller digests fail closed")

    name_mismatch = _run_project_validator(
        [f"prior|/shimpz-space-not-the-service-1|{old_service}|{prior_image}"],
        prior_image=prior_image,
        controller_environments={"prior": f"SHIMPZ_SPACE_ID={space_id}"},
    )
    check(name_mismatch.returncode != 0, "a prior service whose Compose name does not match fails closed")

    service_mismatch = _run_project_validator(
        [f"prior|/shimpz-space-{old_service}-1|not-the-service|{prior_image}"],
        prior_image=prior_image,
        controller_environments={"prior": f"SHIMPZ_SPACE_ID={space_id}"},
    )
    check(service_mismatch.returncode != 0, "a prior container whose Compose service does not match fails closed")

    duplicate_transition = _run_project_validator(
        [f"current|{current_record}", f"prior|{prior_record}"],
        prior_image=prior_image,
        controller_environments={
            "current": f"SHIMPZ_SPACE_ID={space_id}",
            "prior": f"SHIMPZ_SPACE_ID={space_id}",
        },
    )
    check(duplicate_transition.returncode != 0, "current and prior controllers cannot coexist")

    duplicate_prior = _run_project_validator(
        [f"prior|{prior_record}", f"prior_two|{prior_record}"],
        prior_image=prior_image,
        controller_environments={
            "prior": f"SHIMPZ_SPACE_ID={space_id}",
            "prior_two": f"SHIMPZ_SPACE_ID={space_id}",
        },
    )
    check(duplicate_prior.returncode != 0, "multiple prior controllers cannot be authenticated as one runtime")

    foreign = _run_project_validator(
        [f"foreign|/shimpz-space-foreign-1|foreign|{other_image}"],
        prior_image=prior_image,
    )
    check(foreign.returncode != 0, "a foreign Compose container remains rejected")

    same_digest_foreign = _run_project_validator(
        [f"foreign|/shimpz-space-evil-1|evil|{prior_image}"],
        prior_image=prior_image,
    )
    check(same_digest_foreign.returncode != 0, "the prior digest cannot authenticate a different service")


def test_static_owned_prior_controller_reset_preserves_admin_volumes():
    for marker in (
        "controller_image_from_env_file",
        "prior_controller_image_ref",
        "prior_controller_seen",
        "record_controller_identity",
        "accept_prior_controller",
        "prior_runtime_transition",
    ):
        check(marker in SCRIPT, f"the prior-controller migration retains {marker!r}")

    reader = _shell_functions("controller_image_from_env_file", "record_controller_identity")
    check("sed -n 's/^SHIMPZ_CONTROLLER_IMAGE=//p' \"$ENV_FILE\"" in reader, "the owned env supplies the prior digest")
    check("wc -l" in reader, "ambiguous prior controller image entries fail closed")
    check(
        'official_image_digest "$controller_image_lines"' in reader,
        "the owned prior reference must pass the shared exact official SHA-256 allowlist",
    )

    validator = _shell_functions("accept_prior_controller", "dynamic_container_ids")
    check(
        '"$container_service" = "$PRIOR_CONTROLLER_SERVICE"' in validator
        and '"$container_name" = "/${PROJECT_NAME}-${PRIOR_CONTROLLER_SERVICE}-1"' in validator,
        "a prior controller must have the one exact retired service and Compose name",
    )
    check(
        '"$container_image" = "$prior_controller_image_ref"' in validator,
        "a prior service must use the exact digest from owned state",
    )

    reset_start = SCRIPT.index('if [ "$action" = "reset" ]; then')
    reset_branch = SCRIPT[reset_start:].split('\nhost_os="$(uname -s)"', 1)[0]
    loader_start = SCRIPT.index('prior_controller_image_ref=""')
    loader = SCRIPT[loader_start:reset_start]
    check(
        'prior_controller_image_value="$(controller_image_from_env_file)"' in loader
        and '"$prior_controller_image_status" -eq 1' in loader,
        "missing prior controller state is allowed while malformed or ambiguous state is rejected",
    )
    check(
        loader_start
        < reset_start + reset_branch.index("validate_project_resources")
        < reset_start + reset_branch.index("prior_controller_seen")
        < reset_start + reset_branch.index("reset_dynamic_space")
        < reset_start + reset_branch.index("compose down --volumes --remove-orphans"),
        "reset authenticates and drains a prior controller before persistent data removal",
    )

    update_validation = SCRIPT.split(
        'if project_resources_exist; then\n\tstep "Validating the existing managed runtime"', 1
    )[1].split("\numask 077", 1)[0]
    check(
        "prior_controller_seen" in update_validation and "validate_dynamic_resources" in update_validation,
        "update distinguishes prior and current controller validation",
    )
    check(
        update_validation.index("prior_controller_seen") < update_validation.index("validate_dynamic_resources"),
        "the prior-controller decision is made before current dynamic-label validation",
    )

    update_branch = SCRIPT.split("had_previous=0", 1)[1]
    startup = "compose up -d --wait --wait-timeout 120 --no-build --pull never --remove-orphans"
    check(
        update_branch.index("hydrate_previous_release")
        < update_branch.index("prior_runtime_transition")
        < update_branch.index("reset_dynamic_space")
        < update_branch.index(startup),
        "owned prior images are hydrated and dynamically reset before candidate startup",
    )
    check("compose down --volumes" not in update_branch, "an update never removes persistent Compose volumes")
    check("docker volume rm" not in update_branch, "an update preserves Admin configuration and data volumes")


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
