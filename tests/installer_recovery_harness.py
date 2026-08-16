"""PTY and Docker fakes for the shipped corrupt-install recovery flow."""

from __future__ import annotations

import errno
import os
import pty
import tempfile
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class RecoveryRun:
    returncode: int
    output: str
    docker_calls: tuple[str, ...]
    scheduler_removed: bool
    remaining_resources: tuple[str, ...]
    installer_files_remain: bool


def _fake_docker_source() -> str:
    return r"""#!/bin/sh
state="$FAKE_STATE"
calls="$FAKE_DOCKER_CALLS"
managed_filter="label=com.shimpz.local.managed=1"
profile_filter="label=com.shimpz.local.profile=local-v1"
space_filter="label=com.shimpz.local.space-id=space-111111111111111111111111"
list_present() {
    for resource_name in "$@"; do
        [ ! -e "$state/$resource_name" ] || printf '%s\n' "$resource_name"
    done
}
last_argument=""
for argument in "$@"; do
    last_argument="$argument"
done
case "$*" in
    "ps --all --quiet --filter label=com.docker.compose.project=shimpz-space")
        list_present shimpz-team project-admin project-proxy
        ;;
    "volume ls --quiet --filter label=com.docker.compose.project=shimpz-space")
        list_present project-volume
        ;;
    "network ls --quiet --filter label=com.docker.compose.project=shimpz-space")
        list_present project-network
        ;;
    *"ps --all --quiet"*"$managed_filter"*"$profile_filter"*"$space_filter"*)
        list_present project-proxy dynamic-assistant
        ;;
    *"network ls --quiet"*"$managed_filter"*"$profile_filter"*"$space_filter"*)
        list_present dynamic-network
        ;;
    *"ps --all --quiet"*"label=com.shimpz.local.space-id=space-111111111111111111111111"*)
        list_present project-proxy dynamic-assistant
        ;;
    *"network ls --quiet"*"label=com.shimpz.local.space-id=space-111111111111111111111111"*)
        list_present dynamic-network
        ;;
    *"ps --all --quiet"*"label=com.shimpz.local.managed=1"*"label=com.shimpz.local.profile=local-v1"*)
        [ "$FAKE_OUT_OF_PROJECT" != "1" ] || list_present dynamic-assistant
        ;;
    *"network ls --quiet"*"label=com.shimpz.local.managed=1"*"label=com.shimpz.local.profile=local-v1"*)
        [ "$FAKE_OUT_OF_PROJECT" != "1" ] || list_present dynamic-network
        ;;
    *"inspect --type=container"*"range .Config.Env"*"shimpz-team")
        [ "$FAKE_HAS_CONTROLLER" = "1" ] || exit 1
        printf 'SHIMPZ_SPACE_ID=space-111111111111111111111111\n'
        ;;
    *"inspect --type=container"*"com.docker.compose.project"*"shimpz-team")
        [ "$FAKE_HAS_CONTROLLER" = "1" ] || exit 1
        printf 'shimpz-space\n'
        ;;
    *"inspect --type=container"*"com.shimpz.local.managed"*)
        printf '1|local-v1|space-111111111111111111111111\n'
        ;;
    *"network inspect"*"com.shimpz.local.managed"*)
        printf '1|local-v1|space-111111111111111111111111\n'
        ;;
    *"inspect --type=container"*"com.docker.compose.project"*)
        [ "$FAKE_OUT_OF_PROJECT" != "1" ] || printf '\n'
        [ "$FAKE_OUT_OF_PROJECT" = "1" ] || printf 'shimpz-space\n'
        ;;
    *"network inspect"*"com.docker.compose.project"*)
        [ "$FAKE_OUT_OF_PROJECT" != "1" ] || printf '\n'
        [ "$FAKE_OUT_OF_PROJECT" = "1" ] || printf 'shimpz-space\n'
        ;;
    *"inspect --type=container"*"{{.Name}}"*)
        printf '/%s\n' "$last_argument"
        ;;
    "rm --force "*)
        printf 'container:%s\n' "$last_argument" >>"$calls"
        rm -f "$state/$last_argument"
        ;;
    "network rm "*)
        printf 'network:%s\n' "$last_argument" >>"$calls"
        rm -f "$state/$last_argument"
        ;;
    "volume rm "*)
        printf 'volume:%s\n' "$last_argument" >>"$calls"
        rm -f "$state/$last_argument"
        ;;
    *)
        printf 'unexpected docker call: %s\n' "$*" >&2
        exit 72
        ;;
esac
"""


def _harness_source(functions: str) -> str:
    return (
        """#!/bin/sh
set -eu
PROJECT_NAME="shimpz-space"
LOCAL_PROFILE="local-v1"
SPACE_LABEL="com.shimpz.local.space-id"
SHIMPZ_HOME="$HOME/.shimpz"
COMPOSE_FILE="$SHIMPZ_HOME/compose.yaml"
ENV_FILE="$SHIMPZ_HOME/.env"
MARKER_FILE="$SHIMPZ_HOME/.shimpz-space"
RECONCILER_FILE="$SHIMPZ_HOME/reconcile.sh"
RECONCILER_CANDIDATE="$SHIMPZ_HOME/reconcile.candidate"
RECONCILER_PREVIOUS="$SHIMPZ_HOME/reconcile.previous"
STATUS_FILE="$SHIMPZ_HOME/release-status.json"
FAILED_RELEASE_FILE="$SHIMPZ_HOME/failed-release.env"
action="install"
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
notice() { printf 'NOTICE: %s\n' "$*" >&2; }
info() { printf 'INFO: %s\n' "$*" >&2; }
validate_scheduler_ownership() { :; }
remove_scheduler() { printf 'removed\n' >"$FAKE_SCHEDULER_CALLS"; }
generated_space_id() { printf 'space-222222222222222222222222\n'; }
project_container_ids() { docker ps --all --quiet --filter "label=com.docker.compose.project=${PROJECT_NAME}"; }
project_volume_ids() { docker volume ls --quiet --filter "label=com.docker.compose.project=${PROJECT_NAME}"; }
project_network_ids() { docker network ls --quiet --filter "label=com.docker.compose.project=${PROJECT_NAME}"; }
project_resources_exist() {
    container_ids="$(project_container_ids)" || die "container inspection failed"
    volume_ids="$(project_volume_ids)" || die "volume inspection failed"
    network_ids="$(project_network_ids)" || die "network inspection failed"
    [ -n "${container_ids}${volume_ids}${network_ids}" ]
}
"""
        + functions
        + """
offer_corrupt_reinstall "managed runtime is invalid: test corruption"
printf 'FRESH:%s:%s\n' "$install_mode" "$space_id"
"""
    )


def _read_pty(master_fd: int) -> bytes:
    chunks: list[bytes] = []
    while True:
        try:
            chunk = os.read(master_fd, 4096)
        except OSError as error:
            if error.errno == errno.EIO:
                break
            raise
        if not chunk:
            break
        chunks.append(chunk)
    return b"".join(chunks)


def _run_with_terminal(shell: Path, environment: dict[str, str], answer: str) -> tuple[int, str]:
    output_chunks: list[bytes] = []
    pending_input = [f"{answer}\n".encode()]

    def read_output(master_fd: int) -> bytes:
        chunk = os.read(master_fd, 4096)
        output_chunks.append(chunk)
        return chunk

    def read_input(_stdin_fd: int) -> bytes:
        return pending_input.pop() if pending_input else b""

    original_environment = os.environ.copy()
    original_stdout = os.dup(1)
    quiet_stdout = os.open(os.devnull, os.O_WRONLY)
    try:
        os.environ.clear()
        os.environ.update(environment)
        os.dup2(quiet_stdout, 1)
        status = pty.spawn(["/bin/sh", str(shell)], read_output, read_input)
    finally:
        os.dup2(original_stdout, 1)
        os.close(original_stdout)
        os.close(quiet_stdout)
        os.environ.clear()
        os.environ.update(original_environment)
    return os.waitstatus_to_exitcode(status), b"".join(output_chunks).decode(errors="replace")


def _run_without_terminal(shell: Path, environment: dict[str, str]) -> tuple[int, str]:
    read_fd, write_fd = os.pipe()
    child_pid = os.fork()
    if child_pid == 0:
        os.setsid()
        os.close(read_fd)
        os.dup2(write_fd, 1)
        os.dup2(write_fd, 2)
        os.close(write_fd)
        spawned_pid = os.posix_spawn("/bin/sh", ["/bin/sh", str(shell)], environment)
        _, spawned_status = os.waitpid(spawned_pid, 0)
        os._exit(os.waitstatus_to_exitcode(spawned_status))
    os.close(write_fd)
    output = _read_pty(read_fd).decode(errors="replace")
    os.close(read_fd)
    _, status = os.waitpid(child_pid, 0)
    return os.waitstatus_to_exitcode(status), output


def run_recovery(
    functions: str,
    *,
    answer: str = "No",
    terminal: bool = True,
    owned_identity: bool = True,
    out_of_project: bool = False,
) -> RecoveryRun:
    with tempfile.TemporaryDirectory() as raw_home:
        home = Path(raw_home)
        state = home / "state"
        state.mkdir()
        resources = (
            "shimpz-team",
            "project-admin",
            "project-proxy",
            "dynamic-assistant",
            "project-volume",
            "project-network",
            "dynamic-network",
        )
        for resource in resources:
            (state / resource).touch()
        shimpz_home = home / ".shimpz"
        shimpz_home.mkdir()
        for filename in (
            "compose.yaml",
            ".shimpz-space",
            "reconcile.sh",
            "release.env.tmp",
            "reconcile.candidate.tmp",
            "reconcile.previous.tmp",
        ):
            (shimpz_home / filename).touch()
        if owned_identity:
            (shimpz_home / ".env").write_text(
                "SHIMPZ_SPACE_ID=space-111111111111111111111111\n",
                encoding="utf-8",
            )
        binary_dir = home / "bin"
        binary_dir.mkdir()
        docker = binary_dir / "docker"
        docker.write_text(_fake_docker_source(), encoding="utf-8")
        docker.chmod(0o700)
        shell = home / "recovery.sh"
        shell.write_text(_harness_source(functions), encoding="utf-8")
        shell.chmod(0o700)
        docker_calls = home / "docker.calls"
        scheduler_calls = home / "scheduler.calls"
        environment = {
            "HOME": str(home),
            "PATH": f"{binary_dir}:/usr/bin:/bin",
            "FAKE_STATE": str(state),
            "FAKE_DOCKER_CALLS": str(docker_calls),
            "FAKE_SCHEDULER_CALLS": str(scheduler_calls),
            "FAKE_HAS_CONTROLLER": "1" if owned_identity else "0",
            "FAKE_OUT_OF_PROJECT": "1" if out_of_project else "0",
        }
        if terminal:
            returncode, output = _run_with_terminal(shell, environment, answer)
        else:
            returncode, output = _run_without_terminal(shell, environment)
        calls = tuple(docker_calls.read_text(encoding="utf-8").splitlines()) if docker_calls.exists() else ()
        remaining = tuple(sorted(path.name for path in state.iterdir()))
        installer_files_remain = any(shimpz_home.iterdir())
        return RecoveryRun(
            returncode=returncode,
            output=output,
            docker_calls=calls,
            scheduler_removed=scheduler_calls.exists(),
            remaining_resources=remaining,
            installer_files_remain=installer_files_remain,
        )
