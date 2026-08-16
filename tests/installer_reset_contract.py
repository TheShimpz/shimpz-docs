"""Reset-specific contracts for the Local installer."""

from collections.abc import Callable


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
        "stty \"$terminal_state\" </dev/tty 2>/dev/null || true; release_lock" in script
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
