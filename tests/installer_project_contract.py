"""Compose project-identity assertions for the Shimpz Space installer."""

IMAGE_REPOSITORIES_FOR_TESTS = {
    "account-egress": "ghcr.io/theshimpz/shimpz-account-egress",
    "account-egress-init": "ghcr.io/theshimpz/shimpz-account-egress",
    "admin": "ghcr.io/theshimpz/shimpz-admin",
    "assistant-egress": "ghcr.io/theshimpz/shimpz-assistant-egress",
    "brain": "ghcr.io/theshimpz/shimpz-brain",
    "brain-egress": "ghcr.io/theshimpz/shimpz-brain",
    "team": "ghcr.io/theshimpz/shimpz-team-local",
}


def check(condition: object, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def assert_project_validator_contract(run_project_validator) -> None:
    """Assert exact names, roles, and singleton controller identity."""
    images = {
        service: f"{repository}@sha256:{'d' * 64}"
        for service, repository in IMAGE_REPOSITORIES_FOR_TESTS.items()
    }
    space_id = f"space-{'1' * 24}"
    exact_names = (
        ("/account-egress-init", "account-egress-init"),
        ("/shimpz-admin", "admin"),
        ("/shimpz-team", "team"),
        ("/shimpz-brain", "brain"),
        ("/shimpz-brain-egress", "brain-egress"),
        ("/assistant-egress", "assistant-egress"),
        ("/account-egress", "account-egress"),
    )
    for container_name, service in exact_names:
        image = images[service]
        environments = {"current": f"SHIMPZ_SPACE_ID={space_id}"} if service == "team" else None
        accepted = run_project_validator(
            [f"current|{container_name}|{service}|{image}"],
            controller_environments=environments,
        )
        check(accepted.returncode == 0, f"the exact {container_name} project container is accepted")
        expected_state = f"current|{space_id}|1" if service == "team" else "||0"
        check(
            accepted.stdout.strip() == expected_state,
            f"the exact {container_name} project container records only its intended role",
        )

    healthy_project = run_project_validator(
        [
            f"init|/account-egress-init|account-egress-init|{images['account-egress-init']}",
            f"current|/shimpz-team|team|{images['team']}",
            f"second|/shimpz-admin|admin|{images['admin']}",
            f"third|/shimpz-brain|brain|{images['brain']}",
            f"brain-egress|/shimpz-brain-egress|brain-egress|{images['brain-egress']}",
            f"foreign|/assistant-egress|assistant-egress|{images['assistant-egress']}",
            f"oauth|/account-egress|account-egress|{images['account-egress']}",
        ],
        controller_environments={"current": f"SHIMPZ_SPACE_ID={space_id}"},
    )
    check(
        healthy_project.returncode == 0 and healthy_project.stdout.strip() == f"current|{space_id}|1",
        "a complete current project validates in one pass",
    )

    for record in (
        f"/account-egress|assistant-egress|{images['assistant-egress']}",
        f"/shimpz-admin|brain|{images['brain']}",
        f"/shimpz-unknown|admin|{images['admin']}",
    ):
        rejected = run_project_validator([f"current|{record}"])
        check(rejected.returncode != 0, "an unknown container name or mismatched service fails closed")

    duplicate_admin = run_project_validator(
        [
            f"current|/shimpz-admin|admin|{images['admin']}",
            f"second|/shimpz-admin|admin|{images['admin']}",
        ],
    )
    check(duplicate_admin.returncode != 0, "duplicate Admin containers fail closed")

    duplicate_controller = run_project_validator(
        [
            f"current|/shimpz-team|team|{images['team']}",
            f"second|/shimpz-team|team|{images['team']}",
        ],
        controller_environments={
            "current": f"SHIMPZ_SPACE_ID={space_id}",
            "second": f"SHIMPZ_SPACE_ID={space_id}",
        },
    )
    check(duplicate_controller.returncode != 0, "duplicate Team controllers fail closed")

    wrong_package = run_project_validator(
        [f"current|/shimpz-team|team|{images['admin']}"],
        controller_environments={"current": f"SHIMPZ_SPACE_ID={space_id}"},
    )
    check(wrong_package.returncode != 0, "a responsibility cannot run another responsibility's package")
