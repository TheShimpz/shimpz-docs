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
        '"/shimpz-team|team-local"',
        '"/shimpz-brain|brain-runtime"',
        '"/shimpz-egress|app-egress-proxy"',
        '"/shimpz-account|oauth-broker-proxy"',
        '"${PROJECT_NAME}_config|config"',
        '"${PROJECT_NAME}_data|data"',
        '"${PROJECT_NAME}_controller_token|controller_token"',
        '"${PROJECT_NAME}_controller_audit|controller_audit"',
        '"${PROJECT_NAME}_controller_storage|controller_storage"',
        '"${PROJECT_NAME}_controller_inference|controller_inference"',
        '"${PROJECT_NAME}_controller_power_journal|controller_power_journal"',
        '"${PROJECT_NAME}_controller_publications|controller_publications"',
        '"${PROJECT_NAME}_controller_assistant_integration_state|controller_assistant_integration_state"',
        '"${PROJECT_NAME}_controller_assistant_integration_key|controller_assistant_integration_key"',
        '"${PROJECT_NAME}_controller_chat_continuation_state|controller_chat_continuation_state"',
        '"${PROJECT_NAME}_controller_chat_continuation_key|controller_chat_continuation_key"',
        '"${PROJECT_NAME}_supervisor_key|supervisor_key"',
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
        'docker exec -i "$admin_id" python',
        "auth.verify_password",
        "transport.supervisor_session",
        "bridge.reset_space",
        'document.get("reset") is True',
        "the authenticated Team reset did not complete",
        "a Space-labeled container has invalid ownership labels",
        "invalid managed Assistant egress proxy name",
        "dynamic_assistant_container_ids",
        "a Space-labeled network has invalid ownership labels",
        "reset left unexpected Shimpz Space Docker resources",
    ):
        check(marker in script, f"orphan recovery remains bounded by {marker!r}")
    reset_branch = script.split('if [ "$action" = "reset" ]; then', 1)[1].split(
        '\nhost_os="$(uname -s)"',
        1,
    )[0]
    check(
        reset_branch.index("reset_dynamic_space") < reset_branch.index("compose down --volumes --remove-orphans"),
        "authenticated dynamic reset runs before Compose data removal",
    )
