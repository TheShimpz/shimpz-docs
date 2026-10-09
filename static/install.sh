#!/bin/sh

set -eu

BOOTSTRAP_VERSION="2.0.0"
RELEASE_REPOSITORY="ghcr.io/theshimpz/shimpz-local-release"
RELEASE_CHANNEL="stable"
# The public half of the key that signs every published Local release (ADR-0103); the Local CLI pins the same key.
RELEASE_SIGNING_KEY='-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEsiSmhIGW2Txt7M3SuXQEEJZWqPQj
lNkkH59ClG3czSQKkziiKEvnRwYqaVYk5Yosa6AUalFtdQz5XknSlGHPLw==
-----END PUBLIC KEY-----'

fail() {
	printf '  [error] Shimpz could not continue: %s\n' "$*" >&2
	exit 1
}

confirm_public_replace() {
	[ -r /dev/tty ] && [ -w /dev/tty ] || return 1
	printf 'A different command exists at %s. Replace only that entry? [Yes/No] ' "$public_cli" >/dev/tty
	IFS= read -r answer </dev/tty || return 1
	[ "$answer" = "Yes" ]
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
  Linux amd64.
  64-bit Windows through Ubuntu on WSL2 with systemd.
  Apple Silicon macOS arm64.
  Docker Engine 25.0+, Docker Compose 2.20.2+, and /usr/bin/openssl are required.
EOF
}

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

stale_docker_session() {
	[ "$(uname -s)" = "Linux" ] || return 1
	[ -S /var/run/docker.sock ] || return 1
	[ -x /usr/bin/id ] && [ -x /usr/bin/stat ] || return 1
	candidate_group="$(/usr/bin/stat -c '%G' /var/run/docker.sock)"
	[ -n "$candidate_group" ] && [ "$candidate_group" != UNKNOWN ] || return 1
	account_name="$(/usr/bin/id -un)"
	# shellcheck disable=SC2046 # Intentional group-list tokenization from fixed id output.
	has_group "$candidate_group" $(/usr/bin/id -Gn "$account_name") || return 1
	# shellcheck disable=SC2046 # Intentional group-list tokenization from fixed id output.
	! has_group "$candidate_group" $(/usr/bin/id -Gn)
}

resolve_docker_access() {
	"$docker" info >/dev/null 2>&1 && return 0
	# The Local CLI records this session's primary group as the encrypted volume owner, and its scheduled updates
	# run in the login manager, so a group switch here would install a Space that later updates cannot open.
	stale_docker_session &&
		fail "this login session does not include the Docker group yet; sign out and back in (or restart), confirm docker version works without sudo, then run the installer again"
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
		"$docker" rm --volumes "$container_id" >/dev/null 2>&1 || true
	fi
	[ ! -d "${temporary:-}" ] || rm -rf "$temporary"
	exit "$status"
}

# Nothing runs until the final line, so a truncated download executes no partial bootstrap.
main() {
	case "${1:-}" in
		"") ;;
		--help|-h) usage; exit 0 ;;
		--version) printf '%s\n' "$BOOTSTRAP_VERSION"; exit 0 ;;
		*) usage >&2; fail "unknown option: $1" ;;
	esac
	[ "$#" -le 1 ] || fail "the bootstrap accepts at most one option"

	resolve_host
	if [ "$(uname -s)" = "Linux" ] && [ "$(/usr/bin/id -g)" != "$(/usr/bin/id -g "$(/usr/bin/id -un)")" ]; then
		fail "run the installer from a normal login session, not a switched group such as sg docker; sign out and back in so the session includes the Docker group, then run it again"
	fi
	docker="$(resolve_docker)" || fail "Docker is not installed in a supported system path"
	resolve_docker_access || fail "Docker is not running or this user cannot access it"
	"$docker" compose version >/dev/null 2>&1 || fail "Docker Compose v2 is unavailable"
	[ -x /usr/bin/openssl ] || fail "OpenSSL is required at /usr/bin/openssl to verify the Local release signature"

	temporary="$(mktemp -d "${TMPDIR:-/tmp}/shimpz-bootstrap.XXXXXX")"
	chmod 700 "$temporary"
	container_id=""
	trap cleanup EXIT HUP INT TERM

	printf '  [..] Resolving the atomic Local release\n'
	selector="$RELEASE_REPOSITORY:$RELEASE_CHANNEL"
	"$docker" pull --quiet --platform "$platform" "$selector" >/dev/null 2>&1 || fail "Docker could not download the stable Local release; verify access to ghcr.io and retry"
	release_ref=""
	for candidate in $("$docker" image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' "$selector" 2>/dev/null); do
		if valid_digest_ref "$candidate"; then
			[ -z "$release_ref" ] || fail "Docker returned ambiguous Local release digests"
			release_ref="$candidate"
		fi
	done
	[ -n "$release_ref" ] || fail "Docker returned no trusted Local release digest"

	container_id="$("$docker" create --platform "$platform" "$release_ref" "$member" 2>/dev/null)" || fail "Docker could not create a temporary Local release container; verify Docker storage and retry"
	case "$container_id" in *[!0-9a-f]*|"") fail "Docker returned an invalid temporary Local release container; retry the installation" ;; esac
	release_metadata="$temporary/release.env"
	candidate_cli="$temporary/shimpz"
	"$docker" cp "$container_id:/release.env" "$release_metadata" >/dev/null 2>&1 || fail "Docker could not extract the Local release metadata; verify Docker storage and retry"
	"$docker" cp "$container_id:$member" "$candidate_cli" >/dev/null 2>&1 || fail "Docker could not extract the Shimpz CLI; verify Docker storage and retry"
	"$docker" rm --volumes "$container_id" >/dev/null 2>&1 || fail "Docker could not remove its temporary Local release container; retry the installation"
	container_id=""
	for copied in "$release_metadata" "$candidate_cli"; do
		[ -f "$copied" ] && [ ! -L "$copied" ] || fail "the Local release carries a file of an invalid type; do not install this release"
	done
	[ "$(wc -c < "$release_metadata" | tr -d ' ')" -le 2048 ] || fail "the atomic release metadata is not closed"

	# Nothing from the release is trusted before its signature over the exact metadata and state epoch label verifies.
	labels="$("$docker" image inspect --format '{{index .Config.Labels "org.shimpz.local.state-epoch"}}|{{index .Config.Labels "org.shimpz.local.release-signature"}}' "$release_ref" 2>/dev/null)" ||
		fail "Docker could not read the Local release labels; retry the installation"
	{ cat "$release_metadata"; printf 'state_epoch=%s\n' "${labels%%|*}"; } >"$temporary/release.signed"
	printf '%s\n' "$RELEASE_SIGNING_KEY" >"$temporary/release-key.pem"
	printf '%s' "${labels#*|}" | /usr/bin/openssl base64 -d -A >"$temporary/release.sig" 2>/dev/null &&
		/usr/bin/openssl dgst -sha256 -verify "$temporary/release-key.pem" -signature "$temporary/release.sig" "$temporary/release.signed" >/dev/null 2>&1 ||
		fail "the Local release signature is invalid; do not install this release"

	[ "$(wc -l < "$release_metadata" | tr -d ' ')" -eq 10 ] || fail "the atomic release metadata is not closed"
	[ "$(one_metadata_value schema)" = "local-v2" ] || fail "the atomic release schema is unsupported"
	expected_hash="$(one_metadata_value "$hash_key")"
	[ "${#expected_hash}" -eq 64 ] || fail "the release-bound CLI hash is invalid"
	case "$expected_hash" in *[!0-9a-f]*) fail "the release-bound CLI hash is invalid" ;; esac
	[ "$(file_hash "$candidate_cli")" = "$expected_hash" ] || fail "the release-bound CLI failed SHA-256 verification"
	chmod 700 "$candidate_cli"

	: "${HOME:?HOME is required}"
	case "$HOME" in /*) ;; *) fail "HOME must be an absolute path" ;; esac
	"$candidate_cli" --version >/dev/null 2>&1 ||
		fail "the release-bound CLI cannot run from ${TMPDIR:-/tmp}; set TMPDIR to a private directory that allows execution and retry"

	# The release-bound CLI activates itself as ~/.shimpz/bin/shimpz only under its lifecycle lock and after admission.
	printf '  [..] Installing the release-bound Shimpz Space\n'
	"$candidate_cli" install "$release_ref"

	managed_cli="$HOME/.shimpz/bin/shimpz"
	[ -f "$managed_cli" ] && [ ! -L "$managed_cli" ] && [ -x "$managed_cli" ] ||
		fail "the release-bound CLI did not install the managed command at $managed_cli"
	public_dir="$HOME/.local/bin"
	public_cli="$public_dir/shimpz"
	mkdir -p "$public_dir"
	[ ! -L "$public_dir" ] && [ -d "$public_dir" ] || fail "the public CLI directory is invalid"
	if [ -L "$public_cli" ]; then
		if [ "$(readlink "$public_cli")" != "$managed_cli" ]; then
			if confirm_public_replace; then
				rm -f "$public_cli"
				ln -s "$managed_cli" "$public_cli"
			else
				printf '  [i] Preserved the existing command at %s; use %s directly.\n' "$public_cli" "$managed_cli"
			fi
		fi
	elif [ -e "$public_cli" ]; then
		if confirm_public_replace; then
			rm -f "$public_cli"
			ln -s "$managed_cli" "$public_cli"
		else
			printf '  [i] Preserved the existing command at %s; use %s directly.\n' "$public_cli" "$managed_cli"
		fi
	else
		ln -s "$managed_cli" "$public_cli"
	fi

	printf '  [ok] Shimpz Space installation completed successfully.\n'
	case ":$PATH:" in *":$public_dir:"*) ;; *) printf '  [i] Add %s to PATH to use shimpz in a new terminal.\n' "$public_dir" ;; esac
}

main "$@"
