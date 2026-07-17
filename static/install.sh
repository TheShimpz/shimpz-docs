#!/bin/sh

set -eu

INSTALLER_VERSION="0.3.1-dev"
IMAGE_REPOSITORY="ghcr.io/roxygens/shimpz-space"
ADMIN_CHANNEL="dev"
CONTROLLER_CHANNEL="capsule-driver-local-dev"
PROJECT_NAME="shimpz-space"
MARKER_VALUE="shimpz-space-managed-v1"
LOCAL_PROFILE="single-owner-local-v1"
SPACE_LABEL="com.shimpz.local.space-id"

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

brand_line() {
	art_line "" "  " "$@"
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
	# The title-case wordmark is generated with FIGlet's "big" font to match the bold mono logo.
	logo_color="${OUT_BOLD}${OUT_WHITE}"
	brand_line "" "           " "$OUT_CYAN" "⠤⣤⢬" "$OUT_WHITE" "⣶⣶⣤⣄⣀"
	brand_line "" "       " "$OUT_CYAN" "⢀⣤⡖⠚⠉⠉⠁" "$OUT_WHITE" " ⠈⠉⠉⠛⠳⣵⣤⡀"
	brand_line "" "      " "$OUT_CYAN" "⡠⠖⠉⠠⡤⠤⡀" "$OUT_WHITE" "       ⠈⠁⠙⢦" "" "           " "$logo_color" "  _____ _     _"
	brand_line "" "    " "$OUT_CYAN" "⡰⢋" "$OUT_WHITE" "⣤⣶⣶⣤⡀" "$OUT_CYAN" " ⠈⢢" "$OUT_WHITE" "       ⣤⣄⣀ ⠈⠣" "" "        " "$logo_color" " / ____| |   (_)"
	brand_line "" "   " "$OUT_CYAN" "⢀⠃" "$OUT_WHITE" "⡾⢁⣠⣀⠙⣿⠂ " "$OUT_CYAN" "⢸" "$OUT_WHITE" "  ⢀⣼⣿⡿⠿⠿⠿⣷⣶⣶⣦" "$OUT_MAGENTA" "⡀" "" "       " "$logo_color" "| (___ | |__  _ _ __ ___  _ __ ____"
	brand_line "" "   " "$OUT_CYAN" "⠘⡌" "$OUT_WHITE" "⣷⣾⠋ ⡶   " "$OUT_CYAN" "⢸" "$OUT_WHITE" "  ⢿⣿⠁⢤⣒⠢      ⠉" "$OUT_MAGENTA" "⠨⠁" "" "    " "$logo_color" " \___ \| '_ \| | '_ \` _ \| '_ \_  /"
	brand_line "" "   " "$OUT_CYAN" "⣠⠗" "$OUT_WHITE" "⠘⢿⣷⣄⣉   " "$OUT_CYAN" "⠈⠢⡀" "$OUT_WHITE" "⠈⠻⢿⣿⣧⢆⣴⡶⣤⣤" "" "         " "$logo_color" " ____) | | | | | | | | | | |_) / /"
	brand_line "$OUT_CYAN" "⣀⣴⡊⠁" "$OUT_WHITE" "   ⠈⠛⠋     " "$OUT_CYAN" "⠈⠢" "$OUT_WHITE" "  ⠁⢀⣽⣿⣶⣮⣧⣇" "" "        " "$logo_color" "|_____/|_| |_|_|_| |_| |_| .__/___|"
	brand_line "" "  " "$OUT_CYAN" "⠉⠑⢄" "$OUT_WHITE" "      ⢧⡀      ⣴⣿⣿⣿⣿⣿⣿⣿⣇" "" "       " "$logo_color" "                         | |"
	brand_line "" "     " "$OUT_CYAN" "⠁" "$OUT_MAGENTA" "⠒⠢⡀" "$OUT_WHITE" "   ⠙⠦⡀   ⠘⣿⣮⣿⣛⣿⣿⣛⣛⣛" "" "       " "$logo_color" "                         |_|"
	brand_line "" "        " "$OUT_MAGENTA" "⠈⠢⡀ ⢢" "$OUT_WHITE" " ⠈⠲⣄⣀ ⠈⢿⣿⡿⠟⠉⠉" "$OUT_MAGENTA" "⢀⠆" "" "       " "$OUT_DIM$subtitle_color" "$subtitle"
	brand_line "" "          " "$OUT_MAGENTA" "⠈⠂ ⠑⡄" "$OUT_WHITE" "  ⠙⣇      " "$OUT_MAGENTA" "⣀⠎"
	brand_line "" "              " "$OUT_MAGENTA" "⡇" "$OUT_WHITE" "   ⠈⠆    " "$OUT_MAGENTA" "⠉"
	printf '\n'
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
	printf '  %s%s[ok]%s %s\n' "$OUT_BOLD" "$OUT_GREEN" "$OUT_RESET" "$*"
}

warn() {
	printf '  %s%s[warn]%s %s\n' "$ERR_BOLD" "$ERR_YELLOW" "$ERR_RESET" "$*" >&2
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
	printf '  %s%s[error]%s Shimpz could not continue: %s\n' "$ERR_BOLD" "$ERR_RED" "$ERR_RESET" "$*" >&2
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
if [ -n "${DOCKER_HOST:-}" ]; then
	docker_endpoint="$DOCKER_HOST"
else
	docker_context="$(docker context show 2>/dev/null)" \
		|| die "could not determine the active Docker context"
	[ -n "$docker_context" ] || die "could not determine the active Docker context"
	docker_endpoint="$(docker context inspect --format '{{.Endpoints.docker.Host}}' "$docker_context" 2>/dev/null)" \
		|| die "could not inspect the active Docker context"
fi
case "$docker_endpoint" in
	unix:///*) ;;
	*) die "a local Docker Unix socket is required; remote Docker contexts are not supported" ;;
esac
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
unset SHIMPZ_ADMIN_IMAGE SHIMPZ_CONTROLLER_IMAGE SHIMPZ_SPACE_PLATFORM SHIMPZ_PORT
unset SHIMPZ_DOCKER_GID SHIMPZ_DOCKER_SOCKET SHIMPZ_SPACE_ID SHIMPZ_CPUSET

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

validate_space_id() {
	space_value="$1"
	space_hex="${space_value#space-}"
	[ "$space_hex" != "$space_value" ] || die "invalid Shimpz Space identity"
	case "$space_hex" in
		""|*[!0-9a-f]*) die "invalid Shimpz Space identity" ;;
	esac
	[ "${#space_hex}" -eq 24 ] || die "invalid Shimpz Space identity"
}

generated_space_id() {
	[ -r /dev/urandom ] || die "could not access the system random source"
	space_hex="$(od -An -N12 -tx1 /dev/urandom 2>/dev/null | tr -d ' \n')" \
		|| die "could not generate the Shimpz Space identity"
	case "$space_hex" in
		""|*[!0-9a-f]*) die "could not generate the Shimpz Space identity" ;;
	esac
	[ "${#space_hex}" -eq 24 ] || die "could not generate the Shimpz Space identity"
	printf 'space-%s\n' "$space_hex"
}

space_id_from_env_file() {
	[ -f "$ENV_FILE" ] || return 1
	space_lines="$(sed -n 's/^SHIMPZ_SPACE_ID=//p' "$ENV_FILE")"
	[ -n "$space_lines" ] || return 1
	[ "$(printf '%s\n' "$space_lines" | wc -l | tr -d ' ')" -eq 1 ] || die "invalid Shimpz Space identity"
	validate_space_id "$space_lines"
	printf '%s\n' "$space_lines"
}

validate_official_digest_image() {
	image_value="$1"
	image_digest="${image_value#"${IMAGE_REPOSITORY}@sha256:"}"
	[ "$image_digest" != "$image_value" ] \
		|| die "refusing reset: a managed container does not use the official digest-pinned image"
	case "$image_digest" in
		""|*[!0-9a-f]*) die "refusing reset: a managed image digest is invalid" ;;
	esac
	[ "${#image_digest}" -eq 64 ] || die "refusing reset: a managed image digest is invalid"
}

validate_project_resources() {
	container_ids="$(project_container_ids)" || die "could not inspect existing Shimpz Space containers"
	volume_ids="$(project_volume_ids)" || die "could not inspect existing Shimpz Space volumes"
	network_ids="$(project_network_ids)" || die "could not inspect existing Shimpz Space networks"
	admin_seen=0
	controller_seen=0
	controller_id=""
	controller_space_id=""
	for resource_id in $container_ids; do
		container_record="$(docker inspect --type=container --format '{{.Name}}|{{index .Config.Labels "com.docker.compose.service"}}|{{.Config.Image}}' "$resource_id")" \
			|| die "could not verify managed Shimpz Space container ${resource_id}"
		container_name="${container_record%%|*}"
		container_rest="${container_record#*|}"
		container_service="${container_rest%%|*}"
		container_image="${container_rest#*|}"
		validate_official_digest_image "$container_image"
		case "${container_name}|${container_service}" in
			"/${PROJECT_NAME}-admin-1|admin")
				[ "$admin_seen" -eq 0 ] || die "refusing reset: duplicate managed Admin container"
				admin_seen=1
				;;
			"/${PROJECT_NAME}-capsule-driver-local-1|capsule-driver-local")
				[ "$controller_seen" -eq 0 ] || die "refusing reset: duplicate managed controller container"
				controller_seen=1
				controller_id="$resource_id"
				controller_space_lines="$(docker inspect --type=container --format '{{range .Config.Env}}{{println .}}{{end}}' "$resource_id" \
					| sed -n 's/^SHIMPZ_SPACE_ID=//p')" \
					|| die "could not inspect the managed controller identity"
				[ "$(printf '%s\n' "$controller_space_lines" | wc -l | tr -d ' ')" -eq 1 ] \
					|| die "refusing reset: managed controller has an ambiguous Space identity"
				validate_space_id "$controller_space_lines"
				controller_space_id="$controller_space_lines"
				;;
			*) die "refusing reset: the Compose project contains an unknown container" ;;
		esac
	done
	for resource_id in $volume_ids; do
		volume_record="$(docker volume inspect --format '{{.Name}}|{{index .Labels "com.docker.compose.volume"}}' "$resource_id")" \
			|| die "could not verify managed Shimpz Space volume ${resource_id}"
		case "$volume_record" in
			"${PROJECT_NAME}_config|config"|"${PROJECT_NAME}_data|data"|\
			"${PROJECT_NAME}_controller_token|controller_token"|\
			"${PROJECT_NAME}_controller_audit|controller_audit"|\
			"${PROJECT_NAME}_controller_storage|controller_storage") ;;
			*) die "refusing reset: the Compose project contains an unknown volume" ;;
		esac
	done
	for resource_id in $network_ids; do
		network_record="$(docker network inspect --format '{{.Name}}|{{index .Labels "com.docker.compose.network"}}' "$resource_id")" \
			|| die "could not verify managed Shimpz Space network ${resource_id}"
		case "$network_record" in
			"${PROJECT_NAME}_egress|egress"|"${PROJECT_NAME}_control|control") ;;
			*) die "refusing reset: the Compose project contains an unknown network" ;;
		esac
	done
}

dynamic_container_ids() {
	docker ps --all --quiet --filter "label=${SPACE_LABEL}=${reset_space_id}"
}

dynamic_network_ids() {
	docker network ls --quiet --filter "label=${SPACE_LABEL}=${reset_space_id}"
}

validate_dynamic_resources() {
	dynamic_container_ids_value="$(dynamic_container_ids)" || die "could not inspect managed Assistant containers"
	dynamic_network_ids_value="$(dynamic_network_ids)" || die "could not inspect managed Capsule networks"
	for resource_id in $dynamic_container_ids_value; do
		dynamic_record="$(docker inspect --type=container --format '{{.Name}}|{{index .Config.Labels "com.shimpz.local.managed"}}|{{index .Config.Labels "com.shimpz.local.profile"}}|{{index .Config.Labels "com.shimpz.local.space-id"}}|{{index .Config.Labels "com.shimpz.local.kind"}}|{{index .Config.Labels "com.shimpz.local.capsule-id"}}|{{index .Config.Labels "com.shimpz.local.assistant-id"}}' "$resource_id")" \
			|| die "could not verify managed Assistant container ${resource_id}"
		dynamic_name="${dynamic_record%%|*}"
		dynamic_rest="${dynamic_record#*|}"
		managed_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		profile_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		space_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		kind_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		capsule_value="${dynamic_rest%%|*}"
		assistant_value="${dynamic_rest#*|}"
		[ "$managed_value" = "1" ] && [ "$profile_value" = "$LOCAL_PROFILE" ] \
			&& [ "$space_value" = "$reset_space_id" ] && [ "$kind_value" = "assistant" ] \
			|| die "refusing reset: a Space-labeled container has invalid ownership labels"
		case "$dynamic_name" in "/shimpz-local-"*) ;; *) die "refusing reset: invalid managed Assistant name" ;; esac
		case "$capsule_value" in ""|*[!a-z0-9_]*) die "refusing reset: invalid managed Capsule id" ;; esac
		[ "${#capsule_value}" -le 40 ] || die "refusing reset: invalid managed Capsule id"
		case "$assistant_value" in ""|*[!a-z0-9-]*) die "refusing reset: invalid managed Assistant id" ;; esac
		case "$assistant_value" in [a-z]*) ;; *) die "refusing reset: invalid managed Assistant id" ;; esac
		case "$assistant_value" in *--*|*-) die "refusing reset: invalid managed Assistant id" ;; esac
		[ "${#assistant_value}" -le 48 ] || die "refusing reset: invalid managed Assistant id"
	done
	for resource_id in $dynamic_network_ids_value; do
		dynamic_record="$(docker network inspect --format '{{.Name}}|{{index .Labels "com.shimpz.local.managed"}}|{{index .Labels "com.shimpz.local.profile"}}|{{index .Labels "com.shimpz.local.space-id"}}|{{index .Labels "com.shimpz.local.kind"}}|{{index .Labels "com.shimpz.local.capsule-id"}}' "$resource_id")" \
			|| die "could not verify managed Capsule network ${resource_id}"
		dynamic_name="${dynamic_record%%|*}"
		dynamic_rest="${dynamic_record#*|}"
		managed_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		profile_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		space_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		kind_value="${dynamic_rest%%|*}"
		capsule_value="${dynamic_rest#*|}"
		[ "$managed_value" = "1" ] && [ "$profile_value" = "$LOCAL_PROFILE" ] \
			&& [ "$space_value" = "$reset_space_id" ] && [ "$kind_value" = "capsule" ] \
			|| die "refusing reset: a Space-labeled network has invalid ownership labels"
		case "$dynamic_name" in "shimpz-local-"*) ;; *) die "refusing reset: invalid managed Capsule network name" ;; esac
		case "$capsule_value" in ""|*[!a-z0-9_]*) die "refusing reset: invalid managed Capsule id" ;; esac
		[ "${#capsule_value}" -le 40 ] || die "refusing reset: invalid managed Capsule id"
	done
}

reset_dynamic_space() {
	[ -n "$controller_id" ] || {
		[ -z "${dynamic_container_ids_value}${dynamic_network_ids_value}" ] \
			|| die "refusing reset: managed Capsule resources exist without their controller"
		return 0
	}
	controller_running="$(docker inspect --type=container --format '{{.State.Running}}' "$controller_id")" \
		|| die "could not inspect the managed controller state"
	if [ "$controller_running" != "true" ]; then
		docker start "$controller_id" >/dev/null || die "could not start the managed controller for reset"
	fi
	step "Resetting Capsules and Assistants through the authenticated controller"
	reset_attempt=0
	while [ "$reset_attempt" -lt 30 ]; do
		if docker exec "$controller_id" /opt/venv/bin/python -c 'import http.client,json,pathlib; token=pathlib.Path("/run/shimpz-local/token").read_text(encoding="ascii"); connection=http.client.HTTPConnection("127.0.0.1",7077,timeout=5); connection.request("DELETE","/v1/space",headers={"Authorization":"Bearer "+token,"Content-Length":"0"}); response=connection.getresponse(); body=response.read(32769); document=json.loads(body); valid=response.status==200 and len(body)<=32768 and isinstance(document,dict) and document.get("reset") is True; connection.close(); raise SystemExit(0 if valid else 1)' >/dev/null 2>&1; then
			break
		fi
		reset_attempt=$((reset_attempt + 1))
		sleep 1
	done
	[ "$reset_attempt" -lt 30 ] || die "the authenticated Capsule reset did not complete"
	dynamic_container_ids_value="$(dynamic_container_ids)" || die "could not verify Assistant reset"
	dynamic_network_ids_value="$(dynamic_network_ids)" || die "could not verify Capsule reset"
	[ -z "${dynamic_container_ids_value}${dynamic_network_ids_value}" ] \
		|| die "the authenticated reset left managed Capsule resources"
}

remove_validated_project_resources() {
	for resource_id in $container_ids; do
		docker rm --force "$resource_id" >/dev/null
	done
	for resource_id in $network_ids; do
		docker network rm "$resource_id" >/dev/null
	done
	for resource_id in $volume_ids; do
		docker volume rm "$resource_id" >/dev/null
	done
}

if [ "$action" = "reset" ]; then
	notice "This permanently removes local Admin, Capsule, and Assistant data"
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
	validate_project_resources
	reset_space_id="$(space_id_from_env_file || true)"
	if [ -n "$controller_space_id" ]; then
		if [ -n "$reset_space_id" ]; then
			[ "$reset_space_id" = "$controller_space_id" ] \
				|| die "refusing reset: local state and controller Space identities differ"
		else
			reset_space_id="$controller_space_id"
		fi
	fi
	if [ -n "$reset_space_id" ]; then
		validate_space_id "$reset_space_id"
		validate_dynamic_resources
		reset_dynamic_space
	fi
	if [ -f "$COMPOSE_FILE" ] && [ -f "$ENV_FILE" ]; then
		step "Stopping Shimpz Space and removing Docker data"
		compose down --volumes --remove-orphans
	elif [ -n "${container_ids}${volume_ids}${network_ids}" ]; then
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
	printf '  Data     Managed Space, Capsule, and Assistant Docker data was removed\n'
	printf '  Files    Known installer files were removed from %s\n' "$SHIMPZ_HOME"
	printf '  Install  curl -fsSL https://install.shimpz.com | sh\n'
	exit 0
fi

host_os="$(uname -s)"
host_arch="$(uname -m)"
case "${host_os}:${host_arch}" in
	Linux:x86_64|Linux:amd64)
		docker_platform="linux/amd64"
		docker_socket_candidates="/var/run/docker.sock"
		;;
	Darwin:arm64)
		docker_platform="linux/arm64"
		docker_socket_candidates="/var/run/docker.sock.raw /var/run/docker.sock"
		;;
	Darwin:*) die "this development installer supports Apple Silicon Macs only" ;;
	Linux:*) die "this development installer supports Linux amd64 only" ;;
	*) die "supported hosts are Linux amd64 and Apple Silicon macOS arm64" ;;
esac

[ -S /var/run/docker.sock ] || die "Docker must expose /var/run/docker.sock"

daemon_processors="$(docker info --format '{{.NCPU}}')" || die "could not read Docker CPU availability"
case "$daemon_processors" in
	""|*[!0-9]*) die "Docker returned an invalid CPU count" ;;
esac
[ "$daemon_processors" -ge 1 ] || die "Docker returned an invalid CPU count"
half_processors=$((daemon_processors / 2))
[ "$half_processors" -ge 1 ] || half_processors=1
if [ "$half_processors" -eq 1 ]; then
	docker_cpuset="0"
else
	docker_cpuset="0-$((half_processors - 1))"
fi

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
	space_id="$(space_id_from_env_file || true)"
	[ -n "$space_id" ] || space_id="$(generated_space_id)"
else
	install_mode="install"
	info "Installing a fresh Shimpz Space"
	space_id="$(generated_space_id)"
fi
validate_space_id "$space_id"
if project_resources_exist; then
	step "Validating the existing managed runtime"
	validate_project_resources
	if [ -n "$controller_space_id" ]; then
		[ "$controller_space_id" = "$space_id" ] \
			|| die "existing controller and local Space identities differ"
	fi
	reset_space_id="$space_id"
	validate_dynamic_resources
fi

umask 077
mkdir -p "$SHIMPZ_HOME"
chmod 700 "$SHIMPZ_HOME"
printf '%s\n' "$MARKER_VALUE" >"$MARKER_FILE"
chmod 600 "$MARKER_FILE"

pull_verified_ref() {
	tag_ref="$1"
	docker pull --quiet --platform "$docker_platform" "$tag_ref" >/dev/null
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
	printf '%s@%s\n' "$IMAGE_REPOSITORY" "$digest_ref"
}

optional_env_value() {
	env_key="$1"
	env_path="$2"
	env_lines="$(sed -n "s/^${env_key}=//p" "$env_path")"
	[ -n "$env_lines" ] || return 0
	[ "$(printf '%s\n' "$env_lines" | wc -l | tr -d ' ')" -eq 1 ] \
		|| die "the previous release has duplicate ${env_key} values"
	printf '%s\n' "$env_lines"
}

validate_pinned_release_ref() {
	release_ref="$1"
	release_digest="${release_ref#"${IMAGE_REPOSITORY}@sha256:"}"
	[ "$release_digest" != "$release_ref" ] || die "the previous release is not pinned to the official image"
	case "$release_digest" in
		""|*[!0-9a-f]*) die "the previous release has an invalid image digest" ;;
	esac
	[ "${#release_digest}" -eq 64 ] || die "the previous release has a malformed image digest"
}

load_previous_release() {
	previous_platform="$(optional_env_value SHIMPZ_SPACE_PLATFORM "${ENV_FILE}.previous")"
	[ "$previous_platform" = "$docker_platform" ] \
		|| die "the previous release targets a different Docker platform"
	previous_admin_ref="$(optional_env_value SHIMPZ_ADMIN_IMAGE "${ENV_FILE}.previous")"
	previous_legacy_ref="$(optional_env_value SHIMPZ_SPACE_IMAGE "${ENV_FILE}.previous")"
	[ -z "$previous_admin_ref" ] || [ -z "$previous_legacy_ref" ] \
		|| die "the previous release has ambiguous Admin image values"
	[ -n "$previous_admin_ref" ] || previous_admin_ref="$previous_legacy_ref"
	[ -n "$previous_admin_ref" ] || die "the previous release is missing its Admin image"
	previous_controller_ref="$(optional_env_value SHIMPZ_CONTROLLER_IMAGE "${ENV_FILE}.previous")"
	validate_pinned_release_ref "$previous_admin_ref"
	if [ -n "$previous_controller_ref" ]; then
		validate_pinned_release_ref "$previous_controller_ref"
	fi
}

ensure_pinned_release_ref() {
	pinned_ref="$1"
	pinned_platform="$2"
	loaded_platform=""
	if docker image inspect "$pinned_ref" >/dev/null 2>&1; then
		loaded_platform="$(docker image inspect --format '{{.Os}}/{{.Architecture}}' "$pinned_ref")" || return 1
	fi
	if [ "$loaded_platform" != "$pinned_platform" ]; then
		docker pull --quiet --platform "$pinned_platform" "$pinned_ref" >/dev/null || return 1
		loaded_platform="$(docker image inspect --format '{{.Os}}/{{.Architecture}}' "$pinned_ref")" || return 1
	fi
	[ "$loaded_platform" = "$pinned_platform" ] || return 1
	resolved_ref="$({ docker image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' "$pinned_ref" || true; } \
		| grep -F -x "$pinned_ref" | head -n 1)"
	[ "$resolved_ref" = "$pinned_ref" ]
}

hydrate_previous_release() {
	ensure_pinned_release_ref "$previous_admin_ref" "$previous_platform" || return 1
	if [ -n "$previous_controller_ref" ]; then
		ensure_pinned_release_ref "$previous_controller_ref" "$previous_platform" || return 1
	fi
}

controller_socket_gid() {
	controller_ref="$1"
	docker run --rm \
		--platform "$docker_platform" --pull never \
		--network none --read-only --cap-drop ALL --security-opt no-new-privileges:true \
		--cpuset-cpus "$docker_cpuset" --cpus 0.25 --memory 64m --memory-swap 64m --pids-limit 32 \
		--tmpfs /tmp:rw,noexec,nosuid,nodev,size=8m \
		--mount "type=bind,src=${docker_socket_source},dst=/var/run/docker.sock,readonly" \
		--entrypoint /opt/venv/bin/python \
		"$controller_ref" -c 'import os; print(os.stat("/var/run/docker.sock").st_gid)'
}

controller_can_reach_docker() {
	controller_ref="$1"
	controller_gid="$2"
	docker run --rm \
		--platform "$docker_platform" --pull never \
		--network none --read-only --cap-drop ALL --security-opt no-new-privileges:true \
		--group-add "$controller_gid" \
		--cpuset-cpus "$docker_cpuset" --cpus 0.25 --memory 64m --memory-swap 64m --pids-limit 32 \
		--tmpfs /tmp:rw,noexec,nosuid,nodev,size=8m \
		--mount "type=bind,src=${docker_socket_source},dst=/var/run/docker.sock" \
		--entrypoint /opt/venv/bin/python \
		"$controller_ref" -c 'import socket; connection=socket.socket(socket.AF_UNIX); connection.settimeout(5); connection.connect("/var/run/docker.sock"); connection.sendall(b"GET /_ping HTTP/1.0\r\nHost: docker\r\n\r\n"); status=connection.recv(128).split(b"\r\n",1)[0]; connection.close(); raise SystemExit(0 if status in {b"HTTP/1.0 200 OK",b"HTTP/1.1 200 OK"} else 1)' \
		>/dev/null 2>&1
}

admin_tag_ref="${IMAGE_REPOSITORY}:${ADMIN_CHANNEL}"
controller_tag_ref="${IMAGE_REPOSITORY}:${CONTROLLER_CHANNEL}"
step "Pulling and verifying the Admin development image"
admin_image_ref="$(pull_verified_ref "$admin_tag_ref")"
step "Pulling and verifying the local Capsule controller image"
controller_image_ref="$(pull_verified_ref "$controller_tag_ref")"
step "Verifying local Docker access for the Capsule controller"
docker_socket_source=""
docker_socket_gid=""
for socket_candidate in $docker_socket_candidates; do
	if candidate_gid="$(docker_socket_source="$socket_candidate" controller_socket_gid "$controller_image_ref" 2>/dev/null)"; then
		case "$candidate_gid" in ""|*[!0-9]*) continue ;; esac
		if docker_socket_source="$socket_candidate" controller_can_reach_docker "$controller_image_ref" "$candidate_gid"; then
			docker_socket_source="$socket_candidate"
			docker_socket_gid="$candidate_gid"
			break
		fi
	fi
done
[ -n "$docker_socket_source" ] && [ -n "$docker_socket_gid" ] \
	|| die "the Capsule controller cannot access Docker; check Docker Desktop socket permissions or Enhanced Container Isolation"

had_previous=0
if [ -f "$COMPOSE_FILE" ] && [ -f "$ENV_FILE" ]; then
	cp "$COMPOSE_FILE" "${COMPOSE_FILE}.previous"
	cp "$ENV_FILE" "${ENV_FILE}.previous"
	had_previous=1
	load_previous_release
	step "Pinning the previous release for safe rollback"
	hydrate_previous_release || die "the previous pinned release could not be prepared; the running version was not changed"
fi

cat >"${ENV_FILE}.tmp" <<EOF
SHIMPZ_ADMIN_IMAGE=${admin_image_ref}
SHIMPZ_CONTROLLER_IMAGE=${controller_image_ref}
SHIMPZ_SPACE_PLATFORM=${docker_platform}
SHIMPZ_PORT=${install_port}
SHIMPZ_DOCKER_GID=${docker_socket_gid}
SHIMPZ_DOCKER_SOCKET=${docker_socket_source}
SHIMPZ_SPACE_ID=${space_id}
SHIMPZ_CPUSET=${docker_cpuset}
EOF
chmod 600 "${ENV_FILE}.tmp"

cat >"${COMPOSE_FILE}.tmp" <<'COMPOSE'
name: shimpz-space

services:
  capsule-driver-local:
    image: ${SHIMPZ_CONTROLLER_IMAGE:?installer must pin SHIMPZ_CONTROLLER_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "10001:10001"
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    group_add:
      - "${SHIMPZ_DOCKER_GID:?installer must bind the Docker socket group}"
    environment:
      SHIMPZ_SPACE_ID: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}
    volumes:
      - ${SHIMPZ_DOCKER_SOCKET:?installer must bind the platform Docker socket}:/var/run/docker.sock:rw
      - controller_token:/run/shimpz-local:rw
      - controller_audit:/var/log/shimpz-local:rw
      - controller_storage:/var/lib/shimpz-local/storage:rw
    tmpfs:
      - /tmp:rw,noexec,nosuid,nodev,size=32m
    cpuset: "${SHIMPZ_CPUSET:?installer must limit local CPUs}"
    cpus: "1.0"
    mem_limit: 256m
    memswap_limit: 256m
    pids_limit: 128
    stop_grace_period: 15s
    logging:
      driver: json-file
      options:
        max-size: "1m"
        max-file: "2"
    networks:
      - control

  admin:
    image: ${SHIMPZ_ADMIN_IMAGE:?installer must pin SHIMPZ_ADMIN_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "1000:1000"
    group_add:
      - "10010"
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    ports:
      - "127.0.0.1:${SHIMPZ_PORT:-7777}:4600"
    environment:
      SHIMPZ_CAPSULEDRIVER_URL: http://capsule-driver-local:7077
      SHIMPZ_CAPSULEDRIVER_TOKEN_FILE: /run/shimpz-local/token
      SHIMPZ_CAPSULE_CREDENTIALS_ENABLED: "0"
    volumes:
      - config:/repo
      - data:/data
      - controller_token:/run/shimpz-local:ro
    tmpfs:
      - /tmp:rw,noexec,nosuid,nodev,size=32m
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:4600/api/session', timeout=2).read()"]
      interval: 5s
      timeout: 3s
      retries: 24
      start_period: 5s
    cpus: "2.0"
    cpuset: "${SHIMPZ_CPUSET:?installer must limit local CPUs}"
    mem_limit: 512m
    memswap_limit: 512m
    pids_limit: 128
    stop_grace_period: 15s
    depends_on:
      capsule-driver-local:
        condition: service_healthy
    logging:
      driver: json-file
      options:
        max-size: "1m"
        max-file: "2"
    networks:
      - control
      - egress

volumes:
  config:
  data:
  controller_token:
  controller_audit:
  controller_storage:

networks:
  control:
    driver: bridge
    internal: true
  egress:
    driver: bridge
COMPOSE
chmod 600 "${COMPOSE_FILE}.tmp"
mv "${ENV_FILE}.tmp" "$ENV_FILE"
mv "${COMPOSE_FILE}.tmp" "$COMPOSE_FILE"

step "Starting the Shimpz Admin and local Capsule controller"
if ! compose up -d --wait --wait-timeout 120 --no-build --pull never; then
	warn "The new release did not become healthy"
	compose logs --no-color --tail 20 capsule-driver-local >&2 || true
	if [ "$had_previous" -eq 1 ]; then
		step "Verifying the previous pinned release"
		if ! hydrate_previous_release; then
			mv "${ENV_FILE}.previous" "$ENV_FILE"
			mv "${COMPOSE_FILE}.previous" "$COMPOSE_FILE"
			die "the candidate failed and rollback images could not be verified; previous files were restored without deleting Docker data"
		fi
	fi
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
printf '  AdminImg %s\n' "$admin_image_ref"
printf '  Control  %s\n' "$controller_image_ref"
printf '  Reset    curl -fsSL https://install.shimpz.com | sh -s -- --reset\n'
