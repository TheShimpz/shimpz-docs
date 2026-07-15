#!/bin/sh

set -eu

INSTALLER_VERSION="0.2.4-dev"
IMAGE_REPOSITORY="ghcr.io/roxygens/shimpz-space"
IMAGE_CHANNEL="dev"
PROJECT_NAME="shimpz-space"
MARKER_VALUE="shimpz-space-managed-v1"

OUT_RESET=""
OUT_BOLD=""
OUT_DIM=""
OUT_CYAN=""
OUT_MAGENTA=""
OUT_WHITE=""
OUT_GREEN=""
OUT_YELLOW=""
ERR_RESET=""
ERR_BOLD=""
ERR_RED=""
ERR_YELLOW=""

setup_colors() {
	[ "${TERM:-dumb}" != "dumb" ] || return 0
	[ -z "${NO_COLOR+x}" ] || return 0
	escape="$(printf '\033')"
	if [ -t 1 ]; then
		OUT_RESET="${escape}[0m"
		OUT_BOLD="${escape}[1m"
		OUT_DIM="${escape}[2m"
		OUT_CYAN="${escape}[38;2;0;215;254m"
		OUT_MAGENTA="${escape}[38;2;248;28;124m"
		OUT_WHITE="${escape}[38;2;252;252;252m"
		OUT_GREEN="${escape}[32m"
		OUT_YELLOW="${escape}[33m"
	fi
	if [ -t 2 ]; then
		ERR_RESET="${escape}[0m"
		ERR_BOLD="${escape}[1m"
		ERR_RED="${escape}[31m"
		ERR_YELLOW="${escape}[33m"
	fi
	return 0
}

art_line() {
	while [ "$#" -gt 0 ]; do
		printf '%s%s' "$1" "$2"
		shift 2
	done
	printf '%s\n' "$OUT_RESET"
}

show_brand() {
	case "$1" in
		reset)
			subtitle="safe reset // local data"
			subtitle_color="$OUT_MAGENTA"
			;;
		*)
			subtitle="space installer // dev"
			subtitle_color="$OUT_CYAN"
			;;
	esac
	# Static terminal rendering authored with Chafa from the canonical friendly-v2 symbol:
	# SHA-256 06d35d9b33c712fe17aef5569e40395b0780860948fa62bf03bd3ee48741f93b.
	art_line "" "           " "$OUT_CYAN" "⠤⣤⢬" "$OUT_WHITE" "⣶⣶⣤⣄⣀"
	art_line "" "       " "$OUT_CYAN" "⢀⣤⡖⠚⠉⠉⠁" "$OUT_WHITE" " ⠈⠉⠉⠛⠳⣵⣤⡀"
	art_line "" "      " "$OUT_CYAN" "⡠⠖⠉⠠⡤⠤⡀" "$OUT_WHITE" "       ⠈⠁⠙⢦"
	art_line "" "    " "$OUT_CYAN" "⡰⢋" "$OUT_WHITE" "⣤⣶⣶⣤⡀" "$OUT_CYAN" " ⠈⢢" "$OUT_WHITE" "       ⣤⣄⣀ ⠈⠣"
	art_line "" "   " "$OUT_CYAN" "⢀⠃" "$OUT_WHITE" "⡾⢁⣠⣀⠙⣿⠂ " "$OUT_CYAN" "⢸" "$OUT_WHITE" "  ⢀⣼⣿⡿⠿⠿⠿⣷⣶⣶⣦" "$OUT_MAGENTA" "⡀"
	art_line "" "   " "$OUT_CYAN" "⠘⡌" "$OUT_WHITE" "⣷⣾⠋ ⡶   " "$OUT_CYAN" "⢸" "$OUT_WHITE" "  ⢿⣿⠁⢤⣒⠢      ⠉" "$OUT_MAGENTA" "⠨⠁"
	art_line "" "   " "$OUT_CYAN" "⣠⠗" "$OUT_WHITE" "⠘⢿⣷⣄⣉   " "$OUT_CYAN" "⠈⠢⡀" "$OUT_WHITE" "⠈⠻⢿⣿⣧⢆⣴⡶⣤⣤"
	art_line "$OUT_CYAN" "⣀⣴⡊⠁" "$OUT_WHITE" "   ⠈⠛⠋     " "$OUT_CYAN" "⠈⠢" "$OUT_WHITE" "  ⠁⢀⣽⣿⣶⣮⣧⣇"
	art_line "" "  " "$OUT_CYAN" "⠉⠑⢄" "$OUT_WHITE" "      ⢧⡀      ⣴⣿⣿⣿⣿⣿⣿⣿⣇"
	art_line "" "     " "$OUT_CYAN" "⠁" "$OUT_MAGENTA" "⠒⠢⡀" "$OUT_WHITE" "   ⠙⠦⡀   ⠘⣿⣮⣿⣛⣿⣿⣛⣛⣛"
	art_line "" "        " "$OUT_MAGENTA" "⠈⠢⡀ ⢢" "$OUT_WHITE" " ⠈⠲⣄⣀ ⠈⢿⣿⡿⠟⠉⠉" "$OUT_MAGENTA" "⢀⠆"
	art_line "" "          " "$OUT_MAGENTA" "⠈⠂ ⠑⡄" "$OUT_WHITE" "  ⠙⣇      " "$OUT_MAGENTA" "⣀⠎"
	art_line "" "              " "$OUT_MAGENTA" "⡇" "$OUT_WHITE" "   ⠈⠆    " "$OUT_MAGENTA" "⠉"
	printf '\n       %s//%s %s%sShimpz%s %s//%s\n' \
		"$OUT_CYAN" "$OUT_RESET" "$OUT_BOLD" "$OUT_WHITE" "$OUT_RESET" "$OUT_MAGENTA" "$OUT_RESET"
	printf '   %s%s%s%s\n\n' "$OUT_DIM" "$subtitle_color" "$subtitle" "$OUT_RESET"
}

step() {
	printf '  %s[..]%s %s\n' "$OUT_DIM" "$OUT_RESET" "$*"
}

info() {
	printf '  %s[i]%s %s\n' "$OUT_CYAN" "$OUT_RESET" "$*"
}

notice() {
	printf '  %s%s[!]%s %s\n' "$OUT_BOLD" "$OUT_YELLOW" "$OUT_RESET" "$*"
}

success() {
	printf '%s%s[ok]%s %s\n' "$OUT_BOLD" "$OUT_GREEN" "$OUT_RESET" "$*"
}

warn() {
	printf '%s%s[warn]%s %s\n' "$ERR_BOLD" "$ERR_YELLOW" "$ERR_RESET" "$*" >&2
}

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
	printf '%s%s[error]%s Shimpz could not continue: %s\n' "$ERR_BOLD" "$ERR_RED" "$ERR_RESET" "$*" >&2
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

setup_colors
show_brand "$action"
step "Checking Docker and Compose"

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
	docker compose --progress quiet --project-name "$PROJECT_NAME" --env-file "$ENV_FILE" -f "$COMPOSE_FILE" "$@"
}

project_container_ids() {
	docker ps --all --quiet --filter "label=com.docker.compose.project=${PROJECT_NAME}"
}

project_volume_ids() {
	docker volume ls --quiet --filter "label=com.docker.compose.project=${PROJECT_NAME}"
}

project_network_ids() {
	docker network ls --quiet --filter "label=com.docker.compose.project=${PROJECT_NAME}"
}

project_resources_exist() {
	container_ids="$(project_container_ids)" || die "could not inspect existing Shimpz Space containers"
	volume_ids="$(project_volume_ids)" || die "could not inspect existing Shimpz Space volumes"
	network_ids="$(project_network_ids)" || die "could not inspect existing Shimpz Space networks"
	[ -n "${container_ids}${volume_ids}${network_ids}" ]
}

validate_orphaned_project_resources() {
	container_ids="$(project_container_ids)" || die "could not inspect existing Shimpz Space containers"
	volume_ids="$(project_volume_ids)" || die "could not inspect existing Shimpz Space volumes"
	network_ids="$(project_network_ids)" || die "could not inspect existing Shimpz Space networks"
	for resource_id in $container_ids; do
		container_record="$(docker inspect --type=container --format '{{.Name}}|{{index .Config.Labels "com.docker.compose.service"}}|{{.Config.Image}}' "$resource_id")" \
			|| die "could not verify orphaned Shimpz Space container ${resource_id}"
		container_name="${container_record%%|*}"
		container_rest="${container_record#*|}"
		container_service="${container_rest%%|*}"
		container_image="${container_rest#*|}"
		[ "$container_name" = "/${PROJECT_NAME}-admin-1" ] && [ "$container_service" = "admin" ] \
			|| die "refusing reset: the orphaned Compose project contains an unknown container"
		container_digest="${container_image#"${IMAGE_REPOSITORY}@sha256:"}"
		[ "$container_digest" != "$container_image" ] \
			|| die "refusing reset: the orphaned Admin does not use the official digest-pinned image"
		case "$container_digest" in
			""|*[!0-9a-f]*) die "refusing reset: the orphaned Admin image digest is invalid" ;;
		esac
		[ "${#container_digest}" -eq 64 ] \
			|| die "refusing reset: the orphaned Admin image digest is invalid"
	done
	for resource_id in $volume_ids; do
		volume_record="$(docker volume inspect --format '{{.Name}}|{{index .Labels "com.docker.compose.volume"}}' "$resource_id")" \
			|| die "could not verify orphaned Shimpz Space volume ${resource_id}"
		case "$volume_record" in
			"${PROJECT_NAME}_config|config"|"${PROJECT_NAME}_data|data") ;;
			*) die "refusing reset: the orphaned Compose project contains an unknown volume" ;;
		esac
	done
	for resource_id in $network_ids; do
		network_record="$(docker network inspect --format '{{.Name}}|{{index .Labels "com.docker.compose.network"}}' "$resource_id")" \
			|| die "could not verify orphaned Shimpz Space network ${resource_id}"
		[ "$network_record" = "${PROJECT_NAME}_egress|egress" ] \
			|| die "refusing reset: the orphaned Compose project contains an unknown network"
	done
}

remove_validated_project_resources() {
	for resource_id in $container_ids; do
		docker rm --force "$resource_id" >/dev/null
	done
	for resource_id in $volume_ids; do
		docker volume rm "$resource_id" >/dev/null
	done
	for resource_id in $network_ids; do
		docker network rm "$resource_id" >/dev/null
	done
}

if [ "$action" = "reset" ]; then
	notice "This permanently removes local Admin data"
	step "Validating managed Docker resources"
	managed_state=0
	if [ -f "$MARKER_FILE" ]; then
		[ "$(sed -n '1p' "$MARKER_FILE")" = "$MARKER_VALUE" ] \
			|| die "refusing reset: invalid install marker"
		managed_state=1
	elif [ -e "$SHIMPZ_HOME" ]; then
		die "refusing reset: ${SHIMPZ_HOME} exists without a valid install marker"
	fi
	if project_resources_exist; then
		managed_state=1
	fi
	[ "$managed_state" -eq 1 ] || die "no managed Shimpz Space installation was found"
	if [ -f "$COMPOSE_FILE" ] && [ -f "$ENV_FILE" ]; then
		step "Stopping Admin and removing Docker data"
		compose down --volumes --remove-orphans
	elif [ -n "${container_ids}${volume_ids}${network_ids}" ]; then
		# With the local marker/config gone, do a complete read-only ownership preflight before the
		# first deletion. Unknown resources sharing the generic Compose project label fail closed.
		validate_orphaned_project_resources
		step "Removing verified orphaned Docker data"
		remove_validated_project_resources
	fi
	if project_resources_exist; then
		die "reset left unexpected Shimpz Space Docker resources; inspect them before retrying"
	fi
	rm -f \
		"$COMPOSE_FILE" "$ENV_FILE" "$MARKER_FILE" \
		"${COMPOSE_FILE}.previous" "${ENV_FILE}.previous" \
		"${COMPOSE_FILE}.tmp" "${ENV_FILE}.tmp"
	rmdir "$SHIMPZ_HOME" 2>/dev/null || true
	printf '\n'
	success "Shimpz Space was reset"
	printf '  Data     Managed Admin Docker data was removed\n'
	printf '  Files    Known installer files were removed from %s\n' "$SHIMPZ_HOME"
	printf '  Install  curl -fsSL https://install.shimpz.com | sh\n'
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
if [ ! -f "$MARKER_FILE" ] && project_resources_exist; then
	die "an earlier Shimpz installation still has Docker data. Nothing was changed. Reset it first with: curl -fsSL https://install.shimpz.com | sh -s -- --reset"
fi

if [ -f "$MARKER_FILE" ]; then
	install_mode="update"
	info "Updating Shimpz Space; your Admin data will be preserved"
else
	install_mode="install"
	info "Installing a fresh Shimpz Space"
fi

umask 077
mkdir -p "$SHIMPZ_HOME"
chmod 700 "$SHIMPZ_HOME"
printf '%s\n' "$MARKER_VALUE" >"$MARKER_FILE"
chmod 600 "$MARKER_FILE"

tag_ref="${IMAGE_REPOSITORY}:${IMAGE_CHANNEL}"
step "Pulling the verified development image"
docker pull --quiet --platform "$docker_platform" "$tag_ref" >/dev/null

step "Verifying the immutable image digest"
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

step "Starting the Shimpz Admin"
if ! compose up -d --wait --wait-timeout 120 --no-build --pull never; then
	warn "The new release did not become healthy"
	compose down --remove-orphans >/dev/null || true
	if [ "$had_previous" -eq 1 ]; then
		step "Restoring the previous pinned release"
		mv "${ENV_FILE}.previous" "$ENV_FILE"
		mv "${COMPOSE_FILE}.previous" "$COMPOSE_FILE"
		compose up -d --wait --wait-timeout 120 --no-build --pull never \
			|| die "rollback also failed; inspect with: (cd \"${SHIMPZ_HOME}\" && docker compose -p ${PROJECT_NAME} logs)"
		warn "Previous version restored; your Admin data was preserved"
		die "the update failed, so Shimpz is still running the previous version"
	fi
	die "installation failed"
fi

rm -f "${ENV_FILE}.previous" "${COMPOSE_FILE}.previous"
printf '\n'
if [ "$install_mode" = "update" ]; then
	success "Shimpz Space is up to date"
	printf '  Admin    %shttp://127.0.0.1:%s%s\n' "$OUT_CYAN" "$install_port" "$OUT_RESET"
	printf '  Data     Admin settings and password were preserved\n'
else
	success "Shimpz Space is ready"
	printf '  Admin    %shttp://127.0.0.1:%s%s\n' "$OUT_CYAN" "$install_port" "$OUT_RESET"
	printf '  Next     Create an Admin password with at least 12 characters\n'
fi
printf '  Image    %s\n' "$image_ref"
printf '  Reset    curl -fsSL https://install.shimpz.com | sh -s -- --reset\n'
