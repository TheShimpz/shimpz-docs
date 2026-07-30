"""Egress-specific contracts for the Local installer topology."""

from collections.abc import Callable

Check = Callable[[object, str], None]


def assert_assistant_egress_runtime(
    app_egress: str,
    compose: str,
    check: Check,
) -> None:
    """Prove the Assistant-owned proxy remains independently constrained."""
    for marker in (
        "${SHIMPZ_APP_EGRESS_IMAGE:?installer must pin SHIMPZ_APP_EGRESS_IMAGE}",
        'user: "10005:10005"',
        '- "10017"',
        "read_only: true",
        "cap_drop:\n      - ALL",
        "no-new-privileges:true",
        'com.shimpz.local.managed: "1"',
        "com.shimpz.local.profile: single-owner-local-v1",
        "com.shimpz.local.space-id: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}",
        "com.shimpz.local.kind: app-egress-proxy",
        'SHIMPZ_APP_EGRESS_PORT: "8889"',
        "SHIMPZ_APP_EGRESS_POLICY_DIR: /policy",
        "app_egress_policy:/policy:ro",
        "app_egress_audit:/var/log/app-egress-proxy:rw",
        "noexec,nosuid,nodev,size=16m",
        '["CMD", "python3", "/app/healthcheck.py"]',
        'cpus: "1.0"',
        "mem_limit: 256m",
        "memswap_limit: 256m",
        "pids_limit: 128",
        "- app_egress_out",
    ):
        check(marker in app_egress, f"Assistant egress proxy enforces {marker!r}")
    check("docker.sock" not in app_egress, "Assistant egress proxy never receives the Docker socket")
    check("controller_token" not in app_egress, "Assistant egress proxy never receives the controller bearer")
    check("brain_runtime" not in app_egress, "Assistant egress proxy cannot enter the Brain plane")
    check("- control" not in app_egress and "- egress" not in app_egress, "proxy starts only on its outbound plane")
    check("app_egress_out:\n    driver: bridge" in compose, "Assistant egress uses a dedicated outbound network")


def assert_account_egress_runtime(
    oauth_broker: str,
    compose: str,
    check: Check,
) -> None:
    """Prove the Account-owned proxy has no Assistant policy coupling."""
    for marker in (
        "${SHIMPZ_ACCOUNT_EGRESS_IMAGE:?installer must pin SHIMPZ_ACCOUNT_EGRESS_IMAGE}",
        'user: "10006:10006"',
        '- "10022"',
        "com.shimpz.local.kind: oauth-broker-proxy",
        "account_egress_capability:/run/shimpz-account-egress:ro",
        "account_egress_audit:/var/log/account-egress:rw",
        "account-egress-init:\n        condition: service_completed_successfully",
        "- oauth_broker\n      - oauth_broker_out",
        'cpus: "0.5"',
        "mem_limit: 128m",
        "pids_limit: 64",
    ):
        check(marker in oauth_broker, f"OAuth broker proxy enforces {marker!r}")
    check("docker.sock" not in oauth_broker, "OAuth broker proxy never receives the Docker socket")
    check("controller_token" not in oauth_broker, "OAuth broker proxy never receives the controller bearer")
    check("brain_runtime" not in oauth_broker, "OAuth broker proxy cannot enter the Brain plane")
    check("control" not in oauth_broker, "OAuth broker proxy cannot enter the controller API plane")
    check(
        "oauth_broker:\n    driver: bridge\n    internal: true" in compose,
        "OAuth broker ingress is internal",
    )
    check("oauth_broker_out:\n    driver: bridge" in compose, "OAuth broker egress has one outbound plane")
    for retired in (
        "generated_oauth_broker_proxy_token",
        "oauth_broker_proxy_token_from_env_file",
        "SHIMPZ_OAUTH_BROKER_PROXY_TOKEN=${oauth_broker_proxy_token}",
        "printf '[\"shimpz.com\"]\\n'",
        "SHIMPZ_APP_EGRESS_",
        "/policy",
    ):
        check(retired not in oauth_broker, f"Account egress excludes retired Assistant coupling {retired!r}")


def assert_account_egress_initializer(
    initializer: str,
    check: Check,
) -> None:
    """Prove the one-shot capability initializer has no network authority."""
    for marker in (
        "${SHIMPZ_ACCOUNT_EGRESS_IMAGE:?installer must pin SHIMPZ_ACCOUNT_EGRESS_IMAGE}",
        'restart: "no"',
        'user: "0:0"',
        "network_mode: none",
        "read_only: true",
        "cap_drop:\n      - ALL",
        "cap_add:\n      - CHOWN",
        "no-new-privileges:true",
        'entrypoint: ["python3"]',
        'command: ["/app/capability.py", "init"]',
        "account_egress_capability:/run/shimpz-account-egress:rw",
        'cpus: "0.25"',
        "mem_limit: 64m",
        "memswap_limit: 64m",
        "pids_limit: 32",
    ):
        check(marker in initializer, f"Account egress initializer enforces {marker!r}")
    check("oauth_broker_out" not in initializer, "capability initialization has no network")
