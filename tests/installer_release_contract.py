"""Atomic Local release metadata contracts for the public installer."""

import subprocess
import tempfile
from collections.abc import Callable
from pathlib import Path


def _run_validator(metadata: str, shell_functions: Callable[[str, str], str]) -> subprocess.CompletedProcess[str]:
    with tempfile.TemporaryDirectory() as raw_home:
        home = Path(raw_home)
        binary_dir = home / "bin"
        binary_dir.mkdir()
        source = home / "source.env"
        source.write_text(metadata, encoding="utf-8")
        docker = binary_dir / "docker"
        docker.write_text(
            """#!/bin/sh
case "$1" in
  create) printf '%s\n' release-metadata ;;
  cp) cp "$FAKE_RELEASE_METADATA" "$3" ;;
  rm) : ;;
  *) exit 71 ;;
esac
""",
            encoding="utf-8",
        )
        docker.chmod(0o700)
        shell = home / "validator.sh"
        shell.write_text(
            """#!/bin/sh
set -eu
SHIMPZ_HOME="$TEST_HOME"
docker_platform="linux/amd64"
ADMIN_REPOSITORY="ghcr.io/theshimpz/shimpz-admin"
TEAM_REPOSITORY="ghcr.io/theshimpz/shimpz-team-local"
BRAIN_REPOSITORY="ghcr.io/theshimpz/shimpz-brain"
EGRESS_REPOSITORY="ghcr.io/theshimpz/shimpz-egress"
die() { printf '%s\n' "$*" >&2; exit 1; }
"""
            + shell_functions("release_value", "load_previous_release")
            + '\nload_release_set "ghcr.io/theshimpz/shimpz-local-release@sha256:'
            + "a" * 64
            + '"\nprintf "%s\\n" "$release_ordinal:$admin_image_ref:$release_revision"\n',
            encoding="utf-8",
        )
        shell.chmod(0o700)
        return _RUN(
            ["/bin/sh", str(shell)],
            check=False,
            capture_output=True,
            text=True,
            env={
                "PATH": f"{binary_dir}:/usr/bin:/bin",
                "TEST_HOME": str(home),
                "FAKE_RELEASE_METADATA": str(source),
            },
        )


_RUN = subprocess.run


def assert_atomic_release_contract(
    shell_functions: Callable[[str, str], str], check: Callable[[object, str], None]
) -> None:
    digest = "a" * 64
    valid = "\n".join(
        (
            "schema=local-v1",
            "ordinal=42",
            f"umbrella_revision={'b' * 40}",
            f"admin=ghcr.io/theshimpz/shimpz-admin@sha256:{digest}",
            f"team=ghcr.io/theshimpz/shimpz-team-local@sha256:{digest}",
            f"brain=ghcr.io/theshimpz/shimpz-brain@sha256:{digest}",
            f"egress=ghcr.io/theshimpz/shimpz-egress@sha256:{digest}",
        )
    ) + "\n"
    accepted = _run_validator(valid, shell_functions)
    check(accepted.returncode == 0, f"exact release metadata is admitted: {accepted.stderr}")
    check(
        accepted.stdout.strip() == f"42:ghcr.io/theshimpz/shimpz-admin@sha256:{digest}:{'b' * 40}",
        "the parser projects the exact ordinal, member, and source revision",
    )

    invalid = {
        "unknown field": valid.replace("schema=local-v1", "schema=local-v1\nmount=/var/run/docker.sock"),
        "duplicate field": valid.replace("ordinal=42", "ordinal=42\nordinal=43"),
        "unknown schema": valid.replace("schema=local-v1", "schema=local-v2"),
        "zero ordinal": valid.replace("ordinal=42", "ordinal=0"),
        "wrong repository": valid.replace(
            "admin=ghcr.io/theshimpz/shimpz-admin", "admin=ghcr.io/example/shimpz-admin"
        ),
        "tag member": valid.replace(f"@sha256:{digest}", ":stable", 1),
    }
    for label, metadata in invalid.items():
        rejected = _run_validator(metadata, shell_functions)
        check(rejected.returncode != 0, f"release metadata rejects {label}")
