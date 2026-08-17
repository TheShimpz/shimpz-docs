#!/usr/bin/env python3
"""Native-host proofs for the shipped Local storage admission functions."""

from __future__ import annotations

import argparse
import secrets
import shutil
import sys
import tempfile
from pathlib import Path

from installer_reconciler_contract import run_shell_fixture

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = (ROOT / "static" / "install.sh").read_text(encoding="utf-8")


def shell_functions(start_name: str, end_name: str) -> str:
    start = SCRIPT.index(f"{start_name}() {{")
    end = SCRIPT.index(f"{end_name}() {{", start)
    return SCRIPT[start:end]


def linux_live() -> None:
    if sys.platform != "linux":
        raise AssertionError("the live LUKS proof must run on Linux")
    for tool in ("cryptsetup", "mkfs.ext4", "mount", "umount", "findmnt", "sudo"):
        if shutil.which(tool) is None:
            raise AssertionError(f"the Linux runner is missing {tool}")
    with tempfile.TemporaryDirectory(prefix="shimpz-storage-") as raw_root:
        root = Path(raw_root)
        security = root / "security"
        image = security / "local-data.luks"
        uuid_file = security / "local-data.uuid"
        marker = security / ".shimpz-storage"
        mountpoint = security / "volumes"
        key_file = root / "test.key"
        space_hex = secrets.token_hex(12)
        mapping = f"shimpz-{space_hex}"
        source = (
            shell_functions("validate_space_id", "validate_repository_digest_image")
            + shell_functions("storage_profile_from_evidence", "linux_volume_specs")
            + shell_functions("linux_volume_specs", "provision_linux_storage")
            + f"""
SECURITY_MARKER="shimpz-local-storage-v1"
SECURITY_DIR="{security}"
SECURE_MARKER_FILE="{marker}"
SECURE_POOL_IMAGE="{image}"
SECURE_POOL_UUID_FILE="{uuid_file}"
SECURE_POOL_MOUNT="{mountpoint}"
space_id="space-{space_hex}"
action="apply"
die() {{ printf '%s\n' "$*" >&2; exit 1; }}
cleanup() {{
    mountpoint -q "$SECURE_POOL_MOUNT" && umount "$SECURE_POOL_MOUNT" || true
    cryptsetup status "{mapping}" >/dev/null 2>&1 && cryptsetup close "{mapping}" || true
}}
trap cleanup EXIT HUP INT TERM
mkdir -m 700 "$SECURITY_DIR"
printf '%s\n' "$SECURITY_MARKER" >"$SECURE_MARKER_FILE"
chmod 600 "$SECURE_MARKER_FILE"
truncate -s 256M "$SECURE_POOL_IMAGE"
chmod 600 "$SECURE_POOL_IMAGE"
printf '%s\n' 'github-actions-only-storage-key' >"{key_file}"
chmod 600 "{key_file}"
install -d -o 0 -g 0 -m 000 "$SECURE_POOL_MOUNT"
cryptsetup luksFormat --batch-mode --type luks2 --cipher aes-xts-plain64 --key-size 512 \
    --pbkdf argon2id --iter-time 100 --key-file "{key_file}" "$SECURE_POOL_IMAGE"
cryptsetup luksUUID "$SECURE_POOL_IMAGE" >"$SECURE_POOL_UUID_FILE"
chmod 600 "$SECURE_POOL_UUID_FILE"
cryptsetup open --type luks2 --key-file "{key_file}" "$SECURE_POOL_IMAGE" "{mapping}"
linux_mapping_identity_valid
mkfs.ext4 -q -m 0 "/dev/mapper/{mapping}"
mount -o nodev,nosuid "/dev/mapper/{mapping}" "$SECURE_POOL_MOUNT"
chown "$(id -u):$(id -g)" "$SECURE_POOL_MOUNT"
chmod 700 "$SECURE_POOL_MOUNT"
prepare_linux_volume_layout
linux_pool_mounted_valid
umount "$SECURE_POOL_MOUNT"
cryptsetup close "{mapping}"
cryptsetup open --type luks2 --key-file "{key_file}" "$SECURE_POOL_IMAGE" "{mapping}"
mount -o nodev,nosuid "/dev/mapper/{mapping}" "$SECURE_POOL_MOUNT"
linux_pool_mounted_valid
reset_secure_storage "$space_id"
reset_secure_storage "$space_id"
[ ! -e "$SECURITY_DIR" ]
printf 'verified-linux-luks-reopen\n'
"""
        )
        result = run_shell_fixture(source, sudo=True)
        if result.returncode != 0 or "verified-linux-luks-reopen" not in result.stdout:
            raise AssertionError(f"live LUKS detector failed\nstdout:\n{result.stdout}\nstderr:\n{result.stderr}")
        print(result.stdout.strip())


def macos_negative() -> None:
    if sys.platform != "darwin":
        raise AssertionError("the FileVault probe must run on macOS")
    source = shell_functions("macos_storage_verified", "bitlocker_record_valid") + "\nmacos_storage_verified\n"
    with tempfile.TemporaryDirectory(prefix="shimpz-empty-home-") as empty_home:
        result = run_shell_fixture(source, environment={"HOME": empty_home})
    if result.returncode == 0:
        raise AssertionError("the production macOS probe admitted a host with no default Docker.raw data disk")
    print("verified-macos-fail-closed")


def windows_negative() -> None:
    if sys.platform != "win32":
        raise AssertionError("the BitLocker probe must run on Windows")
    source = shell_functions("bitlocker_record_valid", "ensure_storage_admission") + "\nwindows_bitlocker_verified\n"
    with tempfile.TemporaryDirectory(prefix="shimpz-empty-localappdata-") as empty_data:
        result = run_shell_fixture(source, environment={"LOCALAPPDATA": empty_data})
    if result.returncode == 0:
        raise AssertionError("the production Windows probe admitted a missing default Docker data VHDX")
    print("verified-windows-fail-closed")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=("linux-live", "macos-negative", "windows-negative"))
    args = parser.parse_args()
    {"linux-live": linux_live, "macos-negative": macos_negative, "windows-negative": windows_negative}[args.mode]()


if __name__ == "__main__":
    main()
