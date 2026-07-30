#!/bin/sh

set -eu

INSTALLER_VERSION="0.6.0"
ADMIN_REPOSITORY="ghcr.io/theshimpz/shimpz-admin"
TEAM_REPOSITORY="ghcr.io/theshimpz/shimpz-team-local"
BRAIN_REPOSITORY="ghcr.io/theshimpz/shimpz-brain"
ASSISTANT_EGRESS_REPOSITORY="ghcr.io/theshimpz/shimpz-assistant-egress"
ACCOUNT_EGRESS_REPOSITORY="ghcr.io/theshimpz/shimpz-account-egress"
ADMIN_CHANNEL="stable"
TEAM_CHANNEL="stable"
BRAIN_CHANNEL="stable"
ASSISTANT_EGRESS_CHANNEL="stable"
ACCOUNT_EGRESS_CHANNEL="stable"
LOCAL_PROFILE="local-v1"
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
			subtitle="space installer // stable"
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
Install the stable Shimpz Space release.

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
PROJECT_NAME="shimpz-space"
RESERVED_CONTAINER_NAMES="shimpz-admin shimpz-team shimpz-brain shimpz-brain-egress assistant-egress account-egress account-egress-init"
SHIMPZ_HOME_NAME=".shimpz"
MARKER_VALUE="shimpz-space-managed-v1"
OAUTH_CALLBACK_MODE="loopback"
ADMIN_ALLOWED_ORIGINS="http://localhost:${SHIMPZ_PORT:-7777},http://127.0.0.1:${SHIMPZ_PORT:-7777}"
reset_command="curl -fsSL https://install.shimpz.com | sh -s -- --reset"
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

SHIMPZ_HOME="${HOME}/${SHIMPZ_HOME_NAME}"
COMPOSE_FILE="${SHIMPZ_HOME}/compose.yaml"
ENV_FILE="${SHIMPZ_HOME}/.env"
MARKER_FILE="${SHIMPZ_HOME}/.shimpz-space"
install_port="${SHIMPZ_PORT:-7777}"
unset SHIMPZ_ADMIN_IMAGE SHIMPZ_TEAM_IMAGE SHIMPZ_BRAIN_IMAGE SHIMPZ_ASSISTANT_EGRESS_IMAGE
unset SHIMPZ_ACCOUNT_EGRESS_IMAGE
unset SHIMPZ_SPACE_PLATFORM SHIMPZ_PORT
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

validate_reserved_container_names() {
	for reserved_name in $RESERVED_CONTAINER_NAMES; do
		reserved_project="$(docker inspect --type=container \
			--format '{{index .Config.Labels "com.docker.compose.project"}}' \
			"$reserved_name" 2>/dev/null)" || continue
		[ "$reserved_project" = "$PROJECT_NAME" ] \
			|| die "another Docker container is already named ${reserved_name}. Nothing was changed. Rename or remove it, then run the installer again"
	done
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

official_image_digest() {
	image_value="$1"
	image_digest=""
	for repository in \
		"$ADMIN_REPOSITORY" \
		"$TEAM_REPOSITORY" \
		"$BRAIN_REPOSITORY" \
		"$ASSISTANT_EGRESS_REPOSITORY" \
		"$ACCOUNT_EGRESS_REPOSITORY"
	do
		case "$image_value" in
			"${repository}@sha256:"*) image_digest="${image_value#"${repository}@sha256:"}"; break ;;
		esac
	done
	[ -n "$image_digest" ] || return 1
	case "$image_digest" in
		""|*[!0-9a-f]*) return 1 ;;
	esac
	[ "${#image_digest}" -eq 64 ] || return 1
	printf '%s\n' "$image_digest"
}

validate_repository_digest_image() {
	image_value="$1"
	repository="$2"
	image_digest="${image_value#"${repository}@sha256:"}"
	[ "$image_digest" != "$image_value" ] \
		|| die "refusing reset: a managed container does not use its responsibility-owned image"
	case "$image_digest" in
		""|*[!0-9a-f]*) die "refusing reset: a managed container image digest is invalid" ;;
	esac
	[ "${#image_digest}" -eq 64 ] \
		|| die "refusing reset: a managed container image digest is invalid"
}

record_controller_identity() {
	controller_id="$1"
	controller_space_lines="$(docker inspect --type=container --format '{{range .Config.Env}}{{println .}}{{end}}' "$controller_id" \
		| sed -n 's/^SHIMPZ_SPACE_ID=//p')" \
		|| die "could not inspect the managed controller identity"
	[ "$(printf '%s\n' "$controller_space_lines" | wc -l | tr -d ' ')" -eq 1 ] \
		|| die "refusing reset: managed controller has an ambiguous Space identity"
	validate_space_id "$controller_space_lines"
	controller_space_id="$controller_space_lines"
}

validate_project_resources() {
	container_ids="$(project_container_ids)" || die "could not inspect existing Shimpz Space containers"
	volume_ids="$(project_volume_ids)" || die "could not inspect existing Shimpz Space volumes"
	network_ids="$(project_network_ids)" || die "could not inspect existing Shimpz Space networks"
	admin_seen=0
	controller_seen=0
	brain_runtime_seen=0
	brain_egress_seen=0
	assistant_egress_proxy_seen=0
	account_egress_proxy_seen=0
	account_egress_init_seen=0
	admin_id=""
	controller_id=""
	controller_space_id=""
	for resource_id in $container_ids; do
		container_record="$(docker inspect --type=container --format '{{.Name}}|{{index .Config.Labels "com.docker.compose.service"}}|{{.Config.Image}}' "$resource_id")" \
			|| die "could not verify managed Shimpz Space container ${resource_id}"
		container_name="${container_record%%|*}"
		container_rest="${container_record#*|}"
		container_service="${container_rest%%|*}"
		container_image="${container_rest#*|}"
		case "${container_name}|${container_service}" in
			"/shimpz-admin|admin")
				validate_repository_digest_image "$container_image" "$ADMIN_REPOSITORY"
				[ "$admin_seen" -eq 0 ] || die "refusing reset: duplicate managed Admin container"
				admin_seen=1
				admin_id="$resource_id"
				;;
			"/shimpz-team|team")
				validate_repository_digest_image "$container_image" "$TEAM_REPOSITORY"
				[ "$controller_seen" -eq 0 ] || die "refusing reset: duplicate managed controller container"
				controller_seen=1
				record_controller_identity "$resource_id"
				;;
			"/shimpz-brain|brain")
				validate_repository_digest_image "$container_image" "$BRAIN_REPOSITORY"
				[ "$brain_runtime_seen" -eq 0 ] || die "refusing reset: duplicate managed Brain runtime container"
				brain_runtime_seen=1
				;;
			"/shimpz-brain-egress|brain-egress")
				validate_repository_digest_image "$container_image" "$BRAIN_REPOSITORY"
				[ "$brain_egress_seen" -eq 0 ] || die "refusing reset: duplicate managed Brain egress container"
				brain_egress_seen=1
				;;
			"/assistant-egress|assistant-egress")
				validate_repository_digest_image "$container_image" "$ASSISTANT_EGRESS_REPOSITORY"
				[ "$assistant_egress_proxy_seen" -eq 0 ] \
					|| die "refusing reset: duplicate managed Assistant egress proxy container"
				assistant_egress_proxy_seen=1
				;;
			"/account-egress|account-egress")
				validate_repository_digest_image "$container_image" "$ACCOUNT_EGRESS_REPOSITORY"
				[ "$account_egress_proxy_seen" -eq 0 ] \
					|| die "refusing reset: duplicate managed OAuth broker proxy container"
				account_egress_proxy_seen=1
				;;
			"/account-egress-init|account-egress-init")
				validate_repository_digest_image "$container_image" "$ACCOUNT_EGRESS_REPOSITORY"
				[ "$account_egress_init_seen" -eq 0 ] \
					|| die "refusing reset: duplicate managed Account egress initializer"
				account_egress_init_seen=1
				;;
			*) die "refusing to manage unknown Compose container ${container_name}; inspect or remove it before retrying" ;;
		esac
	done
	for resource_id in $volume_ids; do
		volume_record="$(docker volume inspect --format '{{.Name}}|{{index .Labels "com.docker.compose.volume"}}' "$resource_id")" \
			|| die "could not verify managed Shimpz Space volume ${resource_id}"
		case "$volume_record" in
			"${PROJECT_NAME}_config|config"|"${PROJECT_NAME}_data|data"|\
			"${PROJECT_NAME}_controller_token|controller_token"|\
			"${PROJECT_NAME}_controller_audit|controller_audit"|\
			"${PROJECT_NAME}_controller_storage|controller_storage"|\
			"${PROJECT_NAME}_controller_inference|controller_inference"|\
			"${PROJECT_NAME}_controller_power_journal|controller_power_journal"|\
			"${PROJECT_NAME}_controller_publications|controller_publications"|\
			"${PROJECT_NAME}_controller_assistant_integration_state|controller_assistant_integration_state"|\
			"${PROJECT_NAME}_controller_assistant_integration_key|controller_assistant_integration_key"|\
			"${PROJECT_NAME}_controller_chat_continuation_state|controller_chat_continuation_state"|\
			"${PROJECT_NAME}_controller_chat_continuation_key|controller_chat_continuation_key"|\
			"${PROJECT_NAME}_supervisor_key|supervisor_key"|\
			"${PROJECT_NAME}_account_egress_capability|account_egress_capability"|\
			"${PROJECT_NAME}_account_egress_audit|account_egress_audit"|\
			"${PROJECT_NAME}_brain_egress_audit|brain_egress_audit"|\
			"${PROJECT_NAME}_brain_runtime_token|brain_runtime_token"|\
			"${PROJECT_NAME}_brain_runtime_state|brain_runtime_state"|\
			"${PROJECT_NAME}_assistant_egress_policy|assistant_egress_policy"|\
			"${PROJECT_NAME}_assistant_egress_audit|assistant_egress_audit") ;;
			*) die "refusing reset: the Compose project contains an unknown volume" ;;
		esac
	done
	for resource_id in $network_ids; do
		network_record="$(docker network inspect --format '{{.Name}}|{{index .Labels "com.docker.compose.network"}}' "$resource_id")" \
			|| die "could not verify managed Shimpz Space network ${resource_id}"
		case "$network_record" in
			"${PROJECT_NAME}_egress|egress"|"${PROJECT_NAME}_control|control"|\
			"${PROJECT_NAME}_brain_runtime|brain_runtime"|"${PROJECT_NAME}_brain_egress|brain_egress"|\
			"${PROJECT_NAME}_brain_egress_out|brain_egress_out"|\
			"${PROJECT_NAME}_assistant_egress_out|assistant_egress_out"|\
			"${PROJECT_NAME}_account_egress|account_egress"|\
			"${PROJECT_NAME}_account_egress_out|account_egress_out") ;;
			*) die "refusing reset: the Compose project contains an unknown network" ;;
		esac
	done
}

dynamic_container_ids() {
	docker ps --all --quiet --filter "label=${SPACE_LABEL}=${reset_space_id}"
}

dynamic_assistant_container_ids() {
	docker ps --all --quiet \
		--filter "label=${SPACE_LABEL}=${reset_space_id}" \
		--filter "label=com.shimpz.local.kind=assistant"
}

dynamic_network_ids() {
	docker network ls --quiet --filter "label=${SPACE_LABEL}=${reset_space_id}"
}

validate_dynamic_resources() {
	dynamic_container_ids_value="$(dynamic_container_ids)" || die "could not inspect managed Assistant containers"
	dynamic_network_ids_value="$(dynamic_network_ids)" || die "could not inspect managed Team networks"
	dynamic_assistant_egress_seen=0
	dynamic_brain_egress_seen=0
	dynamic_account_egress_seen=0
	for resource_id in $dynamic_container_ids_value; do
		dynamic_record="$(docker inspect --type=container --format '{{.Name}}|{{index .Config.Labels "com.shimpz.local.managed"}}|{{index .Config.Labels "com.shimpz.local.profile"}}|{{index .Config.Labels "com.shimpz.local.space-id"}}|{{index .Config.Labels "com.shimpz.local.kind"}}|{{index .Config.Labels "com.shimpz.local.team-id"}}|{{index .Config.Labels "com.shimpz.local.assistant-id"}}' "$resource_id")" \
			|| die "could not verify managed Assistant container ${resource_id}"
		dynamic_name="${dynamic_record%%|*}"
		dynamic_rest="${dynamic_record#*|}"
		managed_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		profile_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		space_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		kind_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		team_value="${dynamic_rest%%|*}"
		assistant_value="${dynamic_rest#*|}"
		[ "$managed_value" = "1" ] && [ "$profile_value" = "$LOCAL_PROFILE" ] \
			&& [ "$space_value" = "$reset_space_id" ] \
			|| die "refusing reset: a Space-labeled container has invalid ownership labels"
		case "$kind_value" in
			assistant)
				case "$dynamic_name" in "/shimpz-local-"*) ;; *) die "refusing reset: invalid managed Assistant name" ;; esac
				case "$team_value" in ""|*[!a-z0-9_]*) die "refusing reset: invalid managed Team id" ;; esac
				[ "${#team_value}" -le 40 ] || die "refusing reset: invalid managed Team id"
				case "$assistant_value" in ""|*[!a-z0-9-]*) die "refusing reset: invalid managed Assistant id" ;; esac
				case "$assistant_value" in [a-z]*) ;; *) die "refusing reset: invalid managed Assistant id" ;; esac
				case "$assistant_value" in *--*|*-) die "refusing reset: invalid managed Assistant id" ;; esac
				[ "${#assistant_value}" -le 48 ] || die "refusing reset: invalid managed Assistant id"
				;;
			assistant-egress)
				case "$dynamic_name" in
					"/assistant-egress") ;;
					*) die "refusing reset: invalid managed Assistant egress proxy name" ;;
				esac
				[ "$dynamic_assistant_egress_seen" -eq 0 ] \
					|| die "refusing reset: duplicate managed Assistant egress proxy"
				dynamic_assistant_egress_seen=1
				;;
			brain-egress)
				case "$dynamic_name" in
					"/shimpz-brain-egress") ;;
					*) die "refusing reset: invalid managed Brain egress name" ;;
				esac
				[ "$dynamic_brain_egress_seen" -eq 0 ] \
					|| die "refusing reset: duplicate managed Brain egress"
				dynamic_brain_egress_seen=1
				;;
			account-egress)
				case "$dynamic_name" in
					"/account-egress") ;;
					*) die "refusing reset: invalid managed OAuth broker proxy name" ;;
				esac
				[ "$dynamic_account_egress_seen" -eq 0 ] \
					|| die "refusing reset: duplicate managed OAuth broker proxy"
				dynamic_account_egress_seen=1
				;;
			*) die "refusing reset: a Space-labeled container has invalid ownership labels" ;;
		esac
	done
	for resource_id in $dynamic_network_ids_value; do
		dynamic_record="$(docker network inspect --format '{{.Name}}|{{index .Labels "com.shimpz.local.managed"}}|{{index .Labels "com.shimpz.local.profile"}}|{{index .Labels "com.shimpz.local.space-id"}}|{{index .Labels "com.shimpz.local.kind"}}|{{index .Labels "com.shimpz.local.team-id"}}' "$resource_id")" \
			|| die "could not verify managed Team network ${resource_id}"
		dynamic_name="${dynamic_record%%|*}"
		dynamic_rest="${dynamic_record#*|}"
		managed_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		profile_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		space_value="${dynamic_rest%%|*}"; dynamic_rest="${dynamic_rest#*|}"
		kind_value="${dynamic_rest%%|*}"
		team_value="${dynamic_rest#*|}"
		[ "$managed_value" = "1" ] && [ "$profile_value" = "$LOCAL_PROFILE" ] \
			&& [ "$space_value" = "$reset_space_id" ] && [ "$kind_value" = "team" ] \
			|| die "refusing reset: a Space-labeled network has invalid ownership labels"
		case "$dynamic_name" in "shimpz-local-"*) ;; *) die "refusing reset: invalid managed Team network name" ;; esac
		case "$team_value" in ""|*[!a-z0-9_]*) die "refusing reset: invalid managed Team id" ;; esac
		[ "${#team_value}" -le 40 ] || die "refusing reset: invalid managed Team id"
	done
}

reset_dynamic_space() {
	[ -n "$controller_id" ] || {
		dynamic_assistant_container_ids_value="$(dynamic_assistant_container_ids)" \
			|| die "could not inspect managed Assistant containers"
		[ -z "${dynamic_assistant_container_ids_value}${dynamic_network_ids_value}" ] \
			|| die "refusing reset: managed Team resources exist without their controller"
		return 0
	}
	controller_running="$(docker inspect --type=container --format '{{.State.Running}}' "$controller_id")" \
		|| die "could not inspect the managed controller state"
	if [ "$controller_running" != "true" ]; then
		docker start "$controller_id" >/dev/null || die "could not start the managed controller for reset"
	fi
	[ -n "$admin_id" ] || die "the Local Supervisor is unavailable for authenticated reset"
	admin_running="$(docker inspect --type=container --format '{{.State.Running}}' "$admin_id")" \
		|| die "could not inspect the managed Admin state"
	if [ "$admin_running" != "true" ]; then
		docker start "$admin_id" >/dev/null || die "could not start the managed Admin for reset"
	fi
	[ -r /dev/tty ] && [ -w /dev/tty ] \
		|| die "authenticated reset requires an interactive terminal"
	printf '  Supervisor password: ' >/dev/tty
	terminal_state="$(stty -g </dev/tty)" || die "could not secure the password prompt"
	trap 'stty "$terminal_state" </dev/tty 2>/dev/null || true' EXIT HUP INT TERM
	stty -echo </dev/tty || die "could not secure the password prompt"
	IFS= read -r supervisor_password </dev/tty || {
		stty "$terminal_state" </dev/tty 2>/dev/null || true
		die "could not read the Supervisor password"
	}
	stty "$terminal_state" </dev/tty || die "could not restore the terminal"
	trap - EXIT HUP INT TERM
	printf '\n' >/dev/tty
	[ -n "$supervisor_password" ] || die "the Supervisor password is required"
	step "Resetting Teams and Assistants through the authenticated controller"
	if ! printf '%s\n' "$supervisor_password" | docker exec -i "$admin_id" python -c 'import auth,json,state,sys,supervisor; from team import bridge,transport; password=sys.stdin.readline(4098).removesuffix("\n"); record=state.get(); valid=bool(password) and auth.verify_password(password,record.get("salt",""),record.get("password_hash","")); identity=state.local_supervisor() if valid else None; supervisor.materialize_public_key(identity) if identity is not None else None; session=auth.issue_session(record["session_secret"],ttl=60) if valid else ""; scope=transport.supervisor_session(session,account=False,local_identity=identity) if valid else None; scope.__enter__() if scope is not None else None; response=bridge.reset_space() if scope is not None else None; scope.__exit__(None,None,None) if scope is not None else None; document=response.body if response is not None else {}; raise SystemExit(0 if response is not None and response.status==200 and isinstance(document,dict) and document.get("reset") is True else 1)' >/dev/null 2>&1; then
		unset supervisor_password
		die "the authenticated Team reset did not complete"
	fi
	unset supervisor_password
	dynamic_assistant_container_ids_value="$(dynamic_assistant_container_ids)" \
		|| die "could not verify Assistant reset"
	dynamic_network_ids_value="$(dynamic_network_ids)" || die "could not verify Team reset"
	[ -z "${dynamic_assistant_container_ids_value}${dynamic_network_ids_value}" ] \
		|| die "the authenticated reset left managed Team resources"
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
	notice "This permanently removes local Admin, Team, and Assistant data"
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
		if project_resources_exist; then
			step "Removing verified rollback leftovers"
			validate_project_resources
			remove_validated_project_resources
		fi
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
	printf '  Data     Managed Space, Team, and Assistant Docker data was removed\n'
	printf '  Files    Known installer files were removed from %s\n' "$SHIMPZ_HOME"
	printf '  Install  %s\n' "${reset_command% -s -- --reset}"
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
	Darwin:*) die "this stable installer supports Apple Silicon Macs only" ;;
	Linux:*) die "this stable installer supports Linux amd64 only" ;;
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
	die "managed Shimpz Docker data exists without an install marker. Nothing was changed. Reset it first with: ${reset_command}"
fi
validate_reserved_container_names

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
	repository="$2"
	docker pull --quiet --platform "$docker_platform" "$tag_ref" >/dev/null
	pulled_platform="$(docker image inspect --format '{{.Os}}/{{.Architecture}}' "$tag_ref")"
	[ "$pulled_platform" = "$docker_platform" ] \
		|| die "Docker loaded ${pulled_platform} instead of required platform ${docker_platform}"
	digest_ref="$({ docker image inspect --format '{{range .RepoDigests}}{{println .}}{{end}}' "$tag_ref" || true; } \
		| sed -n "s|^${repository}@\(sha256:[0-9a-f][0-9a-f]*\)$|\1|p" \
		| head -n 1)"
	digest_hex="${digest_ref#sha256:}"
	case "$digest_hex" in
		""|*[!0-9a-f]*) die "Docker did not return a valid registry digest for ${tag_ref}" ;;
	esac
	[ "${#digest_hex}" -eq 64 ] || die "Docker returned a malformed registry digest for ${tag_ref}"
	printf '%s@%s\n' "$repository" "$digest_ref"
}

previous_env_value() {
	env_key="$1"
	env_path="$2"
	env_lines="$(sed -n "s/^${env_key}=//p" "$env_path")"
	[ -n "$env_lines" ] || die "the previous release is missing ${env_key}"
	[ "$(printf '%s\n' "$env_lines" | wc -l | tr -d ' ')" -eq 1 ] \
		|| die "the previous release has duplicate ${env_key} values"
	printf '%s\n' "$env_lines"
}

validate_pinned_release_ref() {
	release_ref="$1"
	repository="$2"
	image_digest="${release_ref#"${repository}@sha256:"}"
	[ "$image_digest" != "$release_ref" ] \
		|| die "the previous release is not pinned to its responsibility-owned official image"
	case "$image_digest" in
		""|*[!0-9a-f]*) die "the previous release image digest is invalid" ;;
	esac
	[ "${#image_digest}" -eq 64 ] || die "the previous release image digest is invalid"
}

load_previous_release() {
	previous_platform="$(previous_env_value SHIMPZ_SPACE_PLATFORM "${ENV_FILE}.previous")"
	[ "$previous_platform" = "$docker_platform" ] \
		|| die "the previous release targets a different Docker platform"
	previous_admin_ref="$(previous_env_value SHIMPZ_ADMIN_IMAGE "${ENV_FILE}.previous")"
	previous_team_ref="$(previous_env_value SHIMPZ_TEAM_IMAGE "${ENV_FILE}.previous")"
	previous_brain_ref="$(previous_env_value SHIMPZ_BRAIN_IMAGE "${ENV_FILE}.previous")"
	previous_assistant_egress_ref="$(previous_env_value SHIMPZ_ASSISTANT_EGRESS_IMAGE "${ENV_FILE}.previous")"
	previous_account_egress_ref="$(previous_env_value SHIMPZ_ACCOUNT_EGRESS_IMAGE "${ENV_FILE}.previous")"
	validate_pinned_release_ref "$previous_admin_ref" "$ADMIN_REPOSITORY"
	validate_pinned_release_ref "$previous_team_ref" "$TEAM_REPOSITORY"
	validate_pinned_release_ref "$previous_brain_ref" "$BRAIN_REPOSITORY"
	validate_pinned_release_ref "$previous_assistant_egress_ref" "$ASSISTANT_EGRESS_REPOSITORY"
	validate_pinned_release_ref "$previous_account_egress_ref" "$ACCOUNT_EGRESS_REPOSITORY"
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
	ensure_pinned_release_ref "$previous_team_ref" "$previous_platform" || return 1
	ensure_pinned_release_ref "$previous_brain_ref" "$previous_platform" || return 1
	ensure_pinned_release_ref "$previous_assistant_egress_ref" "$previous_platform" || return 1
	ensure_pinned_release_ref "$previous_account_egress_ref" "$previous_platform" || return 1
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

admin_tag_ref="${ADMIN_REPOSITORY}:${ADMIN_CHANNEL}"
team_tag_ref="${TEAM_REPOSITORY}:${TEAM_CHANNEL}"
brain_tag_ref="${BRAIN_REPOSITORY}:${BRAIN_CHANNEL}"
assistant_egress_tag_ref="${ASSISTANT_EGRESS_REPOSITORY}:${ASSISTANT_EGRESS_CHANNEL}"
account_egress_tag_ref="${ACCOUNT_EGRESS_REPOSITORY}:${ACCOUNT_EGRESS_CHANNEL}"
step "Pulling and verifying the stable Admin image"
admin_image_ref="$(pull_verified_ref "$admin_tag_ref" "$ADMIN_REPOSITORY")"
step "Pulling and verifying the local Team controller image"
team_image_ref="$(pull_verified_ref "$team_tag_ref" "$TEAM_REPOSITORY")"
step "Pulling and verifying the isolated Brain runtime image"
brain_image_ref="$(pull_verified_ref "$brain_tag_ref" "$BRAIN_REPOSITORY")"
step "Pulling and verifying the deny-by-default Assistant egress proxy"
assistant_egress_image_ref="$(pull_verified_ref "$assistant_egress_tag_ref" "$ASSISTANT_EGRESS_REPOSITORY")"
step "Pulling and verifying the isolated Account egress image"
account_egress_image_ref="$(pull_verified_ref "$account_egress_tag_ref" "$ACCOUNT_EGRESS_REPOSITORY")"
step "Verifying local Docker access for the Team controller"
docker_socket_source=""
docker_socket_gid=""
for socket_candidate in $docker_socket_candidates; do
	if candidate_gid="$(docker_socket_source="$socket_candidate" controller_socket_gid "$team_image_ref" 2>/dev/null)"; then
		case "$candidate_gid" in ""|*[!0-9]*) continue ;; esac
		if docker_socket_source="$socket_candidate" controller_can_reach_docker "$team_image_ref" "$candidate_gid"; then
			docker_socket_source="$socket_candidate"
			docker_socket_gid="$candidate_gid"
			break
		fi
	fi
done
[ -n "$docker_socket_source" ] && [ -n "$docker_socket_gid" ] \
	|| die "the Team controller cannot access Docker; check Docker Desktop socket permissions or Enhanced Container Isolation"

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
SHIMPZ_TEAM_IMAGE=${team_image_ref}
SHIMPZ_BRAIN_IMAGE=${brain_image_ref}
SHIMPZ_ASSISTANT_EGRESS_IMAGE=${assistant_egress_image_ref}
SHIMPZ_ACCOUNT_EGRESS_IMAGE=${account_egress_image_ref}
SHIMPZ_SPACE_PLATFORM=${docker_platform}
SHIMPZ_PORT=${install_port}
SHIMPZ_DOCKER_GID=${docker_socket_gid}
SHIMPZ_DOCKER_SOCKET=${docker_socket_source}
SHIMPZ_SPACE_ID=${space_id}
SHIMPZ_CPUSET=${docker_cpuset}
SHIMPZ_PROJECT_NAME=${PROJECT_NAME}
SHIMPZ_ADMIN_ALLOWED_ORIGINS=${ADMIN_ALLOWED_ORIGINS}
SHIMPZ_OAUTH_CALLBACK_MODE=${OAUTH_CALLBACK_MODE}
EOF
chmod 600 "${ENV_FILE}.tmp"

cat >"${COMPOSE_FILE}.tmp" <<'COMPOSE'
name: ${SHIMPZ_PROJECT_NAME:?installer must pin SHIMPZ_PROJECT_NAME}

services:
  account-egress-init:
    container_name: account-egress-init
    image: ${SHIMPZ_ACCOUNT_EGRESS_IMAGE:?installer must pin SHIMPZ_ACCOUNT_EGRESS_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: "no"
    user: "0:0"
    network_mode: none
    read_only: true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
    security_opt:
      - no-new-privileges:true
    entrypoint: ["python3"]
    command: ["/app/capability.py", "init"]
    volumes:
      - account_egress_capability:/run/shimpz-account-egress:rw
    tmpfs:
      - /tmp:rw,noexec,nosuid,nodev,size=8m
    cpuset: "${SHIMPZ_CPUSET:?installer must limit local CPUs}"
    cpus: "0.25"
    mem_limit: 64m
    memswap_limit: 64m
    pids_limit: 32
    logging:
      driver: json-file
      options:
        max-size: "1m"
        max-file: "1"

  team:
    container_name: shimpz-team
    image: ${SHIMPZ_TEAM_IMAGE:?installer must pin SHIMPZ_TEAM_IMAGE}
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
      - "10016"
      - "10017"
      - "10021"
      - "10022"
    environment:
      SHIMPZ_SPACE_ID: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}
      SHIMPZ_BRAIN_RUNTIME_URL: http://brain:8080
      SHIMPZ_BRAIN_RUNTIME_TOKEN_FILE: /run/shimpz-brain-runtime/token
      SHIMPZ_LOCAL_POWER_JOURNAL_PATH: /var/lib/shimpz-local/power-journal/journal.sqlite3
      SHIMPZ_LOCAL_CHAT_CONTINUATIONS_STATE_PATH: /var/lib/shimpz-local/chat-continuations/state/continuations.json
      SHIMPZ_LOCAL_CHAT_CONTINUATIONS_KEY_PATH: /var/lib/shimpz-local/chat-continuations/key/aes256.key
      SHIMPZ_OAUTH_CALLBACK_MODE: ${SHIMPZ_OAUTH_CALLBACK_MODE:?installer must pin the OAuth callback mode}
      SHIMPZ_OAUTH_BROKER_PROXY_HOST: account-egress
      SHIMPZ_OAUTH_BROKER_PROXY_CAPABILITY_FILE: /run/shimpz-account-egress/token
      SHIMPZ_ASSISTANT_EGRESS_CONTAINER: assistant-egress
      SHIMPZ_ASSISTANT_EGRESS_POLICY_DIR: /var/lib/shimpz-local/assistant-egress
    volumes:
      - ${SHIMPZ_DOCKER_SOCKET:?installer must bind the platform Docker socket}:/var/run/docker.sock:rw
      - controller_token:/run/shimpz-local:rw
      - controller_audit:/var/log/shimpz-local:rw
      - controller_storage:/var/lib/shimpz-local/storage:rw
      - controller_inference:/var/lib/shimpz-local/inference:rw
      - controller_power_journal:/var/lib/shimpz-local/power-journal:rw
      - controller_publications:/var/lib/shimpz-local/publications:rw
      - controller_assistant_integration_state:/var/lib/shimpz-local/assistant-integrations/state:rw
      - controller_assistant_integration_key:/var/lib/shimpz-local/assistant-integrations/key:rw
      - controller_chat_continuation_state:/var/lib/shimpz-local/chat-continuations/state:rw
      - controller_chat_continuation_key:/var/lib/shimpz-local/chat-continuations/key:rw
      - assistant_egress_policy:/var/lib/shimpz-local/assistant-egress:rw
      - brain_runtime_token:/run/shimpz-brain-runtime:rw
      - supervisor_key:/run/shimpz-local-supervisor:ro
      - account_egress_capability:/run/shimpz-account-egress:ro
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
    depends_on:
      account-egress-init:
        condition: service_completed_successfully
      assistant-egress:
        condition: service_started
      account-egress:
        condition: service_healthy
    networks:
      - control
      - brain_runtime
      - account_egress

  assistant-egress:
    container_name: assistant-egress
    image: ${SHIMPZ_ASSISTANT_EGRESS_IMAGE:?installer must pin SHIMPZ_ASSISTANT_EGRESS_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "10005:10005"
    group_add:
      - "10017"
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    labels:
      com.shimpz.local.managed: "1"
      com.shimpz.local.profile: local-v1
      com.shimpz.local.space-id: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}
      com.shimpz.local.kind: assistant-egress
    environment:
      SHIMPZ_ASSISTANT_EGRESS_PORT: "8889"
      SHIMPZ_ASSISTANT_EGRESS_POLICY_DIR: /policy
      SHIMPZ_ASSISTANT_EGRESS_AUDIT_LOG: /var/log/assistant-egress/audit.jsonl
      SHIMPZ_ASSISTANT_EGRESS_MAX_CONCURRENCY: "64"
      SHIMPZ_ASSISTANT_EGRESS_MAX_SOURCE_CONCURRENCY: "8"
      SHIMPZ_ASSISTANT_EGRESS_LISTEN_BACKLOG: "16"
    volumes:
      - assistant_egress_policy:/policy:ro
      - assistant_egress_audit:/var/log/assistant-egress:rw
    tmpfs:
      - /tmp:rw,noexec,nosuid,nodev,size=16m
    healthcheck:
      test: ["CMD", "python3", "/app/healthcheck.py"]
      interval: 5s
      timeout: 3s
      retries: 24
      start_period: 5s
    cpuset: "${SHIMPZ_CPUSET:?installer must limit local CPUs}"
    cpus: "1.0"
    mem_limit: 256m
    memswap_limit: 256m
    pids_limit: 128
    ulimits:
      nofile:
        soft: 512
        hard: 512
    stop_grace_period: 15s
    logging:
      driver: json-file
      options:
        max-size: "1m"
        max-file: "2"
    networks:
      - assistant_egress_out

  account-egress:
    container_name: account-egress
    image: ${SHIMPZ_ACCOUNT_EGRESS_IMAGE:?installer must pin SHIMPZ_ACCOUNT_EGRESS_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "10006:10006"
    group_add:
      - "10022"
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    labels:
      com.shimpz.local.managed: "1"
      com.shimpz.local.profile: local-v1
      com.shimpz.local.space-id: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}
      com.shimpz.local.kind: account-egress
    volumes:
      - account_egress_capability:/run/shimpz-account-egress:ro
      - account_egress_audit:/var/log/account-egress:rw
    tmpfs:
      - /tmp:rw,noexec,nosuid,nodev,size=8m
    cpuset: "${SHIMPZ_CPUSET:?installer must limit local CPUs}"
    cpus: "0.5"
    mem_limit: 128m
    memswap_limit: 128m
    pids_limit: 64
    ulimits:
      nofile:
        soft: 256
        hard: 256
    stop_grace_period: 15s
    depends_on:
      account-egress-init:
        condition: service_completed_successfully
    logging:
      driver: json-file
      options:
        max-size: "1m"
        max-file: "2"
    networks:
      - account_egress
      - account_egress_out

  brain-egress:
    container_name: shimpz-brain-egress
    image: ${SHIMPZ_BRAIN_IMAGE:?installer must pin SHIMPZ_BRAIN_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "10001:10001"
    entrypoint:
      - /opt/venv/bin/python
    command:
      - /app/egress/app.py
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    environment:
      SHIMPZ_EGRESS_AUDIT_LOG: /var/log/egress-proxy/audit.jsonl
      SHIMPZ_EGRESS_MAX_CONCURRENCY: "64"
      SHIMPZ_EGRESS_MAX_SOURCE_CONCURRENCY: "8"
      SHIMPZ_EGRESS_LISTEN_BACKLOG: "16"
    labels:
      com.shimpz.local.managed: "1"
      com.shimpz.local.profile: local-v1
      com.shimpz.local.space-id: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}
      com.shimpz.local.kind: brain-egress
    volumes:
      - brain_egress_audit:/var/log/egress-proxy:rw
    tmpfs:
      - /tmp:rw,noexec,nosuid,nodev,size=16m
    cpuset: "${SHIMPZ_CPUSET:?installer must limit local CPUs}"
    cpus: "1.0"
    mem_limit: 256m
    memswap_limit: 256m
    pids_limit: 128
    ulimits:
      nofile:
        soft: 512
        hard: 512
    stop_grace_period: 15s
    logging:
      driver: json-file
      options:
        max-size: "1m"
        max-file: "2"
    networks:
      - brain_egress
      - brain_egress_out
    healthcheck:
      test: ["CMD", "/opt/venv/bin/python", "/app/egress/healthcheck.py"]
      interval: 10s
      timeout: 4s
      retries: 5
      start_period: 5s

  brain:
    container_name: shimpz-brain
    image: ${SHIMPZ_BRAIN_IMAGE:?installer must pin SHIMPZ_BRAIN_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "10001:10001"
    group_add:
      - "10016"
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    environment:
      LANGCHAIN_TRACING_V2: "false"
      LANGSMITH_TRACING: "false"
      HTTPS_PROXY: http://brain-egress:8888
      HTTP_PROXY: http://brain-egress:8888
      https_proxy: http://brain-egress:8888
      http_proxy: http://brain-egress:8888
      NO_PROXY: localhost,127.0.0.1,::1
      no_proxy: localhost,127.0.0.1,::1
      SHIMPZ_BRAIN_RUNTIME_TOKEN_FILE: /run/shimpz-brain-runtime/token
      SHIMPZ_BRAIN_RUNTIME_STATE: /var/lib/shimpz-brain-runtime/checkpoints.sqlite3
    volumes:
      - brain_runtime_token:/run/shimpz-brain-runtime:ro
      - brain_runtime_state:/var/lib/shimpz-brain-runtime:rw
    tmpfs:
      - /tmp:rw,noexec,nosuid,nodev,size=64m
    cpuset: "${SHIMPZ_CPUSET:?installer must limit local CPUs}"
    cpus: "2.0"
    mem_limit: 1g
    memswap_limit: 1g
    pids_limit: 128
    stop_grace_period: 15s
    depends_on:
      team:
        condition: service_healthy
      brain-egress:
        condition: service_healthy
    logging:
      driver: json-file
      options:
        max-size: "1m"
        max-file: "2"
    networks:
      - brain_runtime
      - brain_egress

  admin:
    container_name: shimpz-admin
    image: ${SHIMPZ_ADMIN_IMAGE:?installer must pin SHIMPZ_ADMIN_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "1000:1000"
    group_add:
      - "10010"
      - "10021"
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    ports:
      - "127.0.0.1:${SHIMPZ_PORT:-7777}:4600"
    environment:
      SHIMPZ_ADMIN_PROFILE: local
      SHIMPZ_TEAM_URL: http://team:7077
      SHIMPZ_TEAM_TOKEN_FILE: /run/shimpz-local/token
      SHIMPZ_TEAM_CREDENTIALS_ENABLED: "0"
      SHIMPZ_ADMIN_LOOPBACK_PORT: ${SHIMPZ_PORT:-7777}
      SHIMPZ_ADMIN_ALLOWED_ORIGINS: ${SHIMPZ_ADMIN_ALLOWED_ORIGINS:?installer must pin Admin origins}
      SHIMPZ_OAUTH_CALLBACK_MODE: ${SHIMPZ_OAUTH_CALLBACK_MODE:?installer must pin the Admin OAuth callback mode}
    volumes:
      - config:/repo
      - data:/data
      - controller_token:/run/shimpz-local:ro
      - supervisor_key:/run/shimpz-local-supervisor:rw
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
      team:
        condition: service_healthy
      brain:
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
  controller_inference:
  controller_power_journal:
  controller_publications:
  controller_assistant_integration_state:
  controller_assistant_integration_key:
  controller_chat_continuation_state:
  controller_chat_continuation_key:
  supervisor_key:
  assistant_egress_policy:
  assistant_egress_audit:
  account_egress_capability:
  account_egress_audit:
  brain_egress_audit:
  brain_runtime_token:
  brain_runtime_state:

networks:
  control:
    driver: bridge
    internal: true
  brain_runtime:
    driver: bridge
    internal: true
  brain_egress:
    driver: bridge
    internal: true
  brain_egress_out:
    driver: bridge
  assistant_egress_out:
    driver: bridge
  account_egress:
    driver: bridge
    internal: true
  account_egress_out:
    driver: bridge
  egress:
    driver: bridge
COMPOSE
chmod 600 "${COMPOSE_FILE}.tmp"
mv "${ENV_FILE}.tmp" "$ENV_FILE"
mv "${COMPOSE_FILE}.tmp" "$COMPOSE_FILE"

step "Starting the Shimpz Admin, local Team controller, and isolated Brain runtime"
if ! compose up -d --wait --wait-timeout 120 --no-build --pull never --remove-orphans; then
	warn "The new release did not become healthy"
	compose logs --no-color --tail 20 team >&2 || true
	compose logs --no-color --tail 20 assistant-egress >&2 || true
	compose logs --no-color --tail 20 account-egress >&2 || true
	compose logs --no-color --tail 20 brain-egress >&2 || true
	compose logs --no-color --tail 20 brain >&2 || true
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
		compose up -d --wait --wait-timeout 120 --no-build --pull never --remove-orphans \
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
printf '  Control  %s\n' "$team_image_ref"
printf '  Brain    %s\n' "$brain_image_ref"
printf '  Egress   %s\n' "$assistant_egress_image_ref"
printf '  Account  %s\n' "$account_egress_image_ref"
printf '  Reset    %s\n' "$reset_command"
