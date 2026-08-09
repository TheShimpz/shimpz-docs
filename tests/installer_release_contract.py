"""Atomic Local release metadata contracts for the public installer."""

import hashlib
import re
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
        reconciler = home / "reconcile.sh"
        reconciler.write_text("#!/bin/sh\n", encoding="utf-8")
        docker = binary_dir / "docker"
        docker.write_text(
            """#!/bin/sh
case "$1" in
  create) printf '%s\n' release-metadata ;;
  cp)
    case "$2" in
      *:/release.env) cp "$FAKE_RELEASE_METADATA" "$3" ;;
      *:/reconcile.sh) cp "$FAKE_RECONCILER" "$3" ;;
      *) exit 72 ;;
    esac
    ;;
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
RECONCILER_CANDIDATE="$TEST_HOME/reconcile.candidate"
action="install"
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
                "FAKE_RECONCILER": str(reconciler),
            },
        )


_RUN = subprocess.run


def assert_pull_only_delivery(script: str, check: Callable[[object, str], None]) -> None:
    """Prove the bootstrap resolves one closed release set without local builds."""
    repositories = {
        "RELEASE_REPOSITORY": "ghcr.io/theshimpz/shimpz-local-release",
        "ADMIN_REPOSITORY": "ghcr.io/theshimpz/shimpz-admin",
        "TEAM_REPOSITORY": "ghcr.io/theshimpz/shimpz-team-local",
        "BRAIN_REPOSITORY": "ghcr.io/theshimpz/shimpz-brain",
        "EGRESS_REPOSITORY": "ghcr.io/theshimpz/shimpz-egress",
    }
    for variable, repository in repositories.items():
        check(f'{variable}="{repository}"' in script, f"installer owns the exact package {repository}")
    check("shimpz-space@" not in script, "no platform artifact uses the Compose project as an OCI package")
    check('RELEASE_CHANNEL="stable"' in script, "installer selects one atomic stable Local release")
    for channel in ("ADMIN_CHANNEL", "TEAM_CHANNEL", "BRAIN_CHANNEL", "EGRESS_CHANNEL"):
        check(channel not in script, f"installer never resolves the retired independent {channel}")
    check(
        "SHIMPZ_TEAM_CHANNEL" not in script and "SHIMPZ_INSTALL_PROFILE" not in script,
        "installer exposes no alternate release profile or channel",
    )
    for marker in (
        'docker pull --quiet --platform "$docker_platform"',
        "RepoDigests",
        "sha256:",
        '"${#digest_hex}" -eq 64',
        'release_image_ref="$(pull_verified_ref "$release_selector_ref" "$RELEASE_REPOSITORY")"',
        'load_release_set "$release_image_ref"',
        'admin_image_ref="$(pull_verified_ref "$admin_image_ref" "$ADMIN_REPOSITORY")"',
        'team_image_ref="$(pull_verified_ref "$team_image_ref" "$TEAM_REPOSITORY")"',
        'brain_image_ref="$(pull_verified_ref "$brain_image_ref" "$BRAIN_REPOSITORY")"',
        'egress_image_ref="$(pull_verified_ref "$egress_image_ref" "$EGRESS_REPOSITORY")"',
    ):
        check(marker in script, f"installer derives an immutable image via {marker!r}")
    check(
        script.count('pull_verified_ref "$') == 5, "one release channel and its four exact members resolve to digests"
    )
    check(
        "SHIMPZ_LOCAL_RELEASE_IMAGE=${release_image_ref}" in script
        and "SHIMPZ_LOCAL_RELEASE_ORDINAL=${release_ordinal}" in script,
        "the applied release identity and monotonic ordinal are persisted",
    )
    check("SHIMPZ_ADMIN_IMAGE=${admin_image_ref}" in script, "the environment pins the Admin digest")
    check("SHIMPZ_TEAM_IMAGE=${team_image_ref}" in script, "the environment pins the controller digest")
    check("SHIMPZ_BRAIN_IMAGE=${brain_image_ref}" in script, "the environment pins the Brain runtime digest")
    check("SHIMPZ_EGRESS_IMAGE=${egress_image_ref}" in script, "the environment pins the shared egress digest once")
    check(
        "SHIMPZ_SPACE_PLATFORM=${docker_platform}" in script,
        "the generated environment stores the validated Docker platform",
    )
    check(
        "SHIMPZ_PROJECT_NAME=${PROJECT_NAME}" in script
        and "SHIMPZ_ADMIN_ALLOWED_ORIGINS=${ADMIN_ALLOWED_ORIGINS}" in script
        and "name: ${SHIMPZ_PROJECT_NAME:?installer must pin SHIMPZ_PROJECT_NAME}" in script
        and "SHIMPZ_ASSISTANT_EGRESS_CONTAINER: shimpz-assistant-egress" in script,
        "the generated Compose project is pinned and the controller targets the named egress container",
    )
    compose = script.split("cat >\"${COMPOSE_FILE}.tmp\" <<'COMPOSE'", 1)[1].split("\nCOMPOSE", 1)[0]
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
    reserved_line = next(line for line in script.splitlines() if line.startswith("RESERVED_CONTAINER_NAMES="))
    check(
        sorted(reserved_line.split('"')[1].split()) == sorted(container_names),
        "the reserved-name preflight covers exactly the Compose container names",
    )
    check("image: ${SHIMPZ_ADMIN_IMAGE:?" in script, "Compose fails closed without the pinned Admin reference")
    check("image: ${SHIMPZ_TEAM_IMAGE:?" in script, "Compose fails closed without the pinned controller reference")
    check("image: ${SHIMPZ_BRAIN_IMAGE:?" in script, "Compose fails closed without the pinned Brain runtime reference")
    check(
        script.count("image: ${SHIMPZ_EGRESS_IMAGE:?") == 5,
        "all five egress services fail closed on the one pinned egress reference",
    )
    check(
        "platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}" in script,
        "Compose fails closed without the pinned platform",
    )
    check("pull_policy: never" in script and "--pull never" in script, "Compose cannot silently replace the digest")
    check(
        'install_port="${SHIMPZ_PORT:-7777}"' in script
        and "unset SHIMPZ_ADMIN_IMAGE SHIMPZ_TEAM_IMAGE SHIMPZ_BRAIN_IMAGE SHIMPZ_EGRESS_IMAGE" in script
        and "unset SHIMPZ_LOCAL_RELEASE_IMAGE SHIMPZ_LOCAL_RELEASE_ORDINAL SHIMPZ_SPACE_PLATFORM SHIMPZ_PORT" in script
        and "unset SHIMPZ_DOCKER_GID SHIMPZ_DOCKER_SOCKET SHIMPZ_SPACE_ID SHIMPZ_CPUSET" in script
        and "SHIMPZ_PORT=${install_port}" in script,
        "exported shell variables cannot override install, rollback, or reset state",
    )
    for forbidden in ("git clone", "npm ", "pnpm ", "uv sync", "docker build", "build:"):
        check(forbidden not in script, f"installer excludes source-build operation {forbidden!r}")


def assert_atomic_release_contract(
    shell_functions: Callable[[str, str], str], check: Callable[[object, str], None]
) -> None:
    digest = "a" * 64
    reconciler_sha256 = hashlib.sha256(b"#!/bin/sh\n").hexdigest()
    valid = (
        "\n".join(
            (
                "schema=local-v1",
                "ordinal=42",
                f"umbrella_revision={'b' * 40}",
                f"reconciler_sha256={reconciler_sha256}",
                f"admin=ghcr.io/theshimpz/shimpz-admin@sha256:{digest}",
                f"team=ghcr.io/theshimpz/shimpz-team-local@sha256:{digest}",
                f"brain=ghcr.io/theshimpz/shimpz-brain@sha256:{digest}",
                f"egress=ghcr.io/theshimpz/shimpz-egress@sha256:{digest}",
            )
        )
        + "\n"
    )
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
        "wrong repository": valid.replace("admin=ghcr.io/theshimpz/shimpz-admin", "admin=ghcr.io/example/shimpz-admin"),
        "tag member": valid.replace(f"@sha256:{digest}", ":stable", 1),
        "invalid reconciler hash": valid.replace(reconciler_sha256, "z" * 64),
        "missing reconciler hash": valid.replace(f"reconciler_sha256={reconciler_sha256}\n", ""),
    }
    for label, metadata in invalid.items():
        rejected = _run_validator(metadata, shell_functions)
        check(rejected.returncode != 0, f"release metadata rejects {label}")
