#!/usr/bin/env python3
"""Native-host proofs for the shipped Local storage admission functions."""

from __future__ import annotations

import argparse
import os
import secrets
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

from installer_reconciler_contract import run_shell_fixture

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = (ROOT / "static" / "install.sh").read_text(encoding="utf-8")


def shell_functions(start_name: str, end_name: str) -> str:
    start = SCRIPT.index(f"{start_name}() {{")
    end = SCRIPT.index(f"{end_name}() {{", start)
    return SCRIPT[start:end]


def send_hidden_response(terminal: int, response: bytes) -> None:
    import termios

    deadline = time.monotonic() + 2
    while termios.tcgetattr(terminal)[3] & termios.ECHO:
        if time.monotonic() >= deadline:
            raise AssertionError("the LUKS prompt did not disable terminal echo")
        time.sleep(0.01)
    os.write(terminal, response + b"\n")


def run_pty_shell_fixture(source: str) -> subprocess.CompletedProcess[str]:
    import fcntl
    import pty
    import select
    import termios

    passphrase = b"ci-only-storage-passphrase"
    with tempfile.TemporaryDirectory(prefix="shimpz-storage-fixture-") as raw_fixture:
        fixture = Path(raw_fixture) / "run"
        fixture.write_text("#!/bin/sh\nset -eu\n" + source, encoding="utf-8")
        fixture.chmod(0o700)
        terminal, child_terminal = pty.openpty()

        def claim_controlling_terminal() -> None:
            os.setsid()
            fcntl.ioctl(child_terminal, termios.TIOCSCTTY, 0)

        process = subprocess.Popen(
            [str(fixture)],
            stdin=child_terminal,
            stdout=child_terminal,
            stderr=child_terminal,
            close_fds=True,
            preexec_fn=claim_controlling_terminal,
        )
        os.close(child_terminal)
        transcript = bytearray()
        responses = 0
        deadline = time.monotonic() + 180
        try:
            while time.monotonic() < deadline and process.poll() is None:
                readable, _, _ = select.select([terminal], [], [], 1)
                if not readable:
                    continue
                try:
                    transcript.extend(os.read(terminal, 4096))
                except OSError:
                    break
                prompt_count = transcript.count(b"Enter passphrase") + transcript.count(b"Verify passphrase")
                if prompt_count > 5:
                    raise AssertionError("the production LUKS flow requested an unexpected number of credentials")
                while responses < prompt_count:
                    send_hidden_response(terminal, passphrase)
                    responses += 1
            if process.poll() is None:
                safe_tail = bytes(transcript[-2000:]).replace(passphrase, b"[redacted]").decode(errors="replace")
                raise AssertionError(f"the production LUKS flow did not finish within 180 seconds\n{safe_tail}")
        finally:
            os.close(terminal)
            if process.poll() is None:
                process.kill()
            return_code = process.wait()
    output = transcript.decode(errors="replace").replace(passphrase.decode(), "[redacted]")
    return subprocess.CompletedProcess([], return_code, output, "")


def linux_live() -> None:
    if sys.platform != "linux":
        raise AssertionError("the live LUKS proof must run on Linux")
    for tool in ("cryptsetup", "mkfs.ext4", "mount", "umount", "findmnt", "sudo"):
        if shutil.which(tool) is None:
            raise AssertionError(f"the Linux runner is missing {tool}")
    sudo_path = shutil.which("sudo")
    if sudo_path is None:
        raise AssertionError("the Linux runner is missing sudo")
    sudo_probe = subprocess.run([sudo_path, "-n", "true"], check=False, capture_output=True, text=True)
    if sudo_probe.returncode != 0:
        raise AssertionError("the Linux CI proof requires passwordless sudo and will not wait on a hidden prompt")
    with tempfile.TemporaryDirectory(prefix="shimpz-storage-") as raw_root:
        root = Path(raw_root)
        security = root / "security"
        image = security / "local-data.luks"
        uuid_file = security / "local-data.uuid"
        marker = security / ".shimpz-storage"
        mountpoint = security / "volumes"
        space_hex = secrets.token_hex(12)
        mapping = f"shimpz-{space_hex}"
        source = (
            shell_functions("validate_space_id", "validate_repository_digest_image")
            + shell_functions("storage_profile_from_evidence", "linux_volume_specs")
            + shell_functions("linux_volume_specs", "macos_storage_verified")
            + f"""
SECURITY_MARKER="shimpz-local-storage-v1"
SECURITY_DIR="{security}"
SECURE_MARKER_FILE="{marker}"
SECURE_POOL_IMAGE="{image}"
SECURE_POOL_UUID_FILE="{uuid_file}"
SECURE_POOL_MOUNT="{mountpoint}"
SECURE_POOL_SIZE="256M"
space_id="space-{space_hex}"
action="apply"
die() {{ printf '%s\n' "$*" >&2; exit 1; }}
cleanup() {{
    mountpoint -q "$SECURE_POOL_MOUNT" && root_command umount "$SECURE_POOL_MOUNT" || true
    linux_mapping_name_exists "{mapping}" && root_command cryptsetup close "{mapping}" || true
    [ ! -e "$SECURITY_DIR" ] || root_command chown -R "$(id -u):$(id -g)" "$SECURITY_DIR" || true
    [ ! -e "$SECURITY_DIR" ] || root_command chmod -R u+rwX "$SECURITY_DIR" || true
}}
trap cleanup EXIT HUP INT TERM
provision_linux_storage
linux_pool_mounted_valid
root_command umount "$SECURE_POOL_MOUNT"
root_command cryptsetup close "{mapping}"
root_command cryptsetup open --type luks2 "$SECURE_POOL_IMAGE" "{mapping}" </dev/tty
root_command mount -o nodev,nosuid "/dev/mapper/{mapping}" "$SECURE_POOL_MOUNT"
linux_pool_mounted_valid
space_id="space-aaaaaaaaaaaaaaaaaaaaaaaa"
reset_secure_storage ""
[ "$space_id" = "space-aaaaaaaaaaaaaaaaaaaaaaaa" ]
space_id="space-{space_hex}"
provision_linux_storage
root_command umount "$SECURE_POOL_MOUNT"
root_command cryptsetup close "{mapping}"
unset space_id
reset_secure_storage ""
[ -z "${{space_id-}}" ]
reset_secure_storage ""
[ ! -e "$SECURITY_DIR" ]
printf 'verified-production-linux-luks-open-and-closed-reset\n'
"""
        )
        try:
            result = run_pty_shell_fixture(source)
        finally:
            for cleanup_command in (
                [sudo_path, "-n", "umount", str(mountpoint)],
                [sudo_path, "-n", "cryptsetup", "close", mapping],
                [sudo_path, "-n", "chown", "-R", f"{os.getuid()}:{os.getgid()}", str(root)],
            ):
                subprocess.run(cleanup_command, check=False, capture_output=True, text=True)
        if result.returncode != 0 or "verified-production-linux-luks-open-and-closed-reset" not in result.stdout:
            raise AssertionError(f"live LUKS detector failed\nstdout:\n{result.stdout}\nstderr:\n{result.stderr}")
        print(result.stdout.strip())


def macos_native() -> None:
    if sys.platform != "darwin":
        raise AssertionError("the FileVault probe must run on macOS")
    verifier = shell_functions("macos_storage_verified", "bitlocker_record_valid")
    with tempfile.TemporaryDirectory(prefix="shimpz-empty-home-") as empty_home:
        home = Path(empty_home)
        binary_dir = home / "bin"
        binary_dir.mkdir()
        fdesetup = binary_dir / "fdesetup"
        fdesetup.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
        fdesetup.chmod(0o700)
        environment = {
            "HOME": empty_home,
            "PATH": f"{binary_dir}:/usr/bin:/bin:/usr/sbin:/sbin",
            "SHIMPZ_RAM_NAME": f"SHIMPZ_{secrets.token_hex(6)}",
        }
        missing = run_shell_fixture(verifier + "\nmacos_storage_verified\n", environment)
        docker_disk = home / "Library" / "Containers" / "com.docker.docker" / "Data" / "vms" / "0" / "data"
        docker_disk.mkdir(parents=True)
        (docker_disk / "Docker.raw").touch()
        same_device = run_shell_fixture(verifier + "\nmacos_storage_verified\n", environment)
        different_device = run_shell_fixture(
            verifier
            + """
ram_name="$SHIMPZ_RAM_NAME"
ram_device="$(hdiutil attach -nomount ram://65536 | awk 'NR == 1 { print $1 }')"
[ -n "$ram_device" ]
cleanup_ram_disk() { hdiutil detach "$ram_device" >/dev/null 2>&1 || true; }
trap cleanup_ram_disk EXIT HUP INT TERM
diskutil erasevolume HFS+ "$ram_name" "$ram_device" >/dev/null
HOME="/Volumes/$ram_name"
export HOME
mkdir -p "$HOME/Library/Containers/com.docker.docker/Data/vms/0/data"
: >"$HOME/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw"
[ "$(stat -f '%d' "$HOME")" != "$(stat -f '%d' /System/Volumes/Data)" ]
if macos_storage_verified; then
    exit 1
fi
printf 'verified-different-device-denied\n'
""",
            environment,
        )
    if missing.returncode == 0:
        raise AssertionError("the production macOS probe admitted a host with no default Docker.raw data disk")
    if same_device.returncode != 0:
        raise AssertionError("the production macOS probe rejected Docker.raw on the startup data filesystem")
    if different_device.returncode != 0 or "verified-different-device-denied" not in different_device.stdout:
        raise AssertionError(
            "the production macOS probe did not deny Docker.raw on a different filesystem device\n"
            f"stdout:\n{different_device.stdout}\nstderr:\n{different_device.stderr}"
        )
    print("verified-macos-filevault-path-and-device")


def windows_native() -> None:
    if sys.platform != "win32":
        raise AssertionError("the BitLocker probe must run on Windows")
    verifier = shell_functions("bitlocker_record_valid", "ensure_storage_admission")
    with tempfile.TemporaryDirectory(prefix="shimpz-empty-localappdata-") as empty_data:
        environment = {"LOCALAPPDATA": empty_data}
        missing = run_shell_fixture(verifier + "\nwindows_bitlocker_record\n", environment)
        docker_disk = Path(empty_data) / "Docker" / "wsl" / "data"
        docker_disk.mkdir(parents=True)
        (docker_disk / "docker_data.vhdx").touch()
        record = run_shell_fixture(verifier + "\nwindows_bitlocker_record\n", environment)
        verified = run_shell_fixture(verifier + "\nwindows_bitlocker_verified\n", environment)
    if missing.returncode == 0:
        raise AssertionError("the production Windows probe admitted a missing default Docker data VHDX")
    fields = record.stdout.strip().split("|")
    if record.returncode != 0 or len(fields) != 4 or fields[0] != "shimpz-bitlocker-v1" or not fields[3].isdigit():
        raise AssertionError(f"the production Windows probe did not emit a bounded BitLocker record: {record.stderr}")
    expected_verified = record.stdout.strip() == "shimpz-bitlocker-v1|FullyEncrypted|On|100"
    if (verified.returncode == 0) != expected_verified:
        raise AssertionError("the production Windows verifier disagreed with its exact BitLocker record")
    print("verified-windows-bitlocker-query-and-parser")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=("linux-live", "macos-native", "windows-native"))
    args = parser.parse_args()
    {"linux-live": linux_live, "macos-native": macos_native, "windows-native": windows_native}[args.mode]()


if __name__ == "__main__":
    main()
