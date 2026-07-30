"""Egress-specific contracts for the Local installer topology."""

from collections.abc import Callable

Check = Callable[[object, str], None]


def assert_brain_egress_runtime(
    brain_egress: str,
    compose: str,
    check: Check,
) -> None:
    """Prove provider traffic crosses only the catalog-bound Brain proxy."""
    for marker in (
        "${SHIMPZ_BRAIN_IMAGE:?installer must pin SHIMPZ_BRAIN_IMAGE}",
        'user: "10001:10001"',
        "- /opt/venv/bin/python",
        "- /app/egress/app.py",
        "read_only: true",
        "cap_drop:\n      - ALL",
        "no-new-privileges:true",
        "com.shimpz.local.kind: brain-egress",
        "brain_egress_audit:/var/log/brain-egress:rw",
        "SHIMPZ_EGRESS_AUDIT_LOG: /var/log/brain-egress/audit.jsonl",
        'SHIMPZ_EGRESS_MAX_CONCURRENCY: "64"',
        'SHIMPZ_EGRESS_MAX_SOURCE_CONCURRENCY: "8"',
        'SHIMPZ_EGRESS_LISTEN_BACKLOG: "16"',
        'cpus: "1.0"',
        "mem_limit: 256m",
        "memswap_limit: 256m",
        "pids_limit: 128",
        "- brain_egress\n      - brain_egress_out",
        'test: ["CMD", "/opt/venv/bin/python", "/app/egress/healthcheck.py"]',
    ):
        check(marker in brain_egress, f"Brain egress proxy enforces {marker!r}")
    check("SHIMPZ_EGRESS_ALLOW" not in brain_egress, "Brain egress has no environment policy override")
    check("docker.sock" not in brain_egress, "Brain egress never receives the Docker socket")
    check("brain_runtime_token" not in brain_egress, "Brain egress never receives the runtime bearer")
    check("brain_runtime_state" not in brain_egress, "Brain egress never receives checkpoint state")
    check(
        "brain_egress:\n    driver: bridge\n    internal: true" in compose,
        "Brain-to-proxy network is internal",
    )
    check("brain_egress_out:\n    driver: bridge" in compose, "Brain egress alone receives its outbound plane")


def assert_assistant_egress_runtime(
    assistant_egress: str,
    compose: str,
    check: Check,
) -> None:
    """Prove the Assistant-owned proxy remains independently constrained."""
    for marker in (
        "${SHIMPZ_ASSISTANT_EGRESS_IMAGE:?installer must pin SHIMPZ_ASSISTANT_EGRESS_IMAGE}",
        'user: "10005:10005"',
        '- "10017"',
        "read_only: true",
        "cap_drop:\n      - ALL",
        "no-new-privileges:true",
        'com.shimpz.local.managed: "1"',
        "com.shimpz.local.profile: local-v1",
        "com.shimpz.local.space-id: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}",
        "com.shimpz.local.kind: assistant-egress",
        'SHIMPZ_ASSISTANT_EGRESS_PORT: "8889"',
        "SHIMPZ_ASSISTANT_EGRESS_POLICY_DIR: /policy",
        "assistant_egress_policy:/policy:ro",
        "assistant_egress_audit:/var/log/assistant-egress:rw",
        "noexec,nosuid,nodev,size=16m",
        '["CMD", "python3", "/app/healthcheck.py"]',
        'cpus: "1.0"',
        "mem_limit: 256m",
        "memswap_limit: 256m",
        "pids_limit: 128",
        "- assistant_egress_out",
    ):
        check(marker in assistant_egress, f"Assistant egress proxy enforces {marker!r}")
    check("docker.sock" not in assistant_egress, "Assistant egress proxy never receives the Docker socket")
    check("controller_token" not in assistant_egress, "Assistant egress proxy never receives the controller bearer")
    check("brain_runtime" not in assistant_egress, "Assistant egress proxy cannot enter the Brain plane")
    check(
        "- control" not in assistant_egress and "- egress" not in assistant_egress,
        "proxy starts only on its outbound plane",
    )
    check("assistant_egress_out:\n    driver: bridge" in compose, "Assistant egress uses a dedicated outbound network")


def assert_assistant_release_runtime(
    assistant_release: str,
    compose: str,
    check: Check,
) -> None:
    """Prove Cosign alone receives the narrow GHCR and Sigstore route."""
    for marker in (
        "${SHIMPZ_ASSISTANT_RELEASE_IMAGE:?installer must pin SHIMPZ_ASSISTANT_RELEASE_IMAGE}",
        'user: "10004:10004"',
        "read_only: true",
        "cap_drop:\n      - ALL",
        "no-new-privileges:true",
        'com.shimpz.local.managed: "1"',
        "com.shimpz.local.profile: local-v1",
        "com.shimpz.local.space-id: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}",
        "com.shimpz.local.kind: assistant-release",
        "SHIMPZ_EGRESS_ALLOW: "
        "ghcr.io,tuf-repo-cdn.sigstore.dev,rekor.sigstore.dev,pkg-containers.githubusercontent.com",
        "SHIMPZ_EGRESS_AUDIT_LOG: /var/log/assistant-release/audit.jsonl",
        'SHIMPZ_EGRESS_MAX_CONCURRENCY: "16"',
        'SHIMPZ_EGRESS_MAX_SOURCE_CONCURRENCY: "4"',
        'SHIMPZ_EGRESS_LISTEN_BACKLOG: "8"',
        "assistant_release_audit:/var/log/assistant-release:rw",
        "noexec,nosuid,nodev,size=8m",
        '["CMD", "python3", "/app/healthcheck.py"]',
        'cpus: "0.5"',
        "mem_limit: 128m",
        "memswap_limit: 128m",
        "pids_limit: 64",
        "- assistant_release\n      - assistant_release_out",
    ):
        check(marker in assistant_release, f"Assistant release proxy enforces {marker!r}")
    check("docker.sock" not in assistant_release, "Assistant release proxy never receives the Docker socket")
    check("controller_token" not in assistant_release, "Assistant release proxy never receives a Team bearer")
    check("brain_runtime" not in assistant_release, "Assistant release proxy cannot enter the Brain plane")
    check(
        "assistant_release:\n    driver: bridge\n    internal: true" in compose,
        "Team-to-Assistant-release network is internal",
    )
    check(
        "assistant_release_out:\n    driver: bridge" in compose,
        "Assistant release alone receives its outbound plane",
    )


def assert_account_egress_runtime(
    account_egress: str,
    compose: str,
    check: Check,
) -> None:
    """Prove the Account-owned proxy has no Assistant policy coupling."""
    for marker in (
        "${SHIMPZ_ACCOUNT_EGRESS_IMAGE:?installer must pin SHIMPZ_ACCOUNT_EGRESS_IMAGE}",
        'user: "10006:10006"',
        '- "10022"',
        "com.shimpz.local.kind: account-egress",
        "account_egress_capability:/run/shimpz-account-egress:ro",
        "account_egress_audit:/var/log/account-egress:rw",
        "account-egress-init:\n        condition: service_completed_successfully",
        "- account_egress\n      - account_egress_out",
        'cpus: "0.5"',
        "mem_limit: 128m",
        "pids_limit: 64",
    ):
        check(marker in account_egress, f"OAuth broker proxy enforces {marker!r}")
    check("docker.sock" not in account_egress, "OAuth broker proxy never receives the Docker socket")
    check("controller_token" not in account_egress, "OAuth broker proxy never receives the controller bearer")
    check("brain_runtime" not in account_egress, "OAuth broker proxy cannot enter the Brain plane")
    check("control" not in account_egress, "OAuth broker proxy cannot enter the controller API plane")
    check(
        "account_egress:\n    driver: bridge\n    internal: true" in compose,
        "OAuth broker ingress is internal",
    )
    check("account_egress_out:\n    driver: bridge" in compose, "OAuth broker egress has one outbound plane")
    for retired in (
        "generated_account_egress_proxy_token",
        "account_egress_proxy_token_from_env_file",
        "SHIMPZ_OAUTH_BROKER_PROXY_TOKEN=${account_egress_proxy_token}",
        "printf '[\"shimpz.com\"]\\n'",
        "SHIMPZ_ASSISTANT_EGRESS_",
        "/policy",
    ):
        check(retired not in account_egress, f"Account egress excludes retired Assistant coupling {retired!r}")


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
    check("account_egress_out" not in initializer, "capability initialization has no network")
