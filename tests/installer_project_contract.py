"""Compose project-identity assertions for the Shimpz Space installer."""

IMAGE_REPOSITORY_FOR_TESTS = "ghcr.io/theshimpz/shimpz-space"


def check(condition: object, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def assert_project_validator_contract(run_project_validator) -> None:
    """Assert exact names, roles, and singleton controller identity."""
    image = f"{IMAGE_REPOSITORY_FOR_TESTS}@sha256:{'d' * 64}"
    space_id = f"space-{'1' * 24}"
    exact_names = (
        ("/shimpz-admin", "admin"),
        ("/shimpz-team", "team-local"),
        ("/shimpz-brain", "brain-runtime"),
        ("/shimpz-egress", "app-egress-proxy"),
        ("/shimpz-account", "oauth-broker-proxy"),
    )
    for container_name, service in exact_names:
        environments = {"current": f"SHIMPZ_SPACE_ID={space_id}"} if service == "team-local" else None
        accepted = run_project_validator(
            [f"current|{container_name}|{service}|{image}"],
            controller_environments=environments,
        )
        check(accepted.returncode == 0, f"the exact {container_name} project container is accepted")
        expected_state = f"current|{space_id}|1" if service == "team-local" else "||0"
        check(
            accepted.stdout.strip() == expected_state,
            f"the exact {container_name} project container records only its intended role",
        )

    healthy_project = run_project_validator(
        [
            f"current|/shimpz-team|team-local|{image}",
            f"second|/shimpz-admin|admin|{image}",
            f"third|/shimpz-brain|brain-runtime|{image}",
            f"foreign|/shimpz-egress|app-egress-proxy|{image}",
            f"oauth|/shimpz-account|oauth-broker-proxy|{image}",
        ],
        controller_environments={"current": f"SHIMPZ_SPACE_ID={space_id}"},
    )
    check(
        healthy_project.returncode == 0 and healthy_project.stdout.strip() == f"current|{space_id}|1",
        "a complete current project validates in one pass",
    )

    for record in (
        f"/shimpz-account|app-egress-proxy|{image}",
        f"/shimpz-admin|brain-runtime|{image}",
        f"/shimpz-unknown|admin|{image}",
    ):
        rejected = run_project_validator([f"current|{record}"])
        check(rejected.returncode != 0, "an unknown container name or mismatched service fails closed")

    duplicate_admin = run_project_validator(
        [
            f"current|/shimpz-admin|admin|{image}",
            f"second|/shimpz-admin|admin|{image}",
        ],
    )
    check(duplicate_admin.returncode != 0, "duplicate Admin containers fail closed")

    duplicate_controller = run_project_validator(
        [
            f"current|/shimpz-team|team-local|{image}",
            f"second|/shimpz-team|team-local|{image}",
        ],
        controller_environments={
            "current": f"SHIMPZ_SPACE_ID={space_id}",
            "second": f"SHIMPZ_SPACE_ID={space_id}",
        },
    )
    check(duplicate_controller.returncode != 0, "duplicate Team controllers fail closed")
