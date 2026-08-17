"""Concrete contracts for Local data-at-rest admission."""

from __future__ import annotations

import subprocess
import tempfile
from collections.abc import Callable
from dataclasses import dataclass, field
from pathlib import Path

ShellRunner = Callable[[str, dict[str, str] | None], subprocess.CompletedProcess[str]]


@dataclass
class ComposeIdentity:
    uid: int | None = None
    gid: int | None = None
    groups: set[int] = field(default_factory=set)
    volumes: dict[str, str] = field(default_factory=dict)


def _assert_exact_parsers(
    shell_functions: Callable[[str, str], str],
    run_shell: ShellRunner,
    check: Callable[[object, str], None],
) -> None:
    profile_parser = shell_functions("storage_profile_from_evidence", "detect_storage_profile")
    for evidence, expected in (
        ("Linux 0 0", "linux-luks"),
        ("Linux 1 1", "windows-wsl"),
        ("Darwin 0 0", "macos-filevault"),
    ):
        accepted = run_shell(profile_parser + f"\nstorage_profile_from_evidence {evidence}\n", None)
        check(
            accepted.returncode == 0 and accepted.stdout.strip() == expected,
            "exact host evidence selects one profile",
        )
    for evidence in ("Linux 1 0", "Linux 0 1", "Darwin 1 0", "FreeBSD 0 0"):
        rejected = run_shell(profile_parser + f"\nstorage_profile_from_evidence {evidence}\n", None)
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
    accepted = run_shell(luks_parser + '\nluks_dump_valid "$TEST_RECORD"\n', {"TEST_RECORD": valid_luks})
    check(accepted.returncode == 0, "the production parser accepts exact LUKS2 AES-XTS/Argon2id metadata")
    for invalid in (
        valid_luks.replace("Version:       2", "Version:       1"),
        valid_luks.replace("aes-xts-plain64", "aes-cbc-essiv:sha256"),
        valid_luks.replace("512 bits", "256 bits"),
        valid_luks.replace("argon2id", "pbkdf2"),
        valid_luks + "\nVersion:       1",
    ):
        rejected = run_shell(luks_parser + '\nluks_dump_valid "$TEST_RECORD"\n', {"TEST_RECORD": invalid})
        check(rejected.returncode != 0, "the production LUKS parser rejects downgraded or ambiguous metadata")

    bitlocker_parser = shell_functions("bitlocker_record_valid", "windows_bitlocker_verified")
    accepted = run_shell(
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
        rejected = run_shell(
            bitlocker_parser + '\nbitlocker_record_valid "$TEST_RECORD"\n',
            {"TEST_RECORD": invalid},
        )
        check(rejected.returncode != 0, "the production BitLocker parser rejects partial or malformed evidence")

    record_function = shell_functions("windows_bitlocker_record", "windows_bitlocker_verified")
    with tempfile.TemporaryDirectory() as raw_binary_dir:
        binary_dir = Path(raw_binary_dir)
        powershell = binary_dir / "powershell.exe"
        powershell.write_text("#!/bin/sh\nexit 7\n", encoding="utf-8")
        powershell.chmod(0o700)
        environment = {"PATH": f"{binary_dir}:/usr/bin:/bin"}
        failed_query = run_shell(record_function + "\nwindows_bitlocker_record\n", environment)
        check(failed_query.returncode != 0, "the production BitLocker record preserves PowerShell query failure")
        powershell.write_text(
            "#!/bin/sh\nprintf 'shimpz-bitlocker-v1|FullyEncrypted|On|100\\r\\n'\n",
            encoding="utf-8",
        )
        successful_query = run_shell(record_function + "\nwindows_bitlocker_record\n", environment)
        check(
            successful_query.returncode == 0
            and successful_query.stdout == "shimpz-bitlocker-v1|FullyEncrypted|On|100\n",
            "the production BitLocker record strips only Windows carriage returns",
        )


def _assert_profile_aware_renderer(
    script: str,
    shell_functions: Callable[[str, str], str],
    run_shell: ShellRunner,
    check: Callable[[object, str], None],
) -> None:
    renderer = shell_functions("render_volume_definitions", "validate_existing_runtime")
    volume_names = script.split('LOCAL_VOLUME_NAMES="', 1)[1].split('"', 1)[0]
    common = f'LOCAL_VOLUME_NAMES="{volume_names}"\n'
    linux = run_shell(common + 'storage_profile="linux-luks"\n' + renderer + "\nrender_volume_definitions\n", None)
    check(linux.returncode == 0, f"the Linux volume renderer executes: {linux.stderr.strip()}")
    check(linux.stdout.count("driver: local") == 23, "every Linux Local volume is a local-driver bind")
    check(linux.stdout.count("o: bind") == 23, "every Linux Local volume refuses implicit source creation")
    check(
        linux.stdout.count("${SHIMPZ_SECURE_VOLUME_ROOT:?") == 23,
        "every Linux Local volume is rooted below the admitted encrypted mount",
    )
    desktop = run_shell(
        common + 'storage_profile="macos-filevault"\n' + renderer + "\nrender_volume_definitions\n",
        None,
    )
    check(desktop.returncode == 0, "the Docker Desktop named-volume renderer executes")
    check("driver:" not in desktop.stdout and desktop.stdout.count(":\n") == 23, "Desktop keeps 23 named volumes")


def _compose_identities(script: str, volume_names: set[str]) -> dict[str, ComposeIdentity]:
    start_marker = "cat >\"${COMPOSE_FILE}.tmp\" <<'COMPOSE'\n"
    compose = script.split(start_marker, maxsplit=1)[1].split("\nCOMPOSE\nrender_volume_definitions", maxsplit=1)[0]
    identities: dict[str, ComposeIdentity] = {}
    service_name = ""
    list_name = ""
    for line in compose.splitlines():
        if line == "volumes:":
            break
        if line.startswith("  ") and not line.startswith("    ") and line.endswith(":"):
            service_name = line.strip()[:-1]
            identities[service_name] = ComposeIdentity()
            list_name = ""
            continue
        if not service_name:
            continue
        if line.startswith("    ") and not line.startswith("      "):
            list_name = line.strip()[:-1] if line.strip().endswith(":") else ""
            if line.strip().startswith('user: "'):
                uid_text, gid_text = line.split('"', maxsplit=2)[1].split(":", maxsplit=1)
                identities[service_name].uid = int(uid_text)
                identities[service_name].gid = int(gid_text)
            continue
        if not line.startswith("      - "):
            continue
        item = line.removeprefix("      - ").strip().strip('"')
        if list_name == "group_add" and item.isdigit():
            identities[service_name].groups.add(int(item))
        if list_name == "volumes":
            volume_fields = item.split(":")
            volume_name = volume_fields[0]
            if volume_name in volume_names:
                access = volume_fields[-1] if volume_fields[-1] in {"ro", "rw"} else "rw"
                identities[service_name].volumes[volume_name] = access
    return identities


def _assert_volume_ownership_matches_graph(
    script: str,
    shell_functions: Callable[[str, str], str],
    run_shell: ShellRunner,
    check: Callable[[object, str], None],
) -> None:
    specs_result = run_shell(shell_functions("linux_volume_specs", "luks_dump_valid") + "\nlinux_volume_specs\n", None)
    check(specs_result.returncode == 0, "the production Linux ownership specification executes")
    specs = {
        name: (int(uid), int(gid), int(mode))
        for name, uid, gid, mode in (line.split(":") for line in specs_result.stdout.splitlines())
    }
    declared_names = set(script.split('LOCAL_VOLUME_NAMES="', maxsplit=1)[1].split('"', maxsplit=1)[0].split())
    check(set(specs) == declared_names, "the Linux ownership specification covers every persistent Local volume")
    identities = _compose_identities(script, declared_names)
    mounted_names = {name for identity in identities.values() for name in identity.volumes}
    check(mounted_names == declared_names, "every persistent Local volume has an owning graph consumer")
    for service_name, identity in identities.items():
        for volume_name, access in identity.volumes.items():
            owner_uid, owner_gid, mode = specs[volume_name]
            root_access = identity.uid == 0
            owner_access = identity.uid == owner_uid
            group_access = owner_gid in ({identity.gid} | identity.groups)
            owner_mode = mode // 100
            group_mode = mode // 10 % 10
            readable = root_access or (owner_access and owner_mode & 5 == 5) or (group_access and group_mode & 5 == 5)
            writable = root_access or (owner_access and owner_mode & 3 == 3) or (group_access and group_mode & 3 == 3)
            check(readable, f"{service_name} can read its {volume_name} mount through UID/GID ownership")
            if access == "rw":
                check(writable, f"{service_name} can write its {volume_name} mount through UID/GID ownership")


def _assert_scheduled_unlock_is_non_privileged(
    shell_functions: Callable[[str, str], str],
    run_shell: ShellRunner,
    check: Callable[[object, str], None],
) -> None:
    ensure_function = shell_functions("ensure_linux_storage", "macos_storage_verified")
    with tempfile.TemporaryDirectory() as raw_root:
        root = Path(raw_root)
        binary_dir = root / "bin"
        binary_dir.mkdir()
        sentinel = root / "sudo-called"
        for command_name in ("cryptsetup", "findmnt", "mountpoint", "readlink", "stat", "sudo"):
            command = binary_dir / command_name
            command.write_text(
                "#!/bin/sh\n" + (f": >'{sentinel}'\n" if command_name == "sudo" else "") + "exit 99\n",
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
        result = run_shell(
            source,
            {"PATH": f"{binary_dir}:/usr/bin:/bin", "TEST_SECURITY_DIR": str(root)},
        )
        check(result.returncode == 0, "a scheduled locked-pool check is a successful safe no-op")
        check("locked; no workloads were started" in result.stdout, "the scheduled no-op reports safe unavailability")
        check(not sentinel.exists(), "the scheduled path never invokes sudo")


def assert_storage_contract(
    script: str,
    shell_functions: Callable[[str, str], str],
    run_shell: ShellRunner,
    check: Callable[[object, str], None],
) -> None:
    for marker in (
        'SECURITY_MARKER="shimpz-local-storage-v1"',
        'SECURE_POOL_SIZE="64G"',
        "cryptsetup luksFormat --batch-mode --type luks2",
        "--cipher aes-xts-plain64 --key-size 512 --pbkdf argon2id",
        'secure_mapping="shimpz-${space_hex}"',
        '"/sys/class/block/${dm_block}/dm/uuid"',
        "stat -Lc '%t:%T'",
        "mapper_node_major_minor",
        '"/sys/class/block/${loop_block}/loop/backing_file"',
        'deleted_backing_file="${backing_file% (deleted)}"',
        "linux_pool_mapping_name()",
        'linux_mapping_name_exists "$secure_mapping"',
        'findmnt -rn -M "$SECURE_POOL_MOUNT"',
        'install -d -o 0 -g 0 -m 000 "$SECURE_POOL_MOUNT"',
        "FileVault must protect Docker Desktop's default Docker.raw data disk",
        "shimpz-bitlocker-v1|$($volume.VolumeStatus)|$($volume.ProtectionStatus)|$($volume.EncryptionPercentage)",
        "windows_bitlocker_record()",
        '"$(cat /proc/1/comm 2>/dev/null)" = "systemd"',
        'reset_secure_storage "$recovery_space_id"',
        'reset_secure_storage "$reset_space_id"',
    ):
        check(marker in script, f"storage admission retains {marker!r}")
    check("rm -rf" not in script and "umount -l" not in script, "secure reset is exact and never forced or recursive")
    check(
        script.index("wsl_kernel=0") < script.index('case "${host_os}:${host_arch}" in'),
        "WSL is classified before the native Linux storage arm",
    )
    startup = "compose up -d --wait --wait-timeout 120 --no-build --pull never --remove-orphans"
    first_start = script.index(startup)
    second_start = script.index(startup, first_start + 1)
    check(
        script.rfind("ensure_storage_admission", 0, first_start) > script.rfind('step "Starting', 0, first_start),
        "candidate start has an immediately preceding storage gate",
    )
    check(
        script.rfind("ensure_storage_admission", first_start, second_start)
        > script.rfind('mv "${COMPOSE_FILE}.previous" "$COMPOSE_FILE"', first_start, second_start),
        "rollback start re-runs storage admission after restoring its graph",
    )
    _assert_exact_parsers(shell_functions, run_shell, check)
    _assert_profile_aware_renderer(script, shell_functions, run_shell, check)
    _assert_volume_ownership_matches_graph(script, shell_functions, run_shell, check)
    _assert_scheduled_unlock_is_non_privileged(shell_functions, run_shell, check)
