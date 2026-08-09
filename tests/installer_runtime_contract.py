"""Runtime-version and healthcheck contracts for the Local installer."""

from __future__ import annotations

import grp
import os
import re
import socket
import subprocess
import tempfile
from collections.abc import Callable
from pathlib import Path

Check = Callable[[object, str], None]


def _run_version_comparison(script: str, current: str, minimum: str) -> subprocess.CompletedProcess[str]:
    start = script.index("version_at_least() (")
    end = script.index("\n)\n\nstep()", start) + len("\n)")
    function = script[start:end]
    return subprocess.run(
        ["/bin/sh", "-c", f'{function}\nversion_at_least "$CURRENT" "$MINIMUM"'],
        check=False,
        capture_output=True,
        text=True,
        env={"CURRENT": current, "MINIMUM": minimum},
    )


def _run_version_preflight(
    script_path: Path,
    *,
    engine_version: str,
    api_version: str,
    compose_version: str,
) -> tuple[subprocess.CompletedProcess[str], bool]:
    with tempfile.TemporaryDirectory() as raw_home:
        home = Path(raw_home)
        binary_dir = home / "bin"
        binary_dir.mkdir()
        docker = binary_dir / "docker"
        docker.write_text(
            """#!/bin/sh
case "$*" in
  "compose version") exit 0 ;;
  "compose version --short") printf '%s\n' "$FAKE_COMPOSE_VERSION" ;;
  "context show") printf '%s\n' local ;;
  "context inspect --format {{.Endpoints.docker.Host}} local") printf '%s\n' unix:///var/run/docker.sock ;;
  "info") exit 0 ;;
  "version --format {{.Server.Version}}") printf '%s\n' "$FAKE_ENGINE_VERSION" ;;
  "version --format {{.Server.APIVersion}}") printf '%s\n' "$FAKE_API_VERSION" ;;
  *) exit 92 ;;
esac
""",
            encoding="utf-8",
        )
        docker.chmod(0o700)
        result = subprocess.run(
            ["/bin/sh", str(script_path)],
            check=False,
            capture_output=True,
            text=True,
            env={
                "HOME": str(home),
                "PATH": f"{binary_dir}:/usr/bin:/bin",
                "TERM": "dumb",
                "FAKE_ENGINE_VERSION": engine_version,
                "FAKE_API_VERSION": api_version,
                "FAKE_COMPOSE_VERSION": compose_version,
            },
        )
        return result, (home / ".shimpz").exists()


def assert_runtime_version_floor(script: str, script_path: Path, check: Check) -> None:
    for current, minimum in (
        ("25.0.0", "25.0.0"),
        ("29.6.2", "25.0.0"),
        ("1.44", "1.44"),
        ("v2.20.2", "2.20.2"),
        ("2.20.3-desktop.1", "2.20.2"),
    ):
        accepted = _run_version_comparison(script, current, minimum)
        check(accepted.returncode == 0, f"{current} satisfies {minimum}")
    for current, minimum in (
        ("24.0.9", "25.0.0"),
        ("1.43", "1.44"),
        ("2.20.1", "2.20.2"),
        ("unknown", "2.20.2"),
        ("2..21", "2.20.2"),
    ):
        rejected = _run_version_comparison(script, current, minimum)
        check(rejected.returncode != 0, f"{current} does not satisfy {minimum}")

    old_engine, old_engine_state_exists = _run_version_preflight(
        script_path,
        engine_version="24.0.9",
        api_version="1.43",
        compose_version="2.40.0",
    )
    check(old_engine.returncode != 0 and "Docker Engine 25.0 or newer" in old_engine.stderr, "old Engine fails early")
    check(not old_engine_state_exists, "an old Engine creates no installer state")

    old_compose, old_compose_state_exists = _run_version_preflight(
        script_path,
        engine_version="25.0.0",
        api_version="1.44",
        compose_version="2.20.1",
    )
    check(
        old_compose.returncode != 0 and "Docker Compose 2.20.2 or newer" in old_compose.stderr,
        "old Compose fails early",
    )
    check(not old_compose_state_exists, "an old Compose creates no installer state")

    docker_ready = script.index("if ! docker info >/dev/null 2>&1; then")
    engine_floor = script.index('version_at_least "$docker_server_version" "25.0.0"')
    api_floor = script.index('version_at_least "$docker_api_version" "1.44"')
    compose_floor = script.index('version_at_least "$compose_version" "2.20.2"')
    first_state_write = script.index('umask 077\nmkdir -p "$SHIMPZ_HOME"')
    check(
        docker_ready < engine_floor < api_floor < compose_floor < first_state_write,
        "all runtime version floors run after daemon access and before installer state is written",
    )


def assert_healthcheck_cadence(script: str, check: Check) -> None:
    compose = script.split("cat >\"${COMPOSE_FILE}.tmp\" <<'COMPOSE'", 1)[1].split("\nCOMPOSE", 1)[0]
    healthchecks = re.findall(r"^    healthcheck:\n((?:      .+\n)+)", compose, re.MULTILINE)
    check(len(healthchecks) == 5, "Local Compose owns exactly five explicit healthchecks")
    for healthcheck in healthchecks:
        check("      interval: 30s\n" in healthcheck, "steady-state healthchecks run every 30 seconds")
        check("      retries: 3\n" in healthcheck, "healthchecks tolerate three steady-state failures")
        check("      start_period: 30s\n" in healthcheck, "services receive a 30-second startup window")
        check("      start_interval: 1s\n" in healthcheck, "startup readiness remains responsive")
    check("      interval: 5s\n" not in compose and "      interval: 10s\n" not in compose, "no busy cadence remains")


def assert_stale_group_handoff(script_path: Path, check: Check) -> None:
    """Prove recovery performs one bounded, action-preserving group handoff."""
    with tempfile.TemporaryDirectory() as raw_home:
        home = Path(raw_home)
        binary_dir = home / "bin"
        binary_dir.mkdir()
        socket_path = home / "docker.sock"
        handoff = home / "handoff"
        docker = binary_dir / "docker"
        docker.write_text(
            """#!/bin/sh
case "$*" in
  "compose version") exit 0 ;;
  "context show") printf '%s\n' local ;;
  "context inspect --format {{.Endpoints.docker.Host}} local") printf 'unix://%s\n' "$FAKE_DOCKER_SOCKET" ;;
  "info") exit 91 ;;
  *) exit 92 ;;
esac
""",
            encoding="utf-8",
        )
        docker.chmod(0o700)
        identity = binary_dir / "id"
        identity.write_text(
            """#!/bin/sh
case "$*" in
  "-G") printf '%s\n' 999999 ;;
  "-un") printf '%s\n' stale-user ;;
  "-G stale-user") printf '%s\n' "$FAKE_SOCKET_GID" ;;
  *) exit 93 ;;
esac
""",
            encoding="utf-8",
        )
        identity.chmod(0o700)
        switch_group = binary_dir / "sg"
        switch_group.write_text(
            """#!/bin/sh
printf '%s|%s|%s|%s|%s|%s\n' \
  "$1" "$2" "$SHIMPZ_DOCKER_GROUP_HANDOFF" "$SHIMPZ_DOCKER_GROUP_ACTION" \
  "$SHIMPZ_DOCKER_GROUP_SCRIPT" "$SHIMPZ_DOCKER_GROUP_RELEASE" >"$FAKE_HANDOFF"
exit 73
""",
            encoding="utf-8",
        )
        switch_group.chmod(0o700)
        environment = {
            "HOME": str(home),
            "PATH": f"{binary_dir}:/usr/bin:/bin",
            "TERM": "dumb",
            "FAKE_DOCKER_SOCKET": str(socket_path),
            "FAKE_HANDOFF": str(handoff),
            "FAKE_SOCKET_GID": str(os.getgid()),
        }
        with socket.socket(socket.AF_UNIX) as docker_socket:
            docker_socket.bind(str(socket_path))
            result = subprocess.run(
                ["/bin/sh", str(script_path), "--scheduled"],
                check=False,
                capture_output=True,
                text=True,
                env=environment,
            )
            fields = handoff.read_text(encoding="utf-8").strip().split("|")
            manual = subprocess.run(
                ["/bin/sh", str(script_path)],
                check=False,
                capture_output=True,
                text=True,
                env=environment,
            )
        check(result.returncode == 73, "the stale process is replaced by the bounded group handoff")
        check(
            fields
            == [
                grp.getgrgid(os.getgid()).gr_name,
                "-c",
                "1",
                "scheduled",
                str(script_path),
                "",
            ],
            "the handoff binds the socket group, installed script, and exact scheduled action",
        )
        check(not (home / ".shimpz").exists(), "group recovery runs before lock or installer state mutation")
        check(manual.returncode == 73, "the interactive stale-group handoff remains bounded")
        check(
            manual.stdout.count("space installer // stable") == 1,
            "the stale-group handoff does not repeat the installer brand",
        )
