#!/bin/sh

set -eu

BOOTSTRAP_VERSION="2.0.0"
RELEASE_REPOSITORY="ghcr.io/theshimpz/shimpz-local-release"
RELEASE_CHANNEL="stable"

fail() {
	printf '  [error] Shimpz could not continue: %s\n' "$*" >&2
	exit 1
}

usage() {
	cat <<'EOF'
Install or reconcile the stable Shimpz Space.

Usage:
  curl -fsSL https://install.shimpz.com | sh

After installation:
  shimpz status
  shimpz start
  shimpz reset

Supported hosts:
  Linux amd64, including Windows 11 through WSL2 with systemd.
  Apple Silicon macOS arm64.
  Docker Engine 25.0+ and Docker Compose 2.20.2+ are required.
EOF
}

case "${1:-}" in
	"") ;;
	--help|-h) usage; exit 0 ;;
	--version) printf '%s\n' "$BOOTSTRAP_VERSION"; exit 0 ;;
	*) usage >&2; fail "unknown option: $1" ;;
esac
[ "$#" -le 1 ] || fail "the bootstrap accepts at most one option"

resolve_docker() {
	for candidate in /usr/bin/docker /usr/local/bin/docker /opt/homebrew/bin/docker; do
		if [ -x "$candidate" ] && [ ! -L "$candidate" ]; then
			printf '%s\n' "$candidate"
			return 0
		fi
	done
	return 1
}

resolve_host() {
	os="$(uname -s)"
	arch="$(uname -m)"
	case "$os:$arch" in
		Linux:x86_64)
			platform="linux/amd64"
			member="/cli/x86_64-unknown-linux-musl/shimpz"
			hash_key="cli_linux_amd64_sha256"
			;;
		Darwin:arm64)
			platform="linux/arm64"
			member="/cli/aarch64-apple-darwin/shimpz"
			hash_key="cli_macos_arm64_sha256"
			;;
		*) fail "supported hosts are Linux amd64/WSL2 and Apple Silicon macOS" ;;
	esac
}

valid_digest_ref() {
	case "$1" in
		"$RELEASE_REPOSITORY"@sha256:*) digest="${1##*@sha256:}" ;;
		*) return 1 ;;
	esac
	[ "${#digest}" -eq 64 ] || return 1
	case "$digest" in *[!0-9a-f]*) return 1 ;; esac
}

one_metadata_value() {
	key="$1"
	values="$(sed -n "s/^${key}=//p" "$release_metadata")"
	[ -n "$values" ] && [ "$(printf '%s\n' "$values" | wc -l | tr -d ' ')" -eq 1 ] ||
		fail "the atomic release has invalid $key metadata"
	printf '%s\n' "$values"
}

file_hash() {
	if [ -x /usr/bin/sha256sum ]; then
		/usr/bin/sha256sum "$1" | awk '{print $1}'
	elif [ -x /usr/bin/shasum ]; then
		/usr/bin/shasum -a 256 "$1" | awk '{print $1}'
	else
		fail "SHA-256 verification is unavailable"
	fi
}

cleanup() {
	status=$?
	trap - EXIT HUP INT TERM
	if [ "${container_id:-}" ]; then
		"$docker" rm "$container_id" >/dev/null 2>&1 || true
	fi
	if [ "$status" -ne 0 ] && [ "${activated:-0}" -eq 1 ]; then
		[ ! -e "$managed_cli" ] || rm -f "$managed_cli"
		[ ! -e "$previous_cli" ] || mv "$previous_cli" "$managed_cli"
	fi
	[ ! -d "${temporary:-}" ] || rm -rf "$temporary"
	exit "$status"
}

resolve_host
docker="$(resolve_docker)" || fail "Docker is not installed in a supported system path"
"$docker" info >/dev/null 2>&1 || fail "Docker is not running or this user cannot access it"
"$docker" compose version >/dev/null 2>&1 || fail "Docker Compose v2 is unavailable"

temporary="$(mktemp -d "${TMPDIR:-/tmp}/shimpz-bootstrap.XXXXXX")"
chmod 700 "$temporary"
container_id=""
activated=0
trap cleanup EXIT HUP INT TERM

printf '  [..] Resolving the atomic Local release\n'
selector="$RELEASE_REPOSITORY:$RELEASE_CHANNEL"
"$docker" pull --quiet --platform "$platform" "$selector" >/dev/null
release_ref=""
for candidate in $("$docker" image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' "$selector"); do
	if valid_digest_ref "$candidate"; then
		[ -z "$release_ref" ] || fail "Docker returned ambiguous Local release digests"
		release_ref="$candidate"
	fi
done
[ -n "$release_ref" ] || fail "Docker returned no trusted Local release digest"

container_id="$("$docker" create --platform "$platform" "$release_ref" "$member")"
case "$container_id" in *[!0-9a-f]*|"") fail "Docker returned an invalid temporary container" ;; esac
release_metadata="$temporary/release.env"
candidate_cli="$temporary/shimpz"
"$docker" cp "$container_id:/release.env" "$release_metadata" >/dev/null
"$docker" cp "$container_id:$member" "$candidate_cli" >/dev/null
"$docker" rm "$container_id" >/dev/null
container_id=""

[ "$(wc -l < "$release_metadata" | tr -d ' ')" -eq 10 ] || fail "the atomic release metadata is not closed"
[ "$(one_metadata_value schema)" = "local-v2" ] || fail "the atomic release schema is unsupported"
expected_hash="$(one_metadata_value "$hash_key")"
[ "${#expected_hash}" -eq 64 ] || fail "the release-bound CLI hash is invalid"
case "$expected_hash" in *[!0-9a-f]*) fail "the release-bound CLI hash is invalid" ;; esac
[ "$(file_hash "$candidate_cli")" = "$expected_hash" ] || fail "the release-bound CLI failed SHA-256 verification"
chmod 700 "$candidate_cli"

: "${HOME:?HOME is required}"
case "$HOME" in /*) ;; *) fail "HOME must be an absolute path" ;; esac
space_home="$HOME/.shimpz"
managed_dir="$space_home/bin"
managed_cli="$managed_dir/shimpz"
candidate_target="$managed_dir/shimpz.candidate"
previous_cli="$managed_dir/shimpz.previous"
[ ! -L "$space_home" ] && { [ ! -e "$space_home" ] || [ -d "$space_home" ]; } ||
	fail "the Local Space directory is invalid"
mkdir -p "$managed_dir"
chmod 700 "$space_home" "$managed_dir"
[ ! -L "$managed_dir" ] && [ -d "$managed_dir" ] || fail "the managed CLI directory is invalid"
[ ! -e "$previous_cli" ] || fail "a previous bootstrap compensation artifact remains"
if [ -e "$managed_cli" ]; then
	[ -f "$managed_cli" ] && [ ! -L "$managed_cli" ] || fail "the managed CLI artifact is invalid"
	mv "$managed_cli" "$previous_cli"
fi
cp "$candidate_cli" "$candidate_target"
chmod 700 "$candidate_target"
mv "$candidate_target" "$managed_cli"
activated=1

printf '  [..] Installing the release-bound Shimpz Space\n'
"$managed_cli" install --release "$release_ref"

public_dir="$HOME/.local/bin"
public_cli="$public_dir/shimpz"
mkdir -p "$public_dir"
[ ! -L "$public_dir" ] && [ -d "$public_dir" ] || fail "the public CLI directory is invalid"
if [ -L "$public_cli" ]; then
	[ "$(readlink "$public_cli")" = "$managed_cli" ] || fail "an unowned public shimpz command already exists"
elif [ -e "$public_cli" ]; then
	fail "an unowned public shimpz command already exists"
else
	ln -s "$managed_cli" "$public_cli"
fi
rm -f "$previous_cli"
activated=0

printf '  [ok] Shimpz Space installation completed successfully.\n'
case ":$PATH:" in *":$public_dir:"*) ;; *) printf '  [i] Add %s to PATH to use shimpz in a new terminal.\n' "$public_dir" ;; esac
