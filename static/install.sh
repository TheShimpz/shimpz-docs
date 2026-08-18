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
	for candidate in /usr/bin/docker /Applications/Docker.app/Contents/Resources/bin/docker /usr/local/bin/docker /opt/homebrew/bin/docker; do
		if [ -x "$candidate" ] && [ ! -L "$candidate" ]; then
			printf '%s\n' "$candidate"
			return 0
		fi
	done
	return 1
}

has_group() {
	wanted_group="$1"
	shift
	for available_group in "$@"; do
		[ "$available_group" != "$wanted_group" ] || return 0
	done
	return 1
}

run_command() {
	if [ -z "${docker_group:-}" ]; then
		"$@"
		return
	fi
	case "$#" in
		1) SHIMPZ_RUN_0="$1" /usr/bin/sg "$docker_group" -c 'exec "$SHIMPZ_RUN_0"' ;;
		2) SHIMPZ_RUN_0="$1" SHIMPZ_RUN_1="$2" /usr/bin/sg "$docker_group" -c 'exec "$SHIMPZ_RUN_0" "$SHIMPZ_RUN_1"' ;;
		3) SHIMPZ_RUN_0="$1" SHIMPZ_RUN_1="$2" SHIMPZ_RUN_2="$3" /usr/bin/sg "$docker_group" -c 'exec "$SHIMPZ_RUN_0" "$SHIMPZ_RUN_1" "$SHIMPZ_RUN_2"' ;;
		4) SHIMPZ_RUN_0="$1" SHIMPZ_RUN_1="$2" SHIMPZ_RUN_2="$3" SHIMPZ_RUN_3="$4" /usr/bin/sg "$docker_group" -c 'exec "$SHIMPZ_RUN_0" "$SHIMPZ_RUN_1" "$SHIMPZ_RUN_2" "$SHIMPZ_RUN_3"' ;;
		5) SHIMPZ_RUN_0="$1" SHIMPZ_RUN_1="$2" SHIMPZ_RUN_2="$3" SHIMPZ_RUN_3="$4" SHIMPZ_RUN_4="$5" /usr/bin/sg "$docker_group" -c 'exec "$SHIMPZ_RUN_0" "$SHIMPZ_RUN_1" "$SHIMPZ_RUN_2" "$SHIMPZ_RUN_3" "$SHIMPZ_RUN_4"' ;;
		6) SHIMPZ_RUN_0="$1" SHIMPZ_RUN_1="$2" SHIMPZ_RUN_2="$3" SHIMPZ_RUN_3="$4" SHIMPZ_RUN_4="$5" SHIMPZ_RUN_5="$6" /usr/bin/sg "$docker_group" -c 'exec "$SHIMPZ_RUN_0" "$SHIMPZ_RUN_1" "$SHIMPZ_RUN_2" "$SHIMPZ_RUN_3" "$SHIMPZ_RUN_4" "$SHIMPZ_RUN_5"' ;;
		*) fail "internal command handoff has an unsupported argument count" ;;
	esac
}

resolve_docker_access() {
	docker_group=""
	"$docker" info >/dev/null 2>&1 && return 0
	[ "$(uname -s)" = "Linux" ] || return 1
	[ -S /var/run/docker.sock ] || return 1
	[ -x /usr/bin/id ] && [ -x /usr/bin/stat ] && [ -x /usr/bin/sg ] || return 1
	candidate_group="$(/usr/bin/stat -c '%G' /var/run/docker.sock)"
	[ -n "$candidate_group" ] && [ "$candidate_group" != UNKNOWN ] || return 1
	account_name="$(/usr/bin/id -un)"
	# shellcheck disable=SC2046 # Intentional group-list tokenization from fixed id output.
	has_group "$candidate_group" $(/usr/bin/id -Gn "$account_name") || return 1
	# shellcheck disable=SC2046 # Intentional group-list tokenization from fixed id output.
	has_group "$candidate_group" $(/usr/bin/id -Gn) && return 1
	docker_group="$candidate_group"
	run_command "$docker" info >/dev/null 2>&1
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
		run_command "$docker" rm "$container_id" >/dev/null 2>&1 || true
	fi
	if [ "$status" -ne 0 ] && [ "${activated:-0}" -eq 1 ]; then
		[ ! -e "$managed_cli" ] || rm -f "$managed_cli"
		[ ! -e "$previous_cli" ] || mv "$previous_cli" "$managed_cli"
	fi
	if [ -n "${candidate_target:-}" ] && [ -f "$candidate_target" ] && [ ! -L "$candidate_target" ]; then
		rm -f "$candidate_target"
	fi
	[ ! -d "${temporary:-}" ] || rm -rf "$temporary"
	exit "$status"
}

resolve_host
docker="$(resolve_docker)" || fail "Docker is not installed in a supported system path"
resolve_docker_access || fail "Docker is not running or this user cannot access it"
run_command "$docker" compose version >/dev/null 2>&1 || fail "Docker Compose v2 is unavailable"

temporary="$(mktemp -d "${TMPDIR:-/tmp}/shimpz-bootstrap.XXXXXX")"
chmod 700 "$temporary"
container_id=""
activated=0
trap cleanup EXIT HUP INT TERM

printf '  [..] Resolving the atomic Local release\n'
selector="$RELEASE_REPOSITORY:$RELEASE_CHANNEL"
run_command "$docker" pull --quiet --platform "$platform" "$selector" >/dev/null
release_ref=""
for candidate in $(run_command "$docker" image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' "$selector"); do
	if valid_digest_ref "$candidate"; then
		[ -z "$release_ref" ] || fail "Docker returned ambiguous Local release digests"
		release_ref="$candidate"
	fi
done
[ -n "$release_ref" ] || fail "Docker returned no trusted Local release digest"

container_id="$(run_command "$docker" create --platform "$platform" "$release_ref" "$member")"
case "$container_id" in *[!0-9a-f]*|"") fail "Docker returned an invalid temporary container" ;; esac
release_metadata="$temporary/release.env"
candidate_cli="$temporary/shimpz"
run_command "$docker" cp "$container_id:/release.env" "$release_metadata" >/dev/null
run_command "$docker" cp "$container_id:$member" "$candidate_cli" >/dev/null
run_command "$docker" rm "$container_id" >/dev/null
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
if [ -e "$previous_cli" ] || [ -L "$previous_cli" ]; then
	[ -f "$previous_cli" ] && [ ! -L "$previous_cli" ] ||
		fail "the previous bootstrap compensation artifact is invalid"
	if [ -e "$managed_cli" ] || [ -L "$managed_cli" ]; then
		[ -f "$managed_cli" ] && [ ! -L "$managed_cli" ] ||
			fail "the managed CLI artifact is invalid"
		if [ "$(file_hash "$managed_cli")" = "$expected_hash" ]; then
			rm -f "$previous_cli"
		else
			rm -f "$managed_cli"
			mv "$previous_cli" "$managed_cli"
		fi
	else
		mv "$previous_cli" "$managed_cli"
	fi
fi
if [ -e "$managed_cli" ] || [ -L "$managed_cli" ]; then
	[ -f "$managed_cli" ] && [ ! -L "$managed_cli" ] || fail "the managed CLI artifact is invalid"
	mv "$managed_cli" "$previous_cli"
fi
if [ -e "$candidate_target" ] || [ -L "$candidate_target" ]; then
	[ -f "$candidate_target" ] && [ ! -L "$candidate_target" ] ||
		fail "the stale candidate CLI artifact is invalid; run shimpz reset and retry"
	rm -f "$candidate_target"
fi
cp "$candidate_cli" "$candidate_target"
chmod 700 "$candidate_target"
mv "$candidate_target" "$managed_cli"
activated=1

printf '  [..] Installing the release-bound Shimpz Space\n'
run_command "$managed_cli" install --release "$release_ref"

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
