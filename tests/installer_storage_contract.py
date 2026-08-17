"""Concrete contracts for Local data-at-rest admission."""

from __future__ import annotations

import os
import subprocess
import tempfile
from collections.abc import Callable
from pathlib import Path


def _run_shell(source: str, environment: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["/bin/sh", "-c", "set -eu\n" + source],
        check=False,
        capture_output=True,
        text=True,
        env={**os.environ, **(environment or {})},
    )


def _assert_exact_parsers(shell_functions: Callable[[str, str], str], check: Callable[[object, str], None]) -> None:
    profile_parser = shell_functions("storage_profile_from_evidence", "detect_storage_profile")
    for evidence, expected in (("Linux 0 0", "linux-luks"), ("Linux 1 1", "windows-wsl"), ("Darwin 0 0", "macos-filevault")):
        accepted = _run_shell(profile_parser + f"\nstorage_profile_from_evidence {evidence}\n")
        check(accepted.returncode == 0 and accepted.stdout.strip() == expected, "exact host evidence selects one profile")
    for evidence in ("Linux 1 0", "Linux 0 1", "Darwin 1 0", "FreeBSD 0 0"):
        rejected = _run_shell(profile_parser + f"\nstorage_profile_from_evidence {evidence}\n")
        check(rejected.returncode != 0, "contradictory or unsupported host evidence is denied")

    luks_parser = shell_functions("luks_dump_valid", "linux_pool_metadata_valid")
    valid_luks = """Version:       2
Data segments:
  0: crypt
        cipher: aes-xts-plain64
Keyslots:
  0: luks2
        Key:        512 bits
        PBKDF:      argon2id"""
    accepted = _run_shell(luks_parser + '\nluks_dump_valid "$TEST_RECORD"\n', {"TEST_RECORD": valid_luks})
    check(accepted.returncode == 0, "the production parser accepts exact LUKS2 AES-XTS/Argon2id metadata")
    for invalid in (
        valid_luks.replace("Version:       2", "Version:       1"),
        valid_luks.replace("aes-xts-plain64", "aes-cbc-essiv:sha256"),
        valid_luks.replace("512 bits", "256 bits"),
        valid_luks.replace("argon2id", "pbkdf2"),
        valid_luks + "\nVersion:       1",
    ):
        rejected = _run_shell(luks_parser + '\nluks_dump_valid "$TEST_RECORD"\n', {"TEST_RECORD": invalid})
        check(rejected.returncode != 0, "the production LUKS parser rejects downgraded or ambiguous metadata")

    bitlocker_parser = shell_functions("bitlocker_record_valid", "windows_bitlocker_verified")
    accepted = _run_shell(
        bitlocker_parser + '\nbitlocker_record_valid "$TEST_RECORD"\n',
        {"TEST_RECORD": "shimpz-bitlocker-v1|FullyEncrypted|On|100"},
    )
    check(accepted.returncode == 0, "the production parser accepts exact active full BitLocker protection")
    for invalid in (
        "shimpz-bitlocker-v1|EncryptionInProgress|On|99",
        "shimpz-bitlocker-v1|FullyEncrypted|Off|100",
        "shimpz-bitlocker-v1|FullyEncrypted|On|",
        "FullyEncrypted|On|100",
        "shimpz-bitlocker-v1|FullyEncrypted|On|100\nextra",
    ):
        rejected = _run_shell(
            bitlocker_parser + '\nbitlocker_record_valid "$TEST_RECORD"\n',
            {"TEST_RECORD": invalid},
        )
        check(rejected.returncode != 0, "the production BitLocker parser rejects partial or malformed evidence")


def _assert_profile_aware_renderer(
    script: str,
    shell_functions: Callable[[str, str], str],
    check: Callable[[object, str], None],
) -> None:
    renderer = shell_functions("render_volume_definitions", "validate_existing_runtime")
    volume_names = script.split('LOCAL_VOLUME_NAMES="', 1)[1].split('"', 1)[0]
    common = f'LOCAL_VOLUME_NAMES="{volume_names}"\n'
    linux = _run_shell(common + 'storage_profile="linux-luks"\n' + renderer + "\nrender_volume_definitions\n")
    check(linux.returncode == 0, f"the Linux volume renderer executes: {linux.stderr.strip()}")
    check(linux.stdout.count("driver: local") == 23, "every Linux Local volume is a local-driver bind")
    check(linux.stdout.count("o: bind") == 23, "every Linux Local volume refuses implicit source creation")
    check(
        linux.stdout.count("${SHIMPZ_SECURE_VOLUME_ROOT:?") == 23,
        "every Linux Local volume is rooted below the admitted encrypted mount",
    )
    desktop = _run_shell(common + 'storage_profile="macos-filevault"\n' + renderer + "\nrender_volume_definitions\n")
    check(desktop.returncode == 0, "the Docker Desktop named-volume renderer executes")
    check("driver:" not in desktop.stdout and desktop.stdout.count(":\n") == 23, "Desktop keeps 23 named volumes")


def _assert_scheduled_unlock_is_non_privileged(
    shell_functions: Callable[[str, str], str],
    check: Callable[[object, str], None],
) -> None:
    ensure_function = shell_functions("ensure_linux_storage", "macos_storage_verified")
    with tempfile.TemporaryDirectory() as raw_root:
        root = Path(raw_root)
        binary_dir = root / "bin"
        binary_dir.mkdir()
        sentinel = root / "sudo-called"
        for command_name in ("cryptsetup", "sudo"):
            command = binary_dir / command_name
            command.write_text(
                "#!/bin/sh\n"
                + (f": >'{sentinel}'\n" if command_name == "sudo" else "")
                + "exit 99\n",
                encoding="utf-8",
            )
            command.chmod(0o700)
        source = (
            ensure_function
            + """
action="scheduled"
install_mode="update"
SECURITY_DIR="$TEST_SECURITY_DIR"
linux_pool_metadata_valid() { return 0; }
linux_pool_mounted_valid() { return 1; }
info() { printf '%s\n' "$*"; }
die() { printf '%s\n' "$*" >&2; exit 1; }
ensure_linux_storage
"""
        )
        result = _run_shell(
            source,
            {"PATH": f"{binary_dir}:/usr/bin:/bin", "TEST_SECURITY_DIR": str(root)},
        )
        check(result.returncode == 0, "a scheduled locked-pool check is a successful safe no-op")
        check("locked; no workloads were started" in result.stdout, "the scheduled no-op reports safe unavailability")
        check(not sentinel.exists(), "the scheduled path never invokes sudo")


def assert_storage_contract(
    script: str,
    shell_functions: Callable[[str, str], str],
    check: Callable[[object, str], None],
) -> None:
    for marker in (
        'SECURITY_MARKER="shimpz-local-storage-v1"',
        "cryptsetup luksFormat --batch-mode --type luks2",
        "--cipher aes-xts-plain64 --key-size 512 --pbkdf argon2id",
        'secure_mapping="shimpz-${space_hex}"',
        '"/sys/class/block/${dm_block}/dm/uuid"',
        '"/sys/class/block/${loop_block}/loop/backing_file"',
        'findmnt -rn -M "$SECURE_POOL_MOUNT"',
        'install -d -o 0 -g 0 -m 000 "$SECURE_POOL_MOUNT"',
        "FileVault must protect Docker Desktop's default Docker.raw data disk",
        "shimpz-bitlocker-v1|$($volume.VolumeStatus)|$($volume.ProtectionStatus)|$($volume.EncryptionPercentage)",
        '"$(cat /proc/1/comm 2>/dev/null)" = "systemd"',
        'reset_secure_storage "$recovery_space_id"',
        'reset_secure_storage "$reset_space_id"',
    ):
        check(marker in script, f"storage admission retains {marker!r}")
    check("rm -rf" not in script and "umount -l" not in script, "secure reset is exact and never forced or recursive")
    check(
        script.index("wsl_kernel=0") < script.index("case \"${host_os}:${host_arch}\" in"),
        "WSL is classified before the native Linux storage arm",
    )
    startup = "compose up -d --wait --wait-timeout 120 --no-build --pull never --remove-orphans"
    first_start = script.index(startup)
    second_start = script.index(startup, first_start + 1)
    check(
        script.rfind("ensure_storage_admission", 0, first_start) > script.rfind("step \"Starting", 0, first_start),
        "candidate start has an immediately preceding storage gate",
    )
    check(
        script.rfind("ensure_storage_admission", first_start, second_start)
        > script.rfind('mv "${COMPOSE_FILE}.previous" "$COMPOSE_FILE"', first_start, second_start),
        "rollback start re-runs storage admission after restoring its graph",
    )
    _assert_exact_parsers(shell_functions, check)
    _assert_profile_aware_renderer(script, shell_functions, check)
    _assert_scheduled_unlock_is_non_privileged(shell_functions, check)
