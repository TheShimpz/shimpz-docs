#!/bin/sh

set -eu

INSTALLER_VERSION="0.2.0-dev"
IMAGE_REPOSITORY="ghcr.io/roxygens/shimpz-space"
IMAGE_CHANNEL="dev"
PROJECT_NAME="shimpz-space"
MARKER_VALUE="shimpz-space-managed-v1"

usage() {
	cat <<'EOF'
Install the Shimpz Space development channel.

Usage:
  install.sh             Install or safely update Shimpz Space
  install.sh --reset     Stop Shimpz Space and delete its local data
  install.sh --version   Print the installer version
  install.sh --help      Show this help

Environment:
  SHIMPZ_PORT            Loopback port for the Admin (default: 7777)

Supported hosts:
  Linux amd64 with Docker Engine and Docker Compose v2.
  Apple Silicon macOS arm64 with Docker Desktop and Docker Compose v2.
EOF
}

die() {
	printf 'shimpz-space: %s\n' "$*" >&2
	exit 1
}

case "${1:-}" in
	"") action="install" ;;
	--reset) action="reset" ;;
	--version)
		printf '%s\n' "$INSTALLER_VERSION"
		exit 0
		;;
	--help|-h)
		usage
		exit 0
		;;
	*)
		usage >&2
		die "unknown option: $1"
		;;
esac
[ "$#" -le 1 ] || die "only one option may be supplied"

command -v docker >/dev/null 2>&1 || die "Docker is required: https://docs.docker.com/get-started/get-docker/"
docker compose version >/dev/null 2>&1 || die "Docker Compose v2 is required"
docker info >/dev/null 2>&1 || die "the Docker daemon is not available to this user"

[ -n "${HOME:-}" ] || die "HOME must be set"
case "$HOME" in
	/*) ;;
	*) die "HOME must be an absolute path" ;;
esac

SHIMPZ_HOME="${HOME}/.shimpz"
COMPOSE_FILE="${SHIMPZ_HOME}/compose.yaml"
ENV_FILE="${SHIMPZ_HOME}/.env"
MARKER_FILE="${SHIMPZ_HOME}/.shimpz-space"

install_port="${SHIMPZ_PORT:-7777}"
unset SHIMPZ_SPACE_IMAGE SHIMPZ_SPACE_PLATFORM SHIMPZ_PORT

compose() {
	docker compose --project-name "$PROJECT_NAME" --env-file "$ENV_FILE" -f "$COMPOSE_FILE" "$@"
}

if [ "$action" = "reset" ]; then
	[ -f "$MARKER_FILE" ] || die "refusing reset: ${SHIMPZ_HOME} is not managed by this installer"
	[ "$(sed -n '1p' "$MARKER_FILE")" = "$MARKER_VALUE" ] || die "refusing reset: invalid install marker"
	if [ -f "$COMPOSE_FILE" ] && [ -f "$ENV_FILE" ]; then
		compose down --volumes --remove-orphans
	fi
	rm -f \
		"$COMPOSE_FILE" "$ENV_FILE" "$MARKER_FILE" \
		"${COMPOSE_FILE}.previous" "${ENV_FILE}.previous" \
		"${COMPOSE_FILE}.tmp" "${ENV_FILE}.tmp"
	rmdir "$SHIMPZ_HOME" 2>/dev/null || true
	printf 'Shimpz Space data was removed from %s.\n' "$SHIMPZ_HOME"
	exit 0
fi

host_os="$(uname -s)"
host_arch="$(uname -m)"
case "${host_os}:${host_arch}" in
	Linux:x86_64|Linux:amd64) docker_platform="linux/amd64" ;;
	Darwin:arm64) docker_platform="linux/arm64" ;;
	Darwin:*) die "this development installer supports Apple Silicon Macs only" ;;
	Linux:*) die "this development installer supports Linux amd64 only" ;;
	*) die "supported hosts are Linux amd64 and Apple Silicon macOS arm64" ;;
esac

case "$install_port" in
	""|*[!0-9]*) die "SHIMPZ_PORT must be an integer between 1024 and 65535" ;;
esac
[ "$install_port" -ge 1024 ] 2>/dev/null && [ "$install_port" -le 65535 ] 2>/dev/null \
	|| die "SHIMPZ_PORT must be an integer between 1024 and 65535"

if [ -e "$SHIMPZ_HOME" ] && [ ! -f "$MARKER_FILE" ]; then
	die "refusing to use existing unowned directory: ${SHIMPZ_HOME}"
fi
if [ -f "$MARKER_FILE" ]; then
	[ "$(sed -n '1p' "$MARKER_FILE")" = "$MARKER_VALUE" ] || die "invalid install marker in ${SHIMPZ_HOME}"
fi

umask 077
mkdir -p "$SHIMPZ_HOME"
chmod 700 "$SHIMPZ_HOME"
printf '%s\n' "$MARKER_VALUE" >"$MARKER_FILE"
chmod 600 "$MARKER_FILE"

tag_ref="${IMAGE_REPOSITORY}:${IMAGE_CHANNEL}"
printf 'Pulling %s...\n' "$tag_ref"
docker pull --platform "$docker_platform" "$tag_ref"

pulled_platform="$(docker image inspect --format '{{.Os}}/{{.Architecture}}' "$tag_ref")"
[ "$pulled_platform" = "$docker_platform" ] \
	|| die "Docker loaded ${pulled_platform} instead of required platform ${docker_platform}"

digest_ref="$({ docker image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' "$tag_ref" || true; } \
	| sed -n "s|^${IMAGE_REPOSITORY}@\(sha256:[0-9a-f][0-9a-f]*\)$|\1|p" \
	| head -n 1)"
digest_hex="${digest_ref#sha256:}"
case "$digest_hex" in
	""|*[!0-9a-f]*) die "Docker did not return a valid registry digest for ${tag_ref}" ;;
esac
[ "${#digest_hex}" -eq 64 ] || die "Docker returned a malformed registry digest for ${tag_ref}"
image_ref="${IMAGE_REPOSITORY}@${digest_ref}"

had_previous=0
if [ -f "$COMPOSE_FILE" ] && [ -f "$ENV_FILE" ]; then
	cp "$COMPOSE_FILE" "${COMPOSE_FILE}.previous"
	cp "$ENV_FILE" "${ENV_FILE}.previous"
	had_previous=1
fi

cat >"${ENV_FILE}.tmp" <<EOF
SHIMPZ_SPACE_IMAGE=${image_ref}
SHIMPZ_SPACE_PLATFORM=${docker_platform}
SHIMPZ_PORT=${install_port}
EOF
chmod 600 "${ENV_FILE}.tmp"

cat >"${COMPOSE_FILE}.tmp" <<'COMPOSE'
name: shimpz-space

services:
  admin:
    image: ${SHIMPZ_SPACE_IMAGE:?installer must pin SHIMPZ_SPACE_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "1000:1000"
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    ports:
      - "127.0.0.1:${SHIMPZ_PORT:-7777}:4600"
    volumes:
      - config:/repo
      - data:/data
    tmpfs:
      - /tmp:rw,noexec,nosuid,nodev,size=32m
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:4600/api/session', timeout=2).read()"]
      interval: 5s
      timeout: 3s
      retries: 24
      start_period: 5s
    cpus: "2.0"
    mem_limit: 512m
    pids_limit: 128
    stop_grace_period: 15s
    networks:
      - egress

volumes:
  config:
  data:

networks:
  egress:
    driver: bridge
COMPOSE
chmod 600 "${COMPOSE_FILE}.tmp"
mv "${ENV_FILE}.tmp" "$ENV_FILE"
mv "${COMPOSE_FILE}.tmp" "$COMPOSE_FILE"

printf 'Starting Shimpz Space...\n'
if ! compose up -d --wait --wait-timeout 120 --no-build --pull never; then
	printf 'The new release did not become healthy.\n' >&2
	compose down --remove-orphans >/dev/null 2>&1 || true
	if [ "$had_previous" -eq 1 ]; then
		printf 'Restoring the previous working release...\n' >&2
		mv "${ENV_FILE}.previous" "$ENV_FILE"
		mv "${COMPOSE_FILE}.previous" "$COMPOSE_FILE"
		compose up -d --wait --wait-timeout 120 --no-build --pull never \
			|| die "rollback also failed; inspect with: docker compose -p ${PROJECT_NAME} logs"
	fi
	die "installation failed"
fi

rm -f "${ENV_FILE}.previous" "${COMPOSE_FILE}.previous"
printf '\nShimpz Space is ready: http://127.0.0.1:%s\n' "$install_port"
printf 'Open that address and create an Admin password with at least 12 characters.\n'
printf 'Installed immutable image: %s\n' "$image_ref"
printf 'Reset command: curl -fsSL https://install.shimpz.com | sh -s -- --reset\n'
