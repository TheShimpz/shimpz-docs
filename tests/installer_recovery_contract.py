"""Contracts for destructive recovery of an owned corrupt Local installation."""

from installer_recovery_harness import run_recovery


def _recovery_functions(shell_functions):
    return (
        shell_functions("drain_piped_installer_source", "usage")
        + shell_functions("validate_space_id", "validate_repository_digest_image")
        + shell_functions("dynamic_container_ids", "validate_dynamic_resources")
        + shell_functions("remove_project_resources", "write_release_status")
    )


def _assert_explicit_terminal_yes(script, shell_functions, check):
    functions = _recovery_functions(shell_functions)
    recovery_function = shell_functions("offer_corrupt_reinstall", "write_release_status")
    check(
        '[ "$action" = "install" ] || die "$recovery_reason"' in recovery_function,
        "only the normal installer can offer corrupt-state replacement",
    )
    install_validation = script.split('step "Validating the existing managed runtime"', 1)[1].split(
        "\numask 077",
        1,
    )[0]
    check(
        install_validation.index('if runtime_validation_error="$({')
        < install_validation.index("validate_project_resources", 1)
        < install_validation.index('} 2>&1)"; then')
        < install_validation.index("else\n\t\toffer_corrupt_reinstall"),
        "a healthy managed runtime validates normally without reaching the recovery prompt",
    )
    check(
        '""|[nN]|[nN][oO])\n\t\t\t\tdrain_piped_installer_source' in recovery_function,
        "declining recovery drains a piped public installer before exiting",
    )
    for answer in ("", "No", "n"):
        declined = run_recovery(functions, answer=answer)
        check(declined.returncode != 0, "No or the default choice declines corrupt-install recovery")
        check("Existing Local Space left unchanged" in declined.output, "the declined choice reports no deletion")
        check(not declined.docker_calls and not declined.scheduler_removed, "declining recovery mutates no runtime")
        check(declined.installer_files_remain, "declining recovery preserves the installed files")

    non_interactive = run_recovery(functions, terminal=False)
    check(non_interactive.returncode != 0, "corrupt-install recovery fails closed without a controlling terminal")
    check("requires an interactive terminal" in non_interactive.output, "non-interactive recovery explains the gate")
    check(
        not non_interactive.docker_calls and not non_interactive.scheduler_removed,
        "the missing terminal cannot mutate the runtime",
    )


def _assert_yes_deletes_only_owned_scope(shell_functions, check):
    recovered = run_recovery(_recovery_functions(shell_functions), answer="Yes")
    check(recovered.returncode == 0, f"explicit Yes completes recovery: {recovered.output}")
    check("FRESH:install:space-" in recovered.output, "recovery falls through with a fresh generated Space identity")
    check("FRESH:install:space-111111111111111111111111" not in recovered.output, "recovery never reuses the old id")
    check(recovered.scheduler_removed, "recovery stops the owned automatic updater before deletion")
    check(not recovered.remaining_resources, "recovery removes every exact project and current Space resource")
    check(not recovered.installer_files_remain, "recovery removes only the known installer files before bootstrap")
    check(
        set(recovered.docker_calls)
        == {
            "container:project-admin",
            "container:project-proxy",
            "container:dynamic-assistant",
            "container:shimpz-team",
            "network:project-network",
            "network:dynamic-network",
            "volume:project-volume",
        },
        "recovery deletes the exact bounded resources once",
    )


def _assert_unbound_dynamic_resources_are_refused(shell_functions, check):
    refused = run_recovery(
        _recovery_functions(shell_functions),
        answer="Yes",
        owned_identity=False,
        out_of_project=True,
    )
    check(refused.returncode != 0, "recovery refuses dynamic resources without a resolvable current Space identity")
    check("needs the current Space identity" in refused.output, "the missing identity has an actionable error")
    check(not refused.docker_calls and not refused.scheduler_removed, "ambiguous recovery scope mutates nothing")


def assert_recovery_contract(script, shell_functions, check):
    _assert_explicit_terminal_yes(script, shell_functions, check)
    _assert_yes_deletes_only_owned_scope(shell_functions, check)
    _assert_unbound_dynamic_resources_are_refused(shell_functions, check)
