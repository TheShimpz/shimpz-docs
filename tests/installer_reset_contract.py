"""Reset-specific contracts for the Local installer."""

import subprocess
import tempfile
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

_RUN = subprocess.run


@dataclass(frozen=True)
class ResetRun:
    results: tuple[subprocess.CompletedProcess[str], ...]
    home_exists: bool
    marker_exists: bool
    foreign_file_exists: bool
    scheduler_files_exist: bool
    symlink_target_marker_exists: bool


def _fake_docker() -> str:
    return r"""#!/bin/sh
case "$*" in
  "compose version") : ;;
  "compose version --short") printf '2.40.0\n' ;;
  "context show") printf 'default\n' ;;
  "context inspect --format {{.Endpoints.docker.Host}} default") printf 'unix:///var/run/docker.sock\n' ;;
  "info") : ;;
  "version --format {{.Server.Version}}") printf '29.0.0\n' ;;
  "version --format {{.Server.APIVersion}}") printf '1.52\n' ;;
  "ps --all --quiet --filter label=com.docker.compose.project=shimpz-space") : ;;
  "volume ls --quiet --filter label=com.docker.compose.project=shimpz-space") : ;;
  "network ls --quiet --filter label=com.docker.compose.project=shimpz-space") : ;;
  *"ps --all --quiet"*"label=com.shimpz.local.managed=1"*)
    if [ "$FAKE_UNBOUND_RESOURCES" = "1" ]; then
      printf 'unbound-container\n'
    fi
    ;;
  *"network ls --quiet"*"label=com.shimpz.local.managed=1"*) : ;;
  *"inspect --type=container --format"*"com.docker.compose.project"*"unbound-container") printf 'other-project\n' ;;
  *) printf 'unexpected docker call: %s\n' "$*" >&2; exit 72 ;;
esac
"""


def _fake_systemctl() -> str:
    return r"""#!/bin/sh
case "$*" in
  "--user show-environment"|"--user disable --now shimpz-update.timer"|"--user daemon-reload") : ;;
  "--user is-active --quiet shimpz-update.timer") [ "$FAKE_SCHEDULER_STUCK" = "1" ] ;;
  "--user is-enabled --quiet shimpz-update.timer") exit 1 ;;
  *) printf 'unexpected systemctl call: %s\n' "$*" >&2; exit 72 ;;
esac
"""


def _fake_launchctl() -> str:
    return r"""#!/bin/sh
case "$*" in
  "print gui/"*"/com.shimpz.update") [ "$FAKE_SCHEDULER_STUCK" = "1" ] ;;
  "print gui/"*) : ;;
  "bootout gui/"*) : ;;
  *) printf 'unexpected launchctl call: %s\n' "$*" >&2; exit 72 ;;
esac
"""


def _run_reset(
    script: str,
    *,
    state: str,
    repeats: int = 1,
    platform: str = "Linux",
    scheduler_stuck: bool = False,
) -> ResetRun:
    with tempfile.TemporaryDirectory() as raw_root:
        root = Path(raw_root)
        home = root / "home"
        home.mkdir()
        binary_dir = root / "bin"
        binary_dir.mkdir()
        for name, source in (
            ("docker", _fake_docker()),
            ("systemctl", _fake_systemctl()),
            ("launchctl", _fake_launchctl()),
        ):
            binary = binary_dir / name
            binary.write_text(source, encoding="utf-8")
            binary.chmod(0o700)
        uname = binary_dir / "uname"
        uname.write_text(f"#!/bin/sh\nprintf '%s\\n' '{platform}'\n", encoding="utf-8")
        uname.chmod(0o700)
        installer = root / "install.sh"
        installer.write_text(script, encoding="utf-8")
        installer.chmod(0o700)
        shimpz_home = home / ".shimpz"
        foreign_file = shimpz_home / "keep-me.txt"
        target_marker = root / "symlink-target" / ".shimpz-space"
        if platform == "Darwin":
            scheduler_dir = home / "Library" / "LaunchAgents"
            scheduler_paths = (
                scheduler_dir / "com.shimpz.update.plist",
                scheduler_dir / "com.shimpz.update.plist.tmp",
            )
        else:
            scheduler_dir = root / "config" / "systemd" / "user"
            scheduler_paths = (
                scheduler_dir / "shimpz-update.service",
                scheduler_dir / "shimpz-update.timer",
                scheduler_dir / "shimpz-update.service.tmp",
                scheduler_dir / "shimpz-update.timer.tmp",
            )
        if state in {"known", "foreign"}:
            shimpz_home.mkdir()
            (shimpz_home / ".shimpz-space").write_text("shimpz-space-managed-v1\n", encoding="utf-8")
        if state == "known":
            for name in (
                "compose.yaml",
                "compose.yaml.previous",
                ".env.previous",
                "compose.yaml.tmp",
                ".env.tmp",
                "reconcile.sh",
                "reconcile.candidate",
                "reconcile.candidate.tmp",
                "reconcile.previous",
                "reconcile.previous.tmp",
                "release-status.json",
                "release-status.json.tmp",
                "failed-release.env",
                "failed-release.env.tmp",
                "release.env.tmp",
            ):
                (shimpz_home / name).touch()
        if state in {"known", "scheduler"}:
            scheduler_dir.mkdir(parents=True, exist_ok=True)
            for path in scheduler_paths:
                if platform == "Darwin":
                    path.write_text(
                        '<?xml version="1.0" encoding="UTF-8"?>\n<!-- shimpz-local-update-v1 -->\n',
                        encoding="utf-8",
                    )
                else:
                    path.write_text("# shimpz-local-update-v1\n", encoding="utf-8")
        if state == "foreign":
            foreign_file.write_text("preserve this\n", encoding="utf-8")
        elif state == "symlink":
            target_marker.parent.mkdir()
            target_marker.write_text("shimpz-space-managed-v1\n", encoding="utf-8")
            shimpz_home.symlink_to(target_marker.parent, target_is_directory=True)
        environment = {
            "HOME": str(home),
            "PATH": f"{binary_dir}:/usr/bin:/bin",
            "XDG_CONFIG_HOME": str(root / "config"),
            "TERM": "dumb",
            "FAKE_SCHEDULER_STUCK": "1" if scheduler_stuck else "0",
            "FAKE_UNBOUND_RESOURCES": "1" if state == "unbound" else "0",
        }
        results = tuple(
            _RUN(
                ["/bin/sh", str(installer), "--reset"],
                check=False,
                capture_output=True,
                text=True,
                env=environment,
            )
            for _ in range(repeats)
        )
        return ResetRun(
            results=results,
            home_exists=shimpz_home.exists() or shimpz_home.is_symlink(),
            marker_exists=(shimpz_home / ".shimpz-space").exists(),
            foreign_file_exists=foreign_file.exists(),
            scheduler_files_exist=any(path.exists() for path in scheduler_paths),
            symlink_target_marker_exists=target_marker.exists(),
        )


def assert_reset_contract(
    script: str,
    check: Callable[[object, str], None],
) -> None:
    check('MARKER_VALUE="shimpz-space-managed-v1"' in script, "installer owns its state with an exact marker")
    check("refusing reset" in script and "invalid install marker" in script, "reset fails closed on foreign state")
    check("rm -rf" not in script, "reset never recursively deletes a user-controlled path")
    check("down --volumes --remove-orphans" in script, "reset removes only the managed Compose resources")
    check(
        'step "Removing verified rollback leftovers"' in script,
        "reset revalidates and removes volumes left by a rolled-back newer Compose contract",
    )
    for marker in (
        "managed Shimpz Docker data exists without an install marker",
        "validate_project_resources",
        '"/shimpz-admin|admin"',
        '"/shimpz-team|team"',
        '"/shimpz-brain|brain"',
        '"/shimpz-brain-egress|shimpz-brain-egress"',
        '"/shimpz-assistant-egress|shimpz-assistant-egress"',
        '"/shimpz-assistant-release|shimpz-assistant-release"',
        '"/shimpz-account-egress|shimpz-account-egress"',
        '"/shimpz-account-egress-init|shimpz-account-egress-init"',
        '"${PROJECT_NAME}_config|config"',
        '"${PROJECT_NAME}_data|data"',
        '"${PROJECT_NAME}_controller_token|controller_token"',
        '"${PROJECT_NAME}_controller_audit|controller_audit"',
        '"${PROJECT_NAME}_controller_storage|controller_storage"',
        '"${PROJECT_NAME}_controller_inference|controller_inference"',
        '"${PROJECT_NAME}_controller_action_journal|controller_action_journal"',
        '"${PROJECT_NAME}_controller_publications|controller_publications"',
        '"${PROJECT_NAME}_controller_cosign_trust|controller_cosign_trust"',
        '"${PROJECT_NAME}_controller_assistant_integration_state|controller_assistant_integration_state"',
        '"${PROJECT_NAME}_controller_assistant_integration_key|controller_assistant_integration_key"',
        '"${PROJECT_NAME}_controller_chat_continuation_state|controller_chat_continuation_state"',
        '"${PROJECT_NAME}_controller_chat_continuation_key|controller_chat_continuation_key"',
        '"${PROJECT_NAME}_supervisor_key|supervisor_key"',
        '"${PROJECT_NAME}_release_status|release_status"',
        '"${PROJECT_NAME}_brain_runtime_token|brain_runtime_token"',
        '"${PROJECT_NAME}_brain_runtime_state|brain_runtime_state"',
        '"${PROJECT_NAME}_brain_egress_audit|brain_egress_audit"',
        '"${PROJECT_NAME}_assistant_release_audit|assistant_release_audit"',
        '"${PROJECT_NAME}_assistant_egress_policy|assistant_egress_policy"',
        '"${PROJECT_NAME}_assistant_egress_audit|assistant_egress_audit"',
        '"${PROJECT_NAME}_account_egress_capability|account_egress_capability"',
        '"${PROJECT_NAME}_account_egress_audit|account_egress_audit"',
        '"${PROJECT_NAME}_egress|egress"',
        '"${PROJECT_NAME}_control|control"',
        '"${PROJECT_NAME}_brain_runtime|brain_runtime"',
        '"${PROJECT_NAME}_brain_egress|brain_egress"',
        '"${PROJECT_NAME}_brain_egress_out|brain_egress_out"',
        '"${PROJECT_NAME}_assistant_release|assistant_release"',
        '"${PROJECT_NAME}_assistant_release_out|assistant_release_out"',
        '"${PROJECT_NAME}_assistant_egress_out|assistant_egress_out"',
        "validate_dynamic_resources",
        'docker exec -i "$admin_id" python',
        "auth.verify_password",
        "transport.supervisor_session",
        "bridge.reset_space",
        'document.get("reset") is True',
        "the Supervisor password is incorrect",
        "the authenticated Team reset did not complete",
        "a Space-labeled container has invalid ownership labels",
        "invalid Assistant egress proxy name",
        "invalid Assistant release proxy name",
        "dynamic_assistant_container_ids",
        "a Space-labeled network has invalid ownership labels",
        "reset left unexpected Shimpz Space Docker resources",
    ):
        check(marker in script, f"orphan recovery remains bounded by {marker!r}")
    check(
        "valid or sys.exit(2)" in script and '2) die "the Supervisor password is incorrect"' in script,
        "reset distinguishes rejected Supervisor credentials from Team lifecycle failure",
    )
    check(
        'stty "$terminal_state" </dev/tty 2>/dev/null || true; release_lock' in script
        and "trap 'release_lock' EXIT HUP INT TERM" in script,
        "the authenticated reset restores the install lock trap after reading the password",
    )
    reset_branch = script.split('if [ "$action" = "reset" ]; then', 1)[1].split(
        '\nhost_os="$(uname -s)"',
        1,
    )[0]
    check(
        reset_branch.index("reset_dynamic_space") < reset_branch.index("compose down --volumes --remove-orphans"),
        "authenticated dynamic reset runs before Compose data removal",
    )

    pristine = _run_reset(script, state="pristine", repeats=2)
    for result in pristine.results:
        output = result.stdout + result.stderr
        check(result.returncode == 0, f"an already-clean reset succeeds: {output}")
        check("Shimpz Space was reset" in output, "an already-clean reset reports the positive terminal outcome")
        check("no such file" not in output.lower(), "absent reset targets never leak a missing-file error")
    check(not pristine.home_exists, "repeated clean resets leave no installer directory")

    known = _run_reset(script, state="known")
    check(known.results[0].returncode == 0, f"reset removes interrupted installer state: {known.results[0].stderr}")
    check(not known.home_exists, "reset removes every known current installer temporary")
    check(not known.scheduler_files_exist, "reset removes owned scheduler files and temporaries")

    mac_scheduler = _run_reset(script, state="scheduler", platform="Darwin")
    check(mac_scheduler.results[0].returncode == 0, "an orphaned owned LaunchAgent is sufficient reset state")
    check(not mac_scheduler.scheduler_files_exist, "reset removes owned macOS scheduler files and temporaries")

    stuck_scheduler = _run_reset(script, state="known", scheduler_stuck=True)
    check(stuck_scheduler.results[0].returncode != 0, "reset fails when an owned scheduler remains active")

    foreign = _run_reset(script, state="foreign")
    foreign_output = foreign.results[0].stdout + foreign.results[0].stderr
    check(foreign.results[0].returncode == 0, f"foreign residue does not invalidate managed reset: {foreign_output}")
    check(foreign.foreign_file_exists and not foreign.marker_exists, "reset preserves and disowns foreign residue")
    check("keep-me.txt" in foreign_output and "Move or delete" in foreign_output, "foreign residue is actionable")

    symlink = _run_reset(script, state="symlink")
    check(symlink.results[0].returncode != 0, "reset refuses an installer home reached through a symbolic link")
    check(symlink.symlink_target_marker_exists, "symlink refusal mutates no target state")

    unbound = _run_reset(script, state="unbound")
    unbound_output = unbound.results[0].stdout + unbound.results[0].stderr
    check(unbound.results[0].returncode != 0, "reset refuses dynamic resources without a current Space identity")
    check("restore the current .env" in unbound_output, "unbound reset explains the safe next action")
