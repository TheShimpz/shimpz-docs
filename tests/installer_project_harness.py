"""Executable Docker fake for exercising the shipped installer project validator."""

from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path


def run_project_validator(
    records: list[str],
    *,
    validator_functions: str,
    controller_environments: dict[str, str] | None = None,
    runner=subprocess.run,
) -> subprocess.CompletedProcess[str]:
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
            second) printf '%s\n' "$FAKE_SECOND_ENV" ;;
            third) printf '%s\n' "$FAKE_THIRD_ENV" ;;
            init) printf '%s\n' "$FAKE_INIT_ENV" ;;
            *) exit 71 ;;
        esac
        ;;
    *)
        case "$resource_id" in
            current) printf '%s\n' "$FAKE_CURRENT_RECORD" ;;
            second) printf '%s\n' "$FAKE_SECOND_RECORD" ;;
            third) printf '%s\n' "$FAKE_THIRD_RECORD" ;;
            foreign) printf '%s\n' "$FAKE_FOREIGN_RECORD" ;;
            oauth) printf '%s\n' "$FAKE_OAUTH_RECORD" ;;
            brain-egress) printf '%s\n' "$FAKE_BRAIN_EGRESS_RECORD" ;;
            release) printf '%s\n' "$FAKE_ASSISTANT_RELEASE_RECORD" ;;
            init) printf '%s\n' "$FAKE_INIT_RECORD" ;;
            *) exit 72 ;;
        esac
        ;;
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
ADMIN_REPOSITORY="ghcr.io/theshimpz/shimpz-admin"
TEAM_REPOSITORY="ghcr.io/theshimpz/shimpz-team-local"
BRAIN_REPOSITORY="ghcr.io/theshimpz/shimpz-brain"
EGRESS_REPOSITORY="ghcr.io/theshimpz/shimpz-egress"
CONTAINER_IDS="$TEST_CONTAINER_IDS"
die() { printf '%s\n' "$*" >&2; exit 1; }
project_container_ids() { printf '%s\n' "$CONTAINER_IDS"; }
project_volume_ids() { :; }
project_network_ids() { :; }
"""
            + validator_functions
            + """
validate_project_resources
printf '%s|%s|%s\n' "$controller_id" "$controller_space_id" "$controller_seen"
""",
            encoding="utf-8",
        )
        shell.chmod(0o700)
        fake_records = {record.split("|", 1)[0]: record.split("|", 1)[1] for record in records}
        environment = {
            "HOME": str(home),
            "PATH": f"{binary_dir}:/usr/bin:/bin",
            "TEST_CONTAINER_IDS": " ".join(fake_records),
            "FAKE_CURRENT_RECORD": fake_records.get("current", ""),
            "FAKE_SECOND_RECORD": fake_records.get("second", ""),
            "FAKE_THIRD_RECORD": fake_records.get("third", ""),
            "FAKE_FOREIGN_RECORD": fake_records.get("foreign", ""),
            "FAKE_OAUTH_RECORD": fake_records.get("oauth", ""),
            "FAKE_BRAIN_EGRESS_RECORD": fake_records.get("brain-egress", ""),
            "FAKE_ASSISTANT_RELEASE_RECORD": fake_records.get("release", ""),
            "FAKE_INIT_RECORD": fake_records.get("init", ""),
            "FAKE_CURRENT_ENV": controller_environments.get("current", ""),
            "FAKE_SECOND_ENV": controller_environments.get("second", ""),
            "FAKE_THIRD_ENV": controller_environments.get("third", ""),
            "FAKE_INIT_ENV": controller_environments.get("init", ""),
        }
        return runner(
            ["/bin/sh", str(shell)],
            check=False,
            capture_output=True,
            text=True,
            env=environment,
        )
