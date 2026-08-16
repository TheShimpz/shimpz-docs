"""Automatic Local reconciliation contracts for the public installer."""

import subprocess
import tempfile
from collections.abc import Callable
from pathlib import Path


def _lock_block(script: str) -> str:
    start = script.index("release_lock() {")
    invocation = script.index("\nacquire_lock\n", start) + len("\nacquire_lock\n")
    return script[start:invocation]


def run_lock_contract(
    script: str,
    action: str,
    *,
    prelocked: bool,
    handoff: bool = False,
    stale: bool = False,
    malformed: bool = False,
) -> subprocess.CompletedProcess[str]:
    with tempfile.TemporaryDirectory() as raw_home:
        lock = Path(raw_home) / ".shimpz-update.lock"
        setup = ""
        if prelocked:
            lock.mkdir()
            if malformed:
                setup = 'printf "not-a-pid\\n" >"$LOCK_DIR/pid"\n'
            elif stale:
                setup = 'printf "99999999\\n" >"$LOCK_DIR/pid"\n'
            else:
                setup = 'printf "%s\\n" "$$" >"$LOCK_DIR/pid"\n'
        command = (
            "set -eu\n"
            f'action="{action}"\n'
            f'lock_handoff="{"1" if handoff else "0"}"\n'
            f'LOCK_DIR="{lock}"\n'
            "lock_owned=0\n"
            "die() { printf '%s\\n' \"$*\" >&2; exit 1; }\n"
            + setup
            + _lock_block(script)
            + '\nprintf "acquired:%s\\n" "$lock_owned"\nrelease_lock\n'
        )
        return subprocess.run(["/bin/sh", "-c", command], check=False, capture_output=True, text=True)


def install_systemd_units(
    script: str,
) -> tuple[subprocess.CompletedProcess[str], str, str, list[str]]:
    with tempfile.TemporaryDirectory() as raw_home:
        home = Path(raw_home)
        binary_dir = home / "bin"
        binary_dir.mkdir()
        calls = home / "systemctl.calls"
        systemctl = binary_dir / "systemctl"
        systemctl.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >>"$SYSTEMCTL_CALLS"\n', encoding="utf-8")
        systemctl.chmod(0o700)
        units = home / "config" / "systemd" / "user"
        service = units / "shimpz-update.service"
        timer = units / "shimpz-update.timer"
        start = script.index("install_scheduler() {")
        end = script.index("persist_reconciler() {", start)
        command = (
            "set -eu\n"
            'host_os="Linux"\n'
            'SCHEDULER_MARKER="shimpz-local-update-v1"\n'
            f'SYSTEMD_USER_DIR="{units}"\n'
            f'SYSTEMD_SERVICE="{service}"\n'
            f'SYSTEMD_TIMER="{timer}"\n'
            "die() { printf '%s\\n' \"$*\" >&2; exit 1; }\n" + script[start:end] + "\ninstall_scheduler\n"
        )
        result = subprocess.run(
            ["/bin/sh", "-c", command],
            check=False,
            capture_output=True,
            text=True,
            env={"PATH": f"{binary_dir}:/usr/bin:/bin", "SYSTEMCTL_CALLS": str(calls)},
        )
        service_text = service.read_text(encoding="utf-8") if service.exists() else ""
        timer_text = timer.read_text(encoding="utf-8") if timer.exists() else ""
        call_lines = calls.read_text(encoding="utf-8").splitlines() if calls.exists() else []
        return result, service_text, timer_text, call_lines


def assert_reconciler_contract(script: str, check: Callable[[object, str], None]) -> None:
    check(
        script.count("cat >\"${COMPOSE_FILE}.tmp\" <<'COMPOSE'") == 1,
        "first install and scheduled updates share one Compose renderer",
    )
    check(
        'exec env SHIMPZ_UPDATE_LOCK_HELD=1 SHIMPZ_PORT="$install_port"' in script
        and 'apply_option="--apply-release"' in script
        and '[ "$install_mode" != "install" ] || apply_option="--apply-fresh-release"' in script
        and '/bin/sh "$RECONCILER_CANDIDATE" "$apply_option" "$release_image_ref"' in script,
        "bootstrap and scheduled selection hand off exact release application to the verified candidate",
    )
    check(
        script.index("drain_piped_installer_source\n\texec env")
        < script.index('/bin/sh "$RECONCILER_CANDIDATE" "$apply_option" "$release_image_ref"'),
        "a piped bootstrap drains its verified public source before replacing the shell with the candidate",
    )
    check(
        '[ "$docker_group_source" != "public" ] || drain_piped_installer_source\n\texec sg' in script,
        "the stale Docker-group handoff drains the outer public installer pipe before replacing its shell",
    )
    check(
        'docker cp "${release_container}:/reconcile.sh"' in script
        and '[ "$actual_reconciler_sha256" = "$reconciler_sha256" ]' in script,
        "the OCI reconciler is extracted and hash-checked before execution",
    )
    check(
        'mv "$RECONCILER_CANDIDATE" "$RECONCILER_FILE"' in script
        and "compose up -d --wait --wait-timeout 120" in script
        and script.index("compose up -d --wait --wait-timeout 120") < script.rindex("\tpersist_reconciler\n"),
        "the candidate replaces the installed reconciler only after the health gate",
    )
    check(
        'cp "$RECONCILER_FILE" "${RECONCILER_PREVIOUS}.tmp"' in script,
        "the previously healthy reconciler remains available during candidate application",
    )
    check(
        'mkdir "$LOCK_DIR"' in script
        and "SHIMPZ_UPDATE_LOCK_HELD" in script
        and '"$(sed -n \'1p\' "$LOCK_DIR/pid")" = "$$"' in script,
        "one PID-bound atomic lock serializes manual and scheduled applies",
    )
    check(
        "OnUnitActiveSec=6h" in script and "RandomizedDelaySec=30m" in script and "Persistent=true" in script,
        "Linux schedules low-frequency persistent checks with jitter",
    )
    check(
        "<key>StartInterval</key><integer>21600</integer>" in script and "<string>--scheduled</string>" in script,
        "macOS schedules the same installed reconciler at low frequency",
    )
    check(
        "current|updated|rollback-needed" in script and 'chmod 600 "${STATUS_FILE}.tmp"' in script,
        "status is bounded to three outcomes and remains owner-readable only",
    )
    rollback = script.split('warn "The new release did not become healthy"', 1)[1].split("persist_reconciler", 1)[0]
    check(
        rollback.count('"rollback-needed" "$release_image_ref" "$release_ordinal" "$previous_admin_ref"') == 2
        and rollback.count('"rollback-needed" "$release_image_ref" "$release_ordinal" "$admin_image_ref"') == 2
        and "write_optional_release_status" in rollback,
        "rollback status uses the best available Admin image without hiding the original failure",
    )
    status_projection = script.split("project_release_status() {", 1)[1].split("remember_failed_release() {", 1)[0]
    check(
        "release_status:/run/shimpz-local-release:ro" in script
        and '"${PROJECT_NAME}_release_status"' in status_projection
        and "--user 1000:1000" in status_projection
        and 'dst=/run/shimpz-local-release"' in status_projection
        and 'target="/run/shimpz-local-release/status.json"' in status_projection
        and "--cap-add" not in status_projection
        and "os.fchown" not in status_projection,
        "Admin and its unprivileged projector share the image-owned release-status path without capabilities",
    )
    check(
        "failed_release_matches" in script
        and "remember_failed_release" in script
        and 'rm -f "$FAILED_RELEASE_FILE"' in script,
        "a failed release digest is not retried until a different release succeeds",
    )
    check(
        'rm -f "$SYSTEMD_SERVICE" "$SYSTEMD_TIMER"' in script
        and 'rm -f "$LAUNCH_AGENT"' in script
        and '"$RECONCILER_FILE" "$RECONCILER_CANDIDATE" "$RECONCILER_PREVIOUS"' in script,
        "reset removes the exact owned schedulers and reconciliation files",
    )
