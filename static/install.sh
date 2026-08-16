#!/bin/sh

set -eu

INSTALLER_VERSION="0.9.0"
RELEASE_REPOSITORY="ghcr.io/theshimpz/shimpz-local-release"
ADMIN_REPOSITORY="ghcr.io/theshimpz/shimpz-admin"
TEAM_REPOSITORY="ghcr.io/theshimpz/shimpz-team-local"
BRAIN_REPOSITORY="ghcr.io/theshimpz/shimpz-brain"
EGRESS_REPOSITORY="ghcr.io/theshimpz/shimpz-egress"
RELEASE_CHANNEL="stable"
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

version_at_least() (
	current_version="${1#v}"
	minimum_version="${2#v}"
	current_version="${current_version%%[-+]*}"
	minimum_version="${minimum_version%%[-+]*}"
	case "$current_version:$minimum_version" in
		*[!0-9.:]*) return 1 ;;
	esac
	IFS=.
	set -- $current_version
	[ "$#" -ge 2 ] && [ "$#" -le 3 ] || return 1
	current_major="$1"
	current_minor="$2"
	current_patch="${3:-0}"
	set -- $minimum_version
	[ "$#" -ge 2 ] && [ "$#" -le 3 ] || return 1
	minimum_major="$1"
	minimum_minor="$2"
	minimum_patch="${3:-0}"
	for component in \
		"$current_major" "$current_minor" "$current_patch" \
		"$minimum_major" "$minimum_minor" "$minimum_patch"; do
		[ -n "$component" ] || return 1
	done
	[ "$current_major" -gt "$minimum_major" ] && return 0
	[ "$current_major" -lt "$minimum_major" ] && return 1
	[ "$current_minor" -gt "$minimum_minor" ] && return 0
	[ "$current_minor" -lt "$minimum_minor" ] && return 1
	[ "$current_patch" -ge "$minimum_patch" ]
)

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

drain_piped_installer_source() {
	if [ -t 0 ]; then
		return 0
	fi
	dd of=/dev/null 2>/dev/null
}

usage() {
	cat <<'EOF'
Install the stable Shimpz Space release.

Usage:
  install.sh             Install, safely update, or recover Shimpz Space
  install.sh --reset     Stop Shimpz Space and delete its local data
  install.sh --version   Print the installer version
  install.sh --help      Show this help

Environment:
  SHIMPZ_PORT            Loopback port for the Admin (default: 7777)

Supported hosts:
  Linux amd64 with Docker Engine 25.0+ and Docker Compose 2.20.2+.
  Apple Silicon macOS arm64 with Docker Desktop providing Engine 25.0+
  and Docker Compose 2.20.2+.
EOF
}

die() {
	printf '  %s%s[error]%s Shimpz could not continue: %s\n' "$ERR_BOLD" "$ERR_RED" "$ERR_RESET" "$*" >&2
	exit 1
}

lock_handoff="${SHIMPZ_UPDATE_LOCK_HELD:-0}"
unset SHIMPZ_UPDATE_LOCK_HELD
docker_group_handoff="${SHIMPZ_DOCKER_GROUP_HANDOFF:-0}"
unset SHIMPZ_DOCKER_GROUP_HANDOFF SHIMPZ_DOCKER_GROUP_SOURCE SHIMPZ_DOCKER_GROUP_SCRIPT
unset SHIMPZ_DOCKER_GROUP_ACTION SHIMPZ_DOCKER_GROUP_RELEASE SHIMPZ_DOCKER_GROUP_FRESH_APPLY
requested_release_ref=""
fresh_apply=0
case "${1:-}" in
	"") action="install" ;;
	--reset) action="reset" ;;
	--scheduled) action="scheduled" ;;
	--apply-release)
		action="apply"
		requested_release_ref="${2:-}"
		[ -n "$requested_release_ref" ] || die "the exact Local release reference is required"
		;;
	--apply-fresh-release)
		action="apply"
		fresh_apply=1
		requested_release_ref="${2:-}"
		[ -n "$requested_release_ref" ] || die "the exact Local release reference is required"
		;;
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
if [ "$action" = "apply" ]; then
	[ "$#" -eq 2 ] || die "the exact Local release reference is the only internal argument"
else
	[ "$#" -le 1 ] || die "only one option may be supplied"
fi

setup_colors
case "$action" in
	install|reset) [ "$docker_group_handoff" = "1" ] || show_brand "$action" ;;
esac
PROJECT_NAME="shimpz-space"
RESERVED_CONTAINER_NAMES="shimpz-admin shimpz-team shimpz-brain shimpz-brain-egress shimpz-assistant-egress shimpz-assistant-release shimpz-account-egress shimpz-account-egress-init"
SHIMPZ_HOME_NAME=".shimpz"
MARKER_VALUE="shimpz-space-managed-v1"
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

refresh_stale_docker_group() {
	[ "$docker_group_handoff" != "1" ] || return 1
	[ "$(uname -s)" = "Linux" ] || return 1
	command -v sg >/dev/null 2>&1 || return 1
	if [ -f "$0" ] && [ "$(sed -n '1p' "$0" 2>/dev/null)" = "#!/bin/sh" ]; then
		docker_group_source="file"
		docker_group_script="$0"
	else
		case "$action" in
			install|reset) ;;
			*) return 1 ;;
		esac
		command -v curl >/dev/null 2>&1 || return 1
		docker_group_source="public"
		docker_group_script=""
	fi
	docker_socket_path="${docker_endpoint#unix://}"
	[ -S "$docker_socket_path" ] || return 1
	docker_socket_gid="$(stat -c '%g' "$docker_socket_path" 2>/dev/null)" || return 1
	case "$docker_socket_gid" in
		""|*[!0-9]*) return 1 ;;
	esac
	for current_gid in $(id -G); do
		[ "$current_gid" != "$docker_socket_gid" ] || return 1
	done
	account_name="$(id -un)" || return 1
	account_has_socket_group=0
	for account_gid in $(id -G "$account_name"); do
		if [ "$account_gid" = "$docker_socket_gid" ]; then
			account_has_socket_group=1
			break
		fi
	done
	[ "$account_has_socket_group" -eq 1 ] || return 1
	docker_socket_group="$(stat -c '%G' "$docker_socket_path" 2>/dev/null)" || return 1
	case "$docker_socket_group" in
		""|-*|*[!a-zA-Z0-9_.-]*) return 1 ;;
	esac
	SHIMPZ_DOCKER_GROUP_HANDOFF=1
	SHIMPZ_DOCKER_GROUP_SOURCE="$docker_group_source"
	SHIMPZ_DOCKER_GROUP_SCRIPT="$docker_group_script"
	SHIMPZ_DOCKER_GROUP_ACTION="$action"
	SHIMPZ_DOCKER_GROUP_RELEASE="$requested_release_ref"
	SHIMPZ_DOCKER_GROUP_FRESH_APPLY="$fresh_apply"
	export SHIMPZ_DOCKER_GROUP_HANDOFF SHIMPZ_DOCKER_GROUP_SOURCE SHIMPZ_DOCKER_GROUP_SCRIPT
	export SHIMPZ_DOCKER_GROUP_ACTION SHIMPZ_DOCKER_GROUP_RELEASE SHIMPZ_DOCKER_GROUP_FRESH_APPLY
	[ "$docker_group_source" != "public" ] || drain_piped_installer_source
	exec sg "$docker_socket_group" -c '
		case "${SHIMPZ_DOCKER_GROUP_SOURCE}:${SHIMPZ_DOCKER_GROUP_ACTION}" in
			file:install) exec /bin/sh "$SHIMPZ_DOCKER_GROUP_SCRIPT" ;;
			file:reset) exec /bin/sh "$SHIMPZ_DOCKER_GROUP_SCRIPT" --reset ;;
			file:scheduled) exec /bin/sh "$SHIMPZ_DOCKER_GROUP_SCRIPT" --scheduled ;;
			file:apply)
				case "$SHIMPZ_DOCKER_GROUP_FRESH_APPLY" in
					0) exec /bin/sh "$SHIMPZ_DOCKER_GROUP_SCRIPT" --apply-release "$SHIMPZ_DOCKER_GROUP_RELEASE" ;;
					1) exec /bin/sh "$SHIMPZ_DOCKER_GROUP_SCRIPT" --apply-fresh-release "$SHIMPZ_DOCKER_GROUP_RELEASE" ;;
					*) exit 64 ;;
				esac
				;;
			public:install|public:reset)
				public_script="$(curl -fsSL https://install.shimpz.com)" || exit 69
				case "$SHIMPZ_DOCKER_GROUP_ACTION" in
					install) printf "%s\n" "$public_script" | /bin/sh ;;
					reset) printf "%s\n" "$public_script" | /bin/sh -s -- --reset ;;
				esac
				;;
			*) exit 64 ;;
		esac
	'
}

if ! docker info >/dev/null 2>&1; then
	refresh_stale_docker_group || die "the Docker daemon is not available to this user"
fi
docker_server_version="$(docker version --format '{{.Server.Version}}' 2>/dev/null)" \
	|| die "could not determine the Docker Engine version"
docker_api_version="$(docker version --format '{{.Server.APIVersion}}' 2>/dev/null)" \
	|| die "could not determine the Docker Engine API version"
if ! version_at_least "$docker_server_version" "25.0.0" \
	|| ! version_at_least "$docker_api_version" "1.44"; then
	die "Docker Engine 25.0 or newer with API 1.44 or newer is required (found Engine ${docker_server_version}, API ${docker_api_version})"
fi
compose_version="$(docker compose version --short 2>/dev/null)" \
	|| die "could not determine the Docker Compose version"
version_at_least "$compose_version" "2.20.2" \
	|| die "Docker Compose 2.20.2 or newer is required (found ${compose_version})"

[ -n "${HOME:-}" ] || die "HOME must be set"
case "$HOME" in
	/*) ;;
	*) die "HOME must be an absolute path" ;;
esac

SHIMPZ_HOME="${HOME}/${SHIMPZ_HOME_NAME}"
COMPOSE_FILE="${SHIMPZ_HOME}/compose.yaml"
ENV_FILE="${SHIMPZ_HOME}/.env"
MARKER_FILE="${SHIMPZ_HOME}/.shimpz-space"
LOCK_DIR="${HOME}/.shimpz-update.lock"
RECONCILER_FILE="${SHIMPZ_HOME}/reconcile.sh"
RECONCILER_CANDIDATE="${SHIMPZ_HOME}/reconcile.candidate"
RECONCILER_PREVIOUS="${SHIMPZ_HOME}/reconcile.previous"
STATUS_FILE="${SHIMPZ_HOME}/release-status.json"
FAILED_RELEASE_FILE="${SHIMPZ_HOME}/failed-release.env"
SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/systemd/user"
SYSTEMD_SERVICE="${SYSTEMD_USER_DIR}/shimpz-update.service"
SYSTEMD_TIMER="${SYSTEMD_USER_DIR}/shimpz-update.timer"
LAUNCH_AGENT="${HOME}/Library/LaunchAgents/com.shimpz.update.plist"
SCHEDULER_MARKER="shimpz-local-update-v1"
[ -h "$SHIMPZ_HOME" ] && die "refusing to use symbolic-link installer directory: ${SHIMPZ_HOME}"
if { [ "$action" = "scheduled" ] || [ "$action" = "apply" ]; } && [ -f "$ENV_FILE" ]; then
	install_port="$(sed -n 's/^SHIMPZ_PORT=//p' "$ENV_FILE")"
	[ "$(printf '%s\n' "$install_port" | wc -l | tr -d ' ')" -eq 1 ] \
		|| die "the installed Admin port is ambiguous"
else
	install_port="${SHIMPZ_PORT:-7777}"
fi
unset SHIMPZ_ADMIN_IMAGE SHIMPZ_TEAM_IMAGE SHIMPZ_BRAIN_IMAGE SHIMPZ_EGRESS_IMAGE
unset SHIMPZ_LOCAL_RELEASE_IMAGE SHIMPZ_LOCAL_RELEASE_ORDINAL SHIMPZ_SPACE_PLATFORM SHIMPZ_PORT
unset SHIMPZ_DOCKER_GID SHIMPZ_DOCKER_SOCKET SHIMPZ_SPACE_ID SHIMPZ_CPUSET

lock_owned=0
release_lock() {
	[ "$lock_owned" -eq 1 ] || return 0
	rm -f "$LOCK_DIR/pid"
	rmdir "$LOCK_DIR" 2>/dev/null || true
	lock_owned=0
}

claim_lock() {
	chmod 700 "$LOCK_DIR"
	printf '%s\n' "$$" >"$LOCK_DIR/pid"
	chmod 600 "$LOCK_DIR/pid"
	lock_owned=1
	trap 'release_lock' EXIT HUP INT TERM
}

reclaim_stale_lock() {
	lock_record="$(cat "$LOCK_DIR/pid" 2>/dev/null || true)"
	case "$lock_record" in
		""|0|*[!0-9]*) ;;
		*) kill -0 "$lock_record" 2>/dev/null && return 1 ;;
	esac
	lock_record_again="$(cat "$LOCK_DIR/pid" 2>/dev/null || true)"
	[ "$lock_record_again" = "$lock_record" ] || return 1
	case "$lock_record_again" in
		""|0|*[!0-9]*) ;;
		*) kill -0 "$lock_record_again" 2>/dev/null && return 1 ;;
	esac
	rm -f "$LOCK_DIR/pid"
	rmdir "$LOCK_DIR" 2>/dev/null
}

acquire_lock() {
	if [ "$action" = "apply" ] && [ "$lock_handoff" = "1" ] && [ -f "$LOCK_DIR/pid" ] \
		&& [ "$(sed -n '1p' "$LOCK_DIR/pid")" = "$$" ]; then
		lock_owned=1
		trap 'release_lock' EXIT HUP INT TERM
		return 0
	fi
	if mkdir "$LOCK_DIR" 2>/dev/null; then
		claim_lock
		return 0
	fi
	if reclaim_stale_lock && mkdir "$LOCK_DIR" 2>/dev/null; then
		claim_lock
		return 0
	fi
	if [ "$action" = "scheduled" ]; then
		exit 0
	fi
	die "another Shimpz install or update is already running"
}

if [ "$action" = "scheduled" ] && [ "$(uname -s)" = "Darwin" ]; then
	update_jitter="$(printf '%s' "$HOME" | cksum | awk '{print $1 % 1801}')"
	sleep "$update_jitter"
fi
acquire_lock

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
	[ -n "$space_lines" ] || die "invalid Shimpz Space identity"
	[ "$(printf '%s\n' "$space_lines" | wc -l | tr -d ' ')" -eq 1 ] || die "invalid Shimpz Space identity"
	validate_space_id "$space_lines"
	printf '%s\n' "$space_lines"
}

validate_repository_digest_image() {
	image_value="$1"
	repository="$2"
	image_digest="${image_value#"${repository}@sha256:"}"
	[ "$image_digest" != "$image_value" ] \
		|| die "managed runtime is invalid: a container does not use its responsibility-owned image"
	case "$image_digest" in
		""|*[!0-9a-f]*) die "managed runtime is invalid: a container image digest is invalid" ;;
	esac
	[ "${#image_digest}" -eq 64 ] \
		|| die "managed runtime is invalid: a container image digest is invalid"
}

record_controller_identity() {
	controller_id="$1"
	controller_space_lines="$(docker inspect --type=container --format '{{range .Config.Env}}{{println .}}{{end}}' "$controller_id" \
		| sed -n 's/^SHIMPZ_SPACE_ID=//p')" \
		|| die "could not inspect the managed controller identity"
	[ "$(printf '%s\n' "$controller_space_lines" | wc -l | tr -d ' ')" -eq 1 ] \
		|| die "managed runtime is invalid: controller has an ambiguous Space identity"
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
	assistant_release_proxy_seen=0
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
			[ "$admin_seen" -eq 0 ] || die "managed runtime is invalid: duplicate Admin container"
				admin_seen=1
				admin_id="$resource_id"
				;;
			"/shimpz-team|team")
				validate_repository_digest_image "$container_image" "$TEAM_REPOSITORY"
			[ "$controller_seen" -eq 0 ] || die "managed runtime is invalid: duplicate controller container"
				controller_seen=1
				record_controller_identity "$resource_id"
				;;
			"/shimpz-brain|brain")
				validate_repository_digest_image "$container_image" "$BRAIN_REPOSITORY"
			[ "$brain_runtime_seen" -eq 0 ] || die "managed runtime is invalid: duplicate Brain runtime container"
				brain_runtime_seen=1
				;;
			"/shimpz-brain-egress|shimpz-brain-egress")
				validate_repository_digest_image "$container_image" "$EGRESS_REPOSITORY"
			[ "$brain_egress_seen" -eq 0 ] || die "managed runtime is invalid: duplicate Brain egress container"
				brain_egress_seen=1
				;;
			"/shimpz-assistant-egress|shimpz-assistant-egress")
				validate_repository_digest_image "$container_image" "$EGRESS_REPOSITORY"
				[ "$assistant_egress_proxy_seen" -eq 0 ] \
				|| die "managed runtime is invalid: duplicate Assistant egress proxy container"
				assistant_egress_proxy_seen=1
				;;
			"/shimpz-assistant-release|shimpz-assistant-release")
				validate_repository_digest_image "$container_image" "$EGRESS_REPOSITORY"
				[ "$assistant_release_proxy_seen" -eq 0 ] \
				|| die "managed runtime is invalid: duplicate Assistant release proxy container"
				assistant_release_proxy_seen=1
				;;
			"/shimpz-account-egress|shimpz-account-egress")
				validate_repository_digest_image "$container_image" "$EGRESS_REPOSITORY"
				[ "$account_egress_proxy_seen" -eq 0 ] \
				|| die "managed runtime is invalid: duplicate OAuth broker proxy container"
				account_egress_proxy_seen=1
				;;
			"/shimpz-account-egress-init|shimpz-account-egress-init")
				validate_repository_digest_image "$container_image" "$EGRESS_REPOSITORY"
				[ "$account_egress_init_seen" -eq 0 ] \
				|| die "managed runtime is invalid: duplicate Account egress initializer"
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
			"${PROJECT_NAME}_controller_action_journal|controller_action_journal"|\
			"${PROJECT_NAME}_controller_publications|controller_publications"|\
			"${PROJECT_NAME}_controller_cosign_trust|controller_cosign_trust"|\
			"${PROJECT_NAME}_controller_assistant_integration_state|controller_assistant_integration_state"|\
			"${PROJECT_NAME}_controller_assistant_integration_key|controller_assistant_integration_key"|\
			"${PROJECT_NAME}_controller_chat_continuation_state|controller_chat_continuation_state"|\
			"${PROJECT_NAME}_controller_chat_continuation_key|controller_chat_continuation_key"|\
			"${PROJECT_NAME}_supervisor_key|supervisor_key"|\
			"${PROJECT_NAME}_release_status|release_status"|\
			"${PROJECT_NAME}_account_egress_capability|account_egress_capability"|\
			"${PROJECT_NAME}_account_egress_audit|account_egress_audit"|\
			"${PROJECT_NAME}_brain_egress_audit|brain_egress_audit"|\
			"${PROJECT_NAME}_assistant_release_audit|assistant_release_audit"|\
			"${PROJECT_NAME}_brain_runtime_token|brain_runtime_token"|\
			"${PROJECT_NAME}_brain_runtime_state|brain_runtime_state"|\
			"${PROJECT_NAME}_assistant_egress_policy|assistant_egress_policy"|\
			"${PROJECT_NAME}_assistant_egress_audit|assistant_egress_audit") ;;
			*) die "managed runtime is invalid: the Compose project contains an unknown volume" ;;
		esac
	done
	for resource_id in $network_ids; do
		network_record="$(docker network inspect --format '{{.Name}}|{{index .Labels "com.docker.compose.network"}}' "$resource_id")" \
			|| die "could not verify managed Shimpz Space network ${resource_id}"
		case "$network_record" in
			"${PROJECT_NAME}_egress|egress"|"${PROJECT_NAME}_control|control"|\
			"${PROJECT_NAME}_brain_runtime|brain_runtime"|"${PROJECT_NAME}_brain_egress|brain_egress"|\
			"${PROJECT_NAME}_brain_egress_out|brain_egress_out"|\
			"${PROJECT_NAME}_assistant_release|assistant_release"|\
			"${PROJECT_NAME}_assistant_release_out|assistant_release_out"|\
			"${PROJECT_NAME}_assistant_egress_out|assistant_egress_out"|\
			"${PROJECT_NAME}_account_egress|account_egress"|\
			"${PROJECT_NAME}_account_egress_out|account_egress_out") ;;
			*) die "managed runtime is invalid: the Compose project contains an unknown network" ;;
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
	dynamic_assistant_release_seen=0
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
			|| die "managed runtime is invalid: a Space-labeled container has invalid ownership labels"
		case "$kind_value" in
			assistant)
				case "$dynamic_name" in "/shimpz-local-"*) ;; *) die "managed runtime is invalid: invalid Assistant name" ;; esac
				case "$team_value" in ""|*[!a-z0-9_]*) die "managed runtime is invalid: invalid Team id" ;; esac
				[ "${#team_value}" -le 40 ] || die "managed runtime is invalid: invalid Team id"
				case "$assistant_value" in ""|*[!a-z0-9-]*) die "managed runtime is invalid: invalid Assistant id" ;; esac
				case "$assistant_value" in [a-z]*) ;; *) die "managed runtime is invalid: invalid Assistant id" ;; esac
				case "$assistant_value" in *--*|*-) die "managed runtime is invalid: invalid Assistant id" ;; esac
				[ "${#assistant_value}" -le 48 ] || die "managed runtime is invalid: invalid Assistant id"
				;;
			assistant-egress)
				case "$dynamic_name" in
					"/shimpz-assistant-egress") ;;
					*) die "managed runtime is invalid: invalid Assistant egress proxy name" ;;
				esac
				[ "$dynamic_assistant_egress_seen" -eq 0 ] \
					|| die "managed runtime is invalid: duplicate Assistant egress proxy"
				dynamic_assistant_egress_seen=1
				;;
			assistant-release)
				case "$dynamic_name" in
					"/shimpz-assistant-release") ;;
					*) die "managed runtime is invalid: invalid Assistant release proxy name" ;;
				esac
				[ "$dynamic_assistant_release_seen" -eq 0 ] \
					|| die "managed runtime is invalid: duplicate Assistant release proxy"
				dynamic_assistant_release_seen=1
				;;
			brain-egress)
				case "$dynamic_name" in
					"/shimpz-brain-egress") ;;
					*) die "managed runtime is invalid: invalid Brain egress name" ;;
				esac
				[ "$dynamic_brain_egress_seen" -eq 0 ] \
					|| die "managed runtime is invalid: duplicate Brain egress"
				dynamic_brain_egress_seen=1
				;;
			account-egress)
				case "$dynamic_name" in
					"/shimpz-account-egress") ;;
					*) die "managed runtime is invalid: invalid OAuth broker proxy name" ;;
				esac
				[ "$dynamic_account_egress_seen" -eq 0 ] \
					|| die "managed runtime is invalid: duplicate OAuth broker proxy"
				dynamic_account_egress_seen=1
				;;
			*) die "managed runtime is invalid: a Space-labeled container has invalid ownership labels" ;;
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
			|| die "managed runtime is invalid: a Space-labeled network has invalid ownership labels"
		case "$dynamic_name" in "shimpz-local-"*) ;; *) die "managed runtime is invalid: invalid Team network name" ;; esac
		case "$team_value" in ""|*[!a-z0-9_]*) die "managed runtime is invalid: invalid Team id" ;; esac
		[ "${#team_value}" -le 40 ] || die "managed runtime is invalid: invalid Team id"
	done
}

reset_dynamic_space() {
	[ -n "$controller_id" ] || {
		dynamic_assistant_container_ids_value="$(dynamic_assistant_container_ids)" \
			|| die "could not inspect managed Assistant containers"
		[ -z "${dynamic_assistant_container_ids_value}${dynamic_network_ids_value}" ] \
			|| die "managed runtime is invalid: Team resources exist without their controller"
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
	trap 'stty "$terminal_state" </dev/tty 2>/dev/null || true; release_lock' EXIT HUP INT TERM
	stty -echo </dev/tty || die "could not secure the password prompt"
	IFS= read -r supervisor_password </dev/tty || {
		stty "$terminal_state" </dev/tty 2>/dev/null || true
		die "could not read the Supervisor password"
	}
	stty "$terminal_state" </dev/tty || die "could not restore the terminal"
	trap 'release_lock' EXIT HUP INT TERM
	printf '\n' >/dev/tty
	[ -n "$supervisor_password" ] || die "the Supervisor password is required"
	step "Resetting Teams and Assistants through the authenticated controller"
	reset_result=0
	printf '%s\n' "$supervisor_password" | docker exec -i "$admin_id" python -c 'import auth,json,state,sys,supervisor; from team import bridge,transport; password=sys.stdin.readline(4098).removesuffix("\n"); record=state.get(); valid=bool(password) and auth.verify_password(password,record.get("salt",""),record.get("password_hash","")); valid or sys.exit(2); identity=state.local_supervisor(); supervisor.materialize_public_key(identity); session=auth.issue_session(record["session_secret"],ttl=60); scope=transport.supervisor_session(session,account=False,local_identity=identity); scope.__enter__(); response=bridge.reset_space(); scope.__exit__(None,None,None); document=response.body; raise SystemExit(0 if response.status==200 and isinstance(document,dict) and document.get("reset") is True else 1)' >/dev/null 2>&1 \
		|| reset_result=$?
	unset supervisor_password
	case "$reset_result" in
		0) ;;
		2) die "the Supervisor password is incorrect" ;;
		*) die "the authenticated Team reset did not complete" ;;
	esac
	dynamic_assistant_container_ids_value="$(dynamic_assistant_container_ids)" \
		|| die "could not verify Assistant reset"
	dynamic_network_ids_value="$(dynamic_network_ids)" || die "could not verify Team reset"
	[ -z "${dynamic_assistant_container_ids_value}${dynamic_network_ids_value}" ] \
		|| die "the authenticated reset left managed Team resources"
}

remove_project_resources() {
	for resource_id in $container_ids; do
		docker rm --force "$resource_id" >/dev/null \
			|| die "could not remove a managed Shimpz Space container"
	done
	for resource_id in $network_ids; do
		docker network rm "$resource_id" >/dev/null \
			|| die "could not remove a managed Shimpz Space network"
	done
	for resource_id in $volume_ids; do
		docker volume rm "$resource_id" >/dev/null \
			|| die "could not remove a managed Shimpz Space volume"
	done
}

managed_local_container_ids() {
	docker ps --all --quiet \
		--filter "label=com.shimpz.local.managed=1" \
		--filter "label=com.shimpz.local.profile=${LOCAL_PROFILE}"
}

managed_local_network_ids() {
	docker network ls --quiet \
		--filter "label=com.shimpz.local.managed=1" \
		--filter "label=com.shimpz.local.profile=${LOCAL_PROFILE}"
}

recovery_dynamic_container_ids() {
	[ -n "$recovery_space_id" ] || return 0
	docker ps --all --quiet \
		--filter "label=com.shimpz.local.managed=1" \
		--filter "label=com.shimpz.local.profile=${LOCAL_PROFILE}" \
		--filter "label=${SPACE_LABEL}=${recovery_space_id}"
}

recovery_dynamic_network_ids() {
	[ -n "$recovery_space_id" ] || return 0
	docker network ls --quiet \
		--filter "label=com.shimpz.local.managed=1" \
		--filter "label=com.shimpz.local.profile=${LOCAL_PROFILE}" \
		--filter "label=${SPACE_LABEL}=${recovery_space_id}"
}

validate_recovery_dynamic_ownership() {
	reset_space_id="$recovery_space_id"
	space_container_ids="$(dynamic_container_ids)" \
		|| die "could not inspect Space-labeled containers before recovery"
	space_network_ids="$(dynamic_network_ids)" \
		|| die "could not inspect Space-labeled networks before recovery"
	for resource_id in $space_container_ids; do
		ownership_record="$(docker inspect --type=container --format '{{index .Config.Labels "com.shimpz.local.managed"}}|{{index .Config.Labels "com.shimpz.local.profile"}}|{{index .Config.Labels "com.shimpz.local.space-id"}}' "$resource_id")" \
			|| die "could not inspect a Space-labeled container before recovery"
		[ "$ownership_record" = "1|${LOCAL_PROFILE}|${recovery_space_id}" ] \
			|| die "automatic recovery refused a container without exact current Space ownership"
	done
	for resource_id in $space_network_ids; do
		ownership_record="$(docker network inspect --format '{{index .Labels "com.shimpz.local.managed"}}|{{index .Labels "com.shimpz.local.profile"}}|{{index .Labels "com.shimpz.local.space-id"}}' "$resource_id")" \
			|| die "could not inspect a Space-labeled network before recovery"
		[ "$ownership_record" = "1|${LOCAL_PROFILE}|${recovery_space_id}" ] \
			|| die "automatic recovery refused a network without exact current Space ownership"
	done
}

validate_no_unbound_dynamic_resources() {
	local_container_ids="$(managed_local_container_ids)" \
		|| die "could not inspect Local managed containers before recovery"
	local_network_ids="$(managed_local_network_ids)" \
		|| die "could not inspect Local managed networks before recovery"
	for resource_id in $local_container_ids; do
		resource_project="$(docker inspect --type=container --format '{{index .Config.Labels "com.docker.compose.project"}}' "$resource_id")" \
			|| die "could not inspect a Local managed container before recovery"
		[ "$resource_project" = "$PROJECT_NAME" ] \
			|| die "cleanup needs the current Space identity before deleting Team or Assistant resources"
	done
	for resource_id in $local_network_ids; do
		resource_project="$(docker network inspect --format '{{index .Labels "com.docker.compose.project"}}' "$resource_id")" \
			|| die "could not inspect a Local managed network before recovery"
		[ "$resource_project" = "$PROJECT_NAME" ] \
			|| die "cleanup needs the current Space identity before deleting Team or Assistant resources"
	done
}

prepare_corrupt_recovery() {
	validate_scheduler_ownership
	recovery_space_id=""
	if [ -f "$ENV_FILE" ]; then
		recovery_space_id="$(space_id_from_env_file)"
	fi
	recovery_controller_space_id=""
	if recovery_controller_project="$(docker inspect --type=container \
		--format '{{index .Config.Labels "com.docker.compose.project"}}' shimpz-team 2>/dev/null)"; then
		[ "$recovery_controller_project" = "$PROJECT_NAME" ] \
			|| die "automatic recovery refused a controller outside ${PROJECT_NAME}"
		recovery_controller_lines="$(docker inspect --type=container --format '{{range .Config.Env}}{{println .}}{{end}}' shimpz-team \
			| sed -n 's/^SHIMPZ_SPACE_ID=//p')" \
			|| die "could not inspect the managed controller identity before recovery"
		[ -n "$recovery_controller_lines" ] \
			&& [ "$(printf '%s\n' "$recovery_controller_lines" | wc -l | tr -d ' ')" -eq 1 ] \
			|| die "automatic recovery refused an ambiguous controller Space identity"
		validate_space_id "$recovery_controller_lines"
		recovery_controller_space_id="$recovery_controller_lines"
	fi
	if [ -n "$recovery_space_id" ] && [ -n "$recovery_controller_space_id" ]; then
		[ "$recovery_space_id" = "$recovery_controller_space_id" ] \
			|| die "automatic recovery refused mismatched local and controller Space identities"
	elif [ -z "$recovery_space_id" ]; then
		recovery_space_id="$recovery_controller_space_id"
	fi
	if [ -n "$recovery_space_id" ]; then
		validate_recovery_dynamic_ownership
	else
		validate_no_unbound_dynamic_resources
	fi
	container_ids="$(project_container_ids)" \
		|| die "could not inspect Shimpz Space containers before recovery"
	volume_ids="$(project_volume_ids)" \
		|| die "could not inspect Shimpz Space volumes before recovery"
	network_ids="$(project_network_ids)" \
		|| die "could not inspect Shimpz Space networks before recovery"
	recovery_dynamic_container_ids_value="$(recovery_dynamic_container_ids)" \
		|| die "could not inspect current Space containers before recovery"
	recovery_dynamic_network_ids_value="$(recovery_dynamic_network_ids)" \
		|| die "could not inspect current Space networks before recovery"
}

count_resource_ids() {
	resource_ids="$1"
	if [ -n "$resource_ids" ]; then
		printf '%s\n' "$resource_ids" | wc -w | tr -d ' '
	else
		printf '0\n'
	fi
}

print_recovery_container_names() {
	printed_names=""
	for resource_id in $container_ids $recovery_dynamic_container_ids_value; do
		resource_name="$(docker inspect --type=container --format '{{.Name}}' "$resource_id")" \
			|| die "could not name a container before recovery"
		case " $printed_names " in
			*" ${resource_name} "*) ;;
			*) printed_names="${printed_names} ${resource_name}" ;;
		esac
	done
	[ -z "$printed_names" ] || printf '  Containers%s\n' "$printed_names" >&2
}

remove_installer_files() {
	if ! rm -f \
		"$COMPOSE_FILE" "$ENV_FILE" "$MARKER_FILE" \
		"${COMPOSE_FILE}.previous" "${ENV_FILE}.previous" \
		"${COMPOSE_FILE}.tmp" "${ENV_FILE}.tmp" \
		"$RECONCILER_FILE" "$RECONCILER_CANDIDATE" "${RECONCILER_CANDIDATE}.tmp" \
		"$RECONCILER_PREVIOUS" "${RECONCILER_PREVIOUS}.tmp" \
		"$STATUS_FILE" "${STATUS_FILE}.tmp" "$FAILED_RELEASE_FILE" "${FAILED_RELEASE_FILE}.tmp" \
		"${SHIMPZ_HOME}/release.env.tmp"; then
		die "known Local installer files could not be removed"
	fi
}

remove_corrupt_install() {
	remove_scheduler
	recovery_dynamic_container_ids_value="$(recovery_dynamic_container_ids)" \
		|| die "could not refresh current Space containers for recovery"
	for resource_id in $recovery_dynamic_container_ids_value; do
		docker rm --force "$resource_id" >/dev/null \
			|| die "could not remove a current Space container during recovery"
	done
	recovery_dynamic_network_ids_value="$(recovery_dynamic_network_ids)" \
		|| die "could not refresh current Space networks for recovery"
	for resource_id in $recovery_dynamic_network_ids_value; do
		docker network rm "$resource_id" >/dev/null \
			|| die "could not remove a current Space network during recovery"
	done
	container_ids="$(project_container_ids)" \
		|| die "could not refresh Shimpz Space containers for recovery"
	volume_ids="$(project_volume_ids)" \
		|| die "could not refresh Shimpz Space volumes for recovery"
	network_ids="$(project_network_ids)" \
		|| die "could not refresh Shimpz Space networks for recovery"
	remove_project_resources
	if project_resources_exist; then
		die "automatic recovery left unexpected Shimpz Space Docker resources"
	fi
	if [ -n "$recovery_space_id" ]; then
		reset_space_id="$recovery_space_id"
		remaining_space_containers="$(dynamic_container_ids)" \
			|| die "could not verify current Space container removal"
		remaining_space_networks="$(dynamic_network_ids)" \
			|| die "could not verify current Space network removal"
		[ -z "${remaining_space_containers}${remaining_space_networks}" ] \
			|| die "automatic recovery left unexpected current Space resources"
	else
		validate_no_unbound_dynamic_resources
	fi
	remove_installer_files
	install_mode="install"
	space_id="$(generated_space_id)"
	info "Corrupt Local Space removed; installing a fresh Shimpz Space"
}

offer_corrupt_reinstall() {
	recovery_reason="$1"
	[ "$action" = "install" ] || die "$recovery_reason"
	prepare_corrupt_recovery
	warn "The existing Local Space failed current runtime validation"
	printf '%s\n' "$recovery_reason" >&2
	printf '  Project  %s\n' "$PROJECT_NAME" >&2
	[ -z "$recovery_space_id" ] || printf '  Space    %s\n' "$recovery_space_id" >&2
	printf '  Scope    %s project containers, %s volumes, %s project networks\n' \
		"$(count_resource_ids "$container_ids")" \
		"$(count_resource_ids "$volume_ids")" \
		"$(count_resource_ids "$network_ids")" >&2
	printf '           %s current Space containers, %s current Space networks\n' \
		"$(count_resource_ids "$recovery_dynamic_container_ids_value")" \
		"$(count_resource_ids "$recovery_dynamic_network_ids_value")" >&2
	print_recovery_container_names
	notice "Yes permanently removes every listed owned resource and the installed Local state; this cannot be undone" >&2
	if ! { [ -r /dev/tty ] && [ -w /dev/tty ] \
		&& ( : </dev/tty ) 2>/dev/null && ( : >/dev/tty ) 2>/dev/null; }; then
		drain_piped_installer_source
		die "automatic recovery requires an interactive terminal; nothing was changed"
	fi
	while :; do
		printf '  Permanently remove the listed corrupt Local state and install a fresh Space? [y/N] ' >/dev/tty
		if ! IFS= read -r recovery_answer </dev/tty; then
			drain_piped_installer_source
			die "could not read the recovery choice; nothing was changed"
		fi
		case "$recovery_answer" in
			[yY]|[yY][eE][sS]) break ;;
			""|[nN]|[nN][oO])
				drain_piped_installer_source
				printf '  Existing Local Space left unchanged.\n' >&2
				exit 1
				;;
			*) printf '  Please answer Yes or No.\n' >/dev/tty ;;
		esac
	done
	remove_corrupt_install
}

validate_existing_runtime() {
	validate_project_resources
	if [ -n "$controller_space_id" ]; then
		[ "$controller_space_id" = "$space_id" ] \
			|| die "managed runtime is invalid: controller and local Space identities differ"
	fi
	reset_space_id="$space_id"
	validate_dynamic_resources
}

write_release_status() {
	status_outcome="$1"
	status_release="$2"
	status_ordinal="$3"
	status_admin_ref="${4:-$admin_image_ref}"
	case "$status_outcome" in
		current|updated|rollback-needed) ;;
		*) die "the Local release status outcome is invalid" ;;
	esac
	validate_pinned_release_ref "$status_release" "$RELEASE_REPOSITORY"
	case "$status_ordinal" in
		""|0|*[!0-9]*) die "the Local release status ordinal is invalid" ;;
	esac
	status_timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
		|| die "could not timestamp the Local release status"
	cat >"${STATUS_FILE}.tmp" <<EOF
{"release":"${status_release}","ordinal":${status_ordinal},"checked_at":"${status_timestamp}","outcome":"${status_outcome}"}
EOF
	chmod 600 "${STATUS_FILE}.tmp"
	mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
	project_release_status "$status_admin_ref"
}

write_optional_release_status() {
	if ! (write_release_status "$@"); then
		warn "The Local release status was saved on the host but could not be projected to Admin"
	fi
}

project_release_status() {
	status_admin_ref="$1"
	validate_pinned_release_ref "$status_admin_ref" "$ADMIN_REPOSITORY"
	status_volume="${PROJECT_NAME}_release_status"
	status_volume_record="$(docker volume inspect \
		--format '{{.Name}}|{{index .Labels "com.docker.compose.project"}}|{{index .Labels "com.docker.compose.volume"}}' \
		"$status_volume" 2>/dev/null)" \
		|| die "the Local release status volume is unavailable"
	[ "$status_volume_record" = "${status_volume}|${PROJECT_NAME}|release_status" ] \
		|| die "the Local release status volume is not owned by this Space"
	docker run --rm -i \
		--platform "$docker_platform" --pull never \
		--network none --read-only --cap-drop ALL --security-opt no-new-privileges:true \
		--user 1000:1000 --cpuset-cpus "$docker_cpuset" --cpus 0.25 --memory 64m --memory-swap 64m --pids-limit 32 \
		--tmpfs /tmp:rw,noexec,nosuid,nodev,size=8m \
		--mount "type=volume,src=${status_volume},dst=/run/shimpz-local-release" \
		--entrypoint /opt/venv/bin/python \
		"$status_admin_ref" -c 'import json,os,sys; raw=sys.stdin.buffer.read(1025); document=json.loads(raw); assert len(raw)<=1024 and set(document)=={"release","ordinal","checked_at","outcome"}; target="/run/shimpz-local-release/status.json"; temporary=target+".tmp"; descriptor=os.open(temporary,os.O_WRONLY|os.O_CREAT|os.O_TRUNC,0o600); assert os.write(descriptor,raw)==len(raw); os.fchmod(descriptor,0o600); os.close(descriptor); os.replace(temporary,target)' \
		<"$STATUS_FILE" >/dev/null \
		|| die "the Local release status could not be projected to Admin"
}

remember_failed_release() {
	validate_pinned_release_ref "$release_image_ref" "$RELEASE_REPOSITORY"
	cat >"${FAILED_RELEASE_FILE}.tmp" <<EOF
release=${release_image_ref}
ordinal=${release_ordinal}
EOF
	chmod 600 "${FAILED_RELEASE_FILE}.tmp"
	mv "${FAILED_RELEASE_FILE}.tmp" "$FAILED_RELEASE_FILE"
}

failed_release_matches() {
	[ -f "$FAILED_RELEASE_FILE" ] || return 1
	[ "$(wc -l <"$FAILED_RELEASE_FILE" | tr -d ' ')" -eq 2 ] \
		|| die "the failed Local release record is malformed"
	failed_release_ref="$(sed -n 's/^release=//p' "$FAILED_RELEASE_FILE")"
	failed_release_ordinal="$(sed -n 's/^ordinal=//p' "$FAILED_RELEASE_FILE")"
	validate_pinned_release_ref "$failed_release_ref" "$RELEASE_REPOSITORY"
	case "$failed_release_ordinal" in
		""|0|*[!0-9]*) die "the failed Local release record is malformed" ;;
	esac
	[ "$failed_release_ref" = "$release_image_ref" ]
}

scheduler_files_exist() {
	case "$(uname -s)" in
		Linux)
			[ -e "$SYSTEMD_SERVICE" ] || [ -e "$SYSTEMD_TIMER" ] \
				|| [ -e "${SYSTEMD_SERVICE}.tmp" ] || [ -e "${SYSTEMD_TIMER}.tmp" ]
			;;
		Darwin) [ -e "$LAUNCH_AGENT" ] || [ -e "${LAUNCH_AGENT}.tmp" ] ;;
		*) return 1 ;;
	esac
}

remove_scheduler() {
	validate_scheduler_ownership
	host_scheduler_os="$(uname -s)"
	case "$host_scheduler_os" in
		Linux)
			systemd_scheduler_present=0
			if [ -e "$SYSTEMD_SERVICE" ] || [ -e "$SYSTEMD_TIMER" ]; then
				systemd_scheduler_present=1
				command -v systemctl >/dev/null 2>&1 \
					&& systemctl --user show-environment >/dev/null 2>&1 \
					|| die "could not inspect the owned automatic update scheduler"
				systemctl --user disable --now shimpz-update.timer >/dev/null 2>&1 || true
				if systemctl --user is-active --quiet shimpz-update.timer \
					|| systemctl --user is-enabled --quiet shimpz-update.timer; then
					die "the owned automatic update scheduler could not be stopped"
				fi
			fi
			rm -f "$SYSTEMD_SERVICE" "$SYSTEMD_TIMER" \
				"${SYSTEMD_SERVICE}.tmp" "${SYSTEMD_TIMER}.tmp" \
				|| die "owned automatic update scheduler files could not be removed"
			if [ "$systemd_scheduler_present" -eq 1 ]; then
				systemctl --user daemon-reload >/dev/null 2>&1 \
					|| die "could not refresh the automatic update scheduler"
			fi
			;;
		Darwin)
			if [ -e "$LAUNCH_AGENT" ]; then
				command -v launchctl >/dev/null 2>&1 \
					&& launchctl print "gui/$(id -u)" >/dev/null 2>&1 \
					|| die "could not inspect the owned automatic update scheduler"
				launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT" >/dev/null 2>&1 || true
				if launchctl print "gui/$(id -u)/com.shimpz.update" >/dev/null 2>&1; then
					die "the owned automatic update scheduler could not be stopped"
				fi
			fi
			rm -f "$LAUNCH_AGENT" "${LAUNCH_AGENT}.tmp" \
				|| die "owned automatic update scheduler files could not be removed"
			;;
	esac
}

install_scheduler() {
	validate_scheduler_ownership
	case "$host_os" in
		Linux)
			command -v systemctl >/dev/null 2>&1 \
				|| die "systemd user services are required for automatic updates"
			mkdir -p "$SYSTEMD_USER_DIR"
			cat >"${SYSTEMD_SERVICE}.tmp" <<'EOF'
# shimpz-local-update-v1
[Unit]
Description=Reconcile the Shimpz Local platform release
ConditionPathExists=%h/.shimpz/.shimpz-space

[Service]
Type=oneshot
ExecStart=/bin/sh %h/.shimpz/reconcile.sh --scheduled
EOF
			cat >"${SYSTEMD_TIMER}.tmp" <<'EOF'
# shimpz-local-update-v1
[Unit]
Description=Check for a Shimpz Local platform release

[Timer]
OnBootSec=5m
OnUnitActiveSec=6h
RandomizedDelaySec=30m
Persistent=true

[Install]
WantedBy=timers.target
EOF
			chmod 600 "${SYSTEMD_SERVICE}.tmp" "${SYSTEMD_TIMER}.tmp"
			mv "${SYSTEMD_SERVICE}.tmp" "$SYSTEMD_SERVICE"
			mv "${SYSTEMD_TIMER}.tmp" "$SYSTEMD_TIMER"
			systemctl --user daemon-reload \
				|| die "could not reload the automatic update scheduler"
			systemctl --user enable --now shimpz-update.timer >/dev/null \
				|| die "could not enable automatic Shimpz updates"
			;;
		Darwin)
			command -v launchctl >/dev/null 2>&1 \
				|| die "launchd is required for automatic updates"
			mkdir -p "${HOME}/Library/LaunchAgents"
			reconciler_xml="$(printf '%s' "$RECONCILER_FILE" | sed \
				-e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g')"
			cat >"${LAUNCH_AGENT}.tmp" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- shimpz-local-update-v1 -->
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.shimpz.update</string>
  <key>ProgramArguments</key>
  <array><string>/bin/sh</string><string>${reconciler_xml}</string><string>--scheduled</string></array>
  <key>RunAtLoad</key><true/>
  <key>StartInterval</key><integer>21600</integer>
  <key>ProcessType</key><string>Background</string>
  <key>StandardOutPath</key><string>/dev/null</string>
  <key>StandardErrorPath</key><string>/dev/null</string>
</dict>
</plist>
EOF
			chmod 600 "${LAUNCH_AGENT}.tmp"
			mv "${LAUNCH_AGENT}.tmp" "$LAUNCH_AGENT"
			launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENT" >/dev/null 2>&1 || true
			launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT" \
				|| die "could not enable automatic Shimpz updates"
			;;
	esac
}

validate_scheduler_ownership() {
	host_scheduler_os="$(uname -s)"
	case "$host_scheduler_os" in
		Linux)
			for scheduler_path in \
				"$SYSTEMD_SERVICE" "$SYSTEMD_TIMER" \
				"${SYSTEMD_SERVICE}.tmp" "${SYSTEMD_TIMER}.tmp"; do
				[ ! -e "$scheduler_path" ] \
					|| [ "$(sed -n '1p' "$scheduler_path")" = "# ${SCHEDULER_MARKER}" ] \
					|| die "refusing to replace an unowned user scheduler: ${scheduler_path}"
			done
			;;
		Darwin)
			for scheduler_path in "$LAUNCH_AGENT" "${LAUNCH_AGENT}.tmp"; do
				[ ! -e "$scheduler_path" ] \
					|| [ "$(sed -n '2p' "$scheduler_path")" = "<!-- ${SCHEDULER_MARKER} -->" ] \
					|| die "refusing to replace an unowned user scheduler: ${scheduler_path}"
			done
			;;
	esac
}

persist_reconciler() {
	[ -f "$RECONCILER_CANDIDATE" ] || die "the verified Local reconciler candidate is missing"
	[ "$(sha256_file "$RECONCILER_CANDIDATE")" = "$reconciler_sha256" ] \
		|| die "the verified Local reconciler candidate changed during apply"
	if [ -f "$RECONCILER_FILE" ]; then
		cp "$RECONCILER_FILE" "${RECONCILER_PREVIOUS}.tmp"
		chmod 700 "${RECONCILER_PREVIOUS}.tmp"
		mv "${RECONCILER_PREVIOUS}.tmp" "$RECONCILER_PREVIOUS"
	fi
	chmod 700 "$RECONCILER_CANDIDATE"
	mv "$RECONCILER_CANDIDATE" "$RECONCILER_FILE"
	install_scheduler
}

validate_scheduler() {
	case "$host_os" in
		Linux)
			command -v systemctl >/dev/null 2>&1 \
				&& systemctl --user show-environment >/dev/null 2>&1 \
				|| die "a running systemd user manager is required for automatic updates"
			;;
		Darwin)
			command -v launchctl >/dev/null 2>&1 \
				&& launchctl print "gui/$(id -u)" >/dev/null 2>&1 \
				|| die "a running launchd user domain is required for automatic updates"
			;;
	esac
}

if [ "$action" = "reset" ]; then
	validate_scheduler_ownership
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
	if scheduler_files_exist; then
		managed_state=1
	fi
	[ "$managed_state" -eq 1 ] || info "No managed Local state was present; confirming the clean result"
	validate_project_resources
	reset_space_id=""
	if [ -f "$ENV_FILE" ]; then
		reset_space_id="$(space_id_from_env_file)"
	fi
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
	else
		validate_no_unbound_dynamic_resources
	fi
	if [ -f "$COMPOSE_FILE" ] && [ -f "$ENV_FILE" ]; then
		step "Stopping Shimpz Space and removing Docker data"
		compose down --volumes --remove-orphans \
			|| die "could not stop Shimpz Space and remove its Docker data"
		if project_resources_exist; then
			step "Removing verified rollback leftovers"
			validate_project_resources
			remove_project_resources
		fi
	elif [ -n "${container_ids}${volume_ids}${network_ids}" ]; then
		step "Removing verified orphaned Docker data"
		remove_project_resources
	fi
	if project_resources_exist; then
		die "reset left unexpected Shimpz Space Docker resources; inspect them before retrying"
	fi
	remove_scheduler
	remove_installer_files
	release_lock
	preserved_installer_entries=0
	if [ -d "$SHIMPZ_HOME" ] && ! rmdir "$SHIMPZ_HOME" 2>/dev/null; then
		warn "Unrecognized files remain in ${SHIMPZ_HOME}; they were preserved"
		for entry in "$SHIMPZ_HOME"/* "$SHIMPZ_HOME"/.[!.]* "$SHIMPZ_HOME"/..?*; do
			[ -e "$entry" ] || [ -h "$entry" ] || continue
			preserved_installer_entries=1
			printf '  Preserved %s\n' "$entry" >&2
		done
		[ "$preserved_installer_entries" -eq 1 ] \
			|| die "the empty Local installer directory could not be removed"
		printf '  Move or delete the preserved entries before installing Shimpz again.\n' >&2
	fi
	printf '\n'
	success "Shimpz Space was reset"
	printf '  Data     No managed Space, Team, or Assistant Docker data remains\n'
	printf '  Files    No known installer files remain in %s\n' "$SHIMPZ_HOME"
	printf '  Updates  No owned automatic update scheduler remains\n'
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

validate_scheduler

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
if [ "$action" = "scheduled" ] && { [ ! -f "$MARKER_FILE" ] || [ ! -f "$ENV_FILE" ]; }; then
	die "the automatic update scheduler found no complete Shimpz installation"
fi
if [ -f "$MARKER_FILE" ]; then
	[ "$(sed -n '1p' "$MARKER_FILE")" = "$MARKER_VALUE" ] || die "invalid install marker in ${SHIMPZ_HOME}"
fi
if [ ! -f "$MARKER_FILE" ] && project_resources_exist; then
	die "managed Shimpz Docker data exists without an install marker. Nothing was changed; inspect and remove that unowned project explicitly"
fi
validate_reserved_container_names

if [ "$fresh_apply" -eq 1 ]; then
	[ -f "$MARKER_FILE" ] || die "fresh release application requires the owned install marker"
	[ ! -f "$ENV_FILE" ] || die "fresh release application refused existing local configuration"
	if project_resources_exist; then
		die "fresh release application refused existing Shimpz Docker resources"
	fi
	install_mode="install"
	info "Installing a fresh Shimpz Space"
	space_id="$(generated_space_id)"
elif [ -f "$MARKER_FILE" ]; then
	install_mode="update"
	info "Updating Shimpz Space; your Admin data will be preserved"
	space_id=""
	if [ -f "$ENV_FILE" ]; then
		space_id="$(space_id_from_env_file)"
	fi
	[ -n "$space_id" ] || space_id="$(generated_space_id)"
else
	install_mode="install"
	info "Installing a fresh Shimpz Space"
	space_id="$(generated_space_id)"
fi
validate_space_id "$space_id"
if project_resources_exist; then
	step "Validating the existing managed runtime"
	if runtime_validation_error="$({
		validate_existing_runtime
	} 2>&1)"; then
		validate_existing_runtime
	else
		offer_corrupt_reinstall "$runtime_validation_error"
	fi
elif [ "$install_mode" = "update" ]; then
	offer_corrupt_reinstall "managed runtime is invalid: no Shimpz Space Docker resources were found"
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

release_value() {
	release_key="$1"
	release_path="$2"
	release_lines="$(sed -n "s/^${release_key}=//p" "$release_path")"
	[ -n "$release_lines" ] || die "the Local release is missing ${release_key}"
	[ "$(printf '%s\n' "$release_lines" | wc -l | tr -d ' ')" -eq 1 ] \
		|| die "the Local release has duplicate ${release_key} values"
	printf '%s\n' "$release_lines"
}

validate_release_revision() {
	revision="$1"
	case "$revision" in
		""|*[!0-9a-f]*) die "the Local release has an invalid umbrella revision" ;;
	esac
	[ "${#revision}" -eq 40 ] || die "the Local release has an invalid umbrella revision"
}

sha256_file() {
	hash_path="$1"
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum "$hash_path" | awk '{print $1}'
	elif command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$hash_path" | awk '{print $1}'
	else
		die "a SHA-256 utility is required to verify the Local reconciler"
	fi
}

validate_sha256_hex() {
	hash_value="$1"
	case "$hash_value" in
		""|*[!0-9a-f]*) die "the Local release has an invalid reconciler hash" ;;
	esac
	[ "${#hash_value}" -eq 64 ] || die "the Local release has an invalid reconciler hash"
}

load_release_set() {
	release_ref="$1"
	release_metadata="${SHIMPZ_HOME}/release.env.tmp"
	release_container="$(docker create --platform "$docker_platform" "$release_ref" /release.env)" \
		|| die "the Local release metadata could not be opened"
	if ! docker cp "${release_container}:/release.env" "$release_metadata"; then
		docker rm "$release_container" >/dev/null 2>&1 || true
		rm -f "$release_metadata"
		die "the Local release metadata could not be read"
	fi
	if [ "$action" != "apply" ]; then
		if ! docker cp "${release_container}:/reconcile.sh" "${RECONCILER_CANDIDATE}.tmp"; then
			docker rm "$release_container" >/dev/null 2>&1 || true
			rm -f "$release_metadata" "${RECONCILER_CANDIDATE}.tmp"
			die "the Local reconciler could not be read"
		fi
		chmod 700 "${RECONCILER_CANDIDATE}.tmp"
		mv "${RECONCILER_CANDIDATE}.tmp" "$RECONCILER_CANDIDATE"
	fi
	docker rm "$release_container" >/dev/null \
		|| die "the Local release metadata container could not be removed"
	chmod 600 "$release_metadata"
	[ "$(wc -l <"$release_metadata" | tr -d ' ')" -eq 8 ] \
		|| die "the Local release metadata must contain exactly eight fields"
	while IFS= read -r release_record || [ -n "$release_record" ]; do
		case "$release_record" in
			schema=*|ordinal=*|umbrella_revision=*|reconciler_sha256=*|admin=*|team=*|brain=*|egress=*) ;;
			*) die "the Local release metadata contains an unknown field" ;;
		esac
	done <"$release_metadata"
	[ "$(release_value schema "$release_metadata")" = "local-v1" ] \
		|| die "the Local release schema is not supported"
	release_ordinal="$(release_value ordinal "$release_metadata")"
	case "$release_ordinal" in
		""|0|*[!0-9]*) die "the Local release ordinal is invalid" ;;
	esac
	release_revision="$(release_value umbrella_revision "$release_metadata")"
	validate_release_revision "$release_revision"
	reconciler_sha256="$(release_value reconciler_sha256 "$release_metadata")"
	validate_sha256_hex "$reconciler_sha256"
	admin_image_ref="$(release_value admin "$release_metadata")"
	team_image_ref="$(release_value team "$release_metadata")"
	brain_image_ref="$(release_value brain "$release_metadata")"
	egress_image_ref="$(release_value egress "$release_metadata")"
	validate_pinned_release_ref "$admin_image_ref" "$ADMIN_REPOSITORY"
	validate_pinned_release_ref "$team_image_ref" "$TEAM_REPOSITORY"
	validate_pinned_release_ref "$brain_image_ref" "$BRAIN_REPOSITORY"
	validate_pinned_release_ref "$egress_image_ref" "$EGRESS_REPOSITORY"
	if [ "$action" = "apply" ]; then
		actual_reconciler_sha256="$(sha256_file "$0")"
	else
		actual_reconciler_sha256="$(sha256_file "$RECONCILER_CANDIDATE")"
	fi
	[ "$actual_reconciler_sha256" = "$reconciler_sha256" ] \
		|| die "the Local reconciler does not match its release metadata"
	rm -f "$release_metadata"
}

validate_forward_release() {
	current_release_ordinal=""
	release_outcome="updated"
	[ -f "$ENV_FILE" ] || return 0
	current_release_ordinal="$(previous_env_value SHIMPZ_LOCAL_RELEASE_ORDINAL "$ENV_FILE")"
	case "$current_release_ordinal" in
		""|0|*[!0-9]*) die "the current Local release ordinal is invalid" ;;
	esac
	[ "$release_ordinal" -ge "$current_release_ordinal" ] \
		|| die "the Local release channel points to an older release"
	if [ "$release_ordinal" -eq "$current_release_ordinal" ]; then
		current_release_ref="$(previous_env_value SHIMPZ_LOCAL_RELEASE_IMAGE "$ENV_FILE")"
		validate_pinned_release_ref "$current_release_ref" "$RELEASE_REPOSITORY"
		[ "$release_image_ref" = "$current_release_ref" ] \
			|| die "the Local release ordinal was reused for different content"
		release_outcome="current"
	fi
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
		|| die "the Local release reference for ${repository} is not pinned to its official image"
	case "$image_digest" in
		""|*[!0-9a-f]*) die "the Local release reference for ${repository} has an invalid digest" ;;
	esac
	[ "${#image_digest}" -eq 64 ] \
		|| die "the Local release reference for ${repository} has an invalid digest"
}

load_previous_release() {
	previous_platform="$(previous_env_value SHIMPZ_SPACE_PLATFORM "${ENV_FILE}.previous")"
	[ "$previous_platform" = "$docker_platform" ] \
		|| die "the previous release targets a different Docker platform"
	previous_admin_ref="$(previous_env_value SHIMPZ_ADMIN_IMAGE "${ENV_FILE}.previous")"
	previous_team_ref="$(previous_env_value SHIMPZ_TEAM_IMAGE "${ENV_FILE}.previous")"
	previous_brain_ref="$(previous_env_value SHIMPZ_BRAIN_IMAGE "${ENV_FILE}.previous")"
	previous_egress_ref="$(previous_env_value SHIMPZ_EGRESS_IMAGE "${ENV_FILE}.previous")"
	previous_release_ref="$(previous_env_value SHIMPZ_LOCAL_RELEASE_IMAGE "${ENV_FILE}.previous")"
	previous_release_ordinal="$(previous_env_value SHIMPZ_LOCAL_RELEASE_ORDINAL "${ENV_FILE}.previous")"
	validate_pinned_release_ref "$previous_admin_ref" "$ADMIN_REPOSITORY"
	validate_pinned_release_ref "$previous_team_ref" "$TEAM_REPOSITORY"
	validate_pinned_release_ref "$previous_brain_ref" "$BRAIN_REPOSITORY"
	validate_pinned_release_ref "$previous_egress_ref" "$EGRESS_REPOSITORY"
	validate_pinned_release_ref "$previous_release_ref" "$RELEASE_REPOSITORY"
	case "$previous_release_ordinal" in
		""|0|*[!0-9]*) die "the previous Local release ordinal is invalid" ;;
	esac
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
	ensure_pinned_release_ref "$previous_egress_ref" "$previous_platform" || return 1
	ensure_pinned_release_ref "$previous_release_ref" "$previous_platform" || return 1
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

if [ "$action" = "apply" ]; then
	validate_pinned_release_ref "$requested_release_ref" "$RELEASE_REPOSITORY"
	release_selector_ref="$requested_release_ref"
else
	release_selector_ref="${RELEASE_REPOSITORY}:${RELEASE_CHANNEL}"
fi
step "Resolving the atomic Local platform release"
release_image_ref="$(pull_verified_ref "$release_selector_ref" "$RELEASE_REPOSITORY")"
load_release_set "$release_image_ref"
validate_forward_release
if [ "$action" != "apply" ]; then
	if failed_release_matches; then
		if [ "$action" = "scheduled" ]; then
			exit 0
		fi
		die "this Local release already failed its health gate; waiting for another promoted release"
	fi
	apply_option="--apply-release"
	[ "$install_mode" != "install" ] || apply_option="--apply-fresh-release"
	drain_piped_installer_source
	exec env SHIMPZ_UPDATE_LOCK_HELD=1 SHIMPZ_PORT="$install_port" \
		/bin/sh "$RECONCILER_CANDIDATE" "$apply_option" "$release_image_ref"
fi
if [ "$release_outcome" = "current" ]; then
	persist_reconciler
	rm -f "$FAILED_RELEASE_FILE"
	write_release_status "current" "$release_image_ref" "$release_ordinal"
	exit 0
fi
step "Pulling the release-pinned Admin image"
admin_image_ref="$(pull_verified_ref "$admin_image_ref" "$ADMIN_REPOSITORY")"
step "Pulling the release-pinned local Team controller image"
team_image_ref="$(pull_verified_ref "$team_image_ref" "$TEAM_REPOSITORY")"
step "Pulling the release-pinned isolated Brain runtime image"
brain_image_ref="$(pull_verified_ref "$brain_image_ref" "$BRAIN_REPOSITORY")"
step "Pulling the release-pinned shared Shimpz egress image"
egress_image_ref="$(pull_verified_ref "$egress_image_ref" "$EGRESS_REPOSITORY")"
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
SHIMPZ_EGRESS_IMAGE=${egress_image_ref}
SHIMPZ_LOCAL_RELEASE_IMAGE=${release_image_ref}
SHIMPZ_LOCAL_RELEASE_ORDINAL=${release_ordinal}
SHIMPZ_SPACE_PLATFORM=${docker_platform}
SHIMPZ_PORT=${install_port}
SHIMPZ_DOCKER_GID=${docker_socket_gid}
SHIMPZ_DOCKER_SOCKET=${docker_socket_source}
SHIMPZ_SPACE_ID=${space_id}
SHIMPZ_CPUSET=${docker_cpuset}
SHIMPZ_PROJECT_NAME=${PROJECT_NAME}
SHIMPZ_ADMIN_ALLOWED_ORIGINS=${ADMIN_ALLOWED_ORIGINS}
EOF
chmod 600 "${ENV_FILE}.tmp"

cat >"${COMPOSE_FILE}.tmp" <<'COMPOSE'
name: ${SHIMPZ_PROJECT_NAME:?installer must pin SHIMPZ_PROJECT_NAME}

services:
  shimpz-account-egress-init:
    container_name: shimpz-account-egress-init
    image: ${SHIMPZ_EGRESS_IMAGE:?installer must pin SHIMPZ_EGRESS_IMAGE}
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
    command: ["account-init"]
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
      SHIMPZ_LOCAL_ACTION_JOURNAL_PATH: /var/lib/shimpz-local/action-journal/journal.sqlite3
      SHIMPZ_LOCAL_CHAT_CONTINUATIONS_STATE_PATH: /var/lib/shimpz-local/chat-continuations/state/continuations.json
      SHIMPZ_LOCAL_CHAT_CONTINUATIONS_KEY_PATH: /var/lib/shimpz-local/chat-continuations/key/aes256.key
      SHIMPZ_OAUTH_BROKER_PROXY_HOST: shimpz-account-egress
      SHIMPZ_OAUTH_BROKER_PROXY_CAPABILITY_FILE: /run/shimpz-account-egress/token
      SHIMPZ_ASSISTANT_EGRESS_CONTAINER: shimpz-assistant-egress
      SHIMPZ_ASSISTANT_EGRESS_POLICY_DIR: /var/lib/shimpz-local/assistant-egress
    volumes:
      - ${SHIMPZ_DOCKER_SOCKET:?installer must bind the platform Docker socket}:/var/run/docker.sock:rw
      - controller_token:/run/shimpz-local:rw
      - controller_audit:/var/log/shimpz-local:rw
      - controller_storage:/var/lib/shimpz-local/storage:rw
      - controller_inference:/var/lib/shimpz-local/inference:rw
      - controller_action_journal:/var/lib/shimpz-local/action-journal:rw
      - controller_publications:/var/lib/shimpz-local/publications:rw
      - controller_cosign_trust:/var/lib/shimpz-local/cosign:rw
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
      shimpz-account-egress-init:
        condition: service_completed_successfully
      shimpz-assistant-egress:
        condition: service_started
      shimpz-assistant-release:
        condition: service_healthy
      shimpz-account-egress:
        condition: service_healthy
    networks:
      - control
      - brain_runtime
      - account_egress
      - assistant_release

  shimpz-assistant-egress:
    container_name: shimpz-assistant-egress
    image: ${SHIMPZ_EGRESS_IMAGE:?installer must pin SHIMPZ_EGRESS_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "10005:10005"
    command: ["assistant"]
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
      test: ["CMD", "python3", "/app/entrypoint.py", "healthcheck", "assistant"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 30s
      start_interval: 1s
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

  shimpz-assistant-release:
    container_name: shimpz-assistant-release
    image: ${SHIMPZ_EGRESS_IMAGE:?installer must pin SHIMPZ_EGRESS_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "10004:10004"
    command: ["release"]
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    labels:
      com.shimpz.local.managed: "1"
      com.shimpz.local.profile: local-v1
      com.shimpz.local.space-id: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}
      com.shimpz.local.kind: assistant-release
    environment:
      SHIMPZ_EGRESS_ALLOW: developers.shimpz.com,ghcr.io,tuf-repo-cdn.sigstore.dev,rekor.sigstore.dev,pkg-containers.githubusercontent.com
      SHIMPZ_EGRESS_AUDIT_LOG: /var/log/assistant-release/audit.jsonl
      SHIMPZ_EGRESS_MAX_CONCURRENCY: "16"
      SHIMPZ_EGRESS_MAX_SOURCE_CONCURRENCY: "4"
      SHIMPZ_EGRESS_LISTEN_BACKLOG: "8"
    volumes:
      - assistant_release_audit:/var/log/assistant-release:rw
    tmpfs:
      - /tmp:rw,noexec,nosuid,nodev,size=8m
    healthcheck:
      test: ["CMD", "python3", "/app/entrypoint.py", "healthcheck", "release"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 30s
      start_interval: 1s
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
    logging:
      driver: json-file
      options:
        max-size: "1m"
        max-file: "2"
    networks:
      - assistant_release
      - assistant_release_out

  shimpz-account-egress:
    container_name: shimpz-account-egress
    image: ${SHIMPZ_EGRESS_IMAGE:?installer must pin SHIMPZ_EGRESS_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "10006:10006"
    command: ["account"]
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
      shimpz-account-egress-init:
        condition: service_completed_successfully
    logging:
      driver: json-file
      options:
        max-size: "1m"
        max-file: "2"
    networks:
      - account_egress
      - account_egress_out
    healthcheck:
      test: ["CMD", "python3", "/app/entrypoint.py", "healthcheck", "account"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 30s
      start_interval: 1s

  shimpz-brain-egress:
    container_name: shimpz-brain-egress
    image: ${SHIMPZ_EGRESS_IMAGE:?installer must pin SHIMPZ_EGRESS_IMAGE}
    platform: ${SHIMPZ_SPACE_PLATFORM:?installer must pin SHIMPZ_SPACE_PLATFORM}
    pull_policy: never
    restart: unless-stopped
    user: "10001:10001"
    command: ["brain"]
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    environment:
      SHIMPZ_EGRESS_AUDIT_LOG: /var/log/brain-egress/audit.jsonl
      SHIMPZ_EGRESS_MAX_CONCURRENCY: "64"
      SHIMPZ_EGRESS_MAX_SOURCE_CONCURRENCY: "8"
      SHIMPZ_EGRESS_LISTEN_BACKLOG: "16"
    labels:
      com.shimpz.local.managed: "1"
      com.shimpz.local.profile: local-v1
      com.shimpz.local.space-id: ${SHIMPZ_SPACE_ID:?installer must preserve SHIMPZ_SPACE_ID}
      com.shimpz.local.kind: brain-egress
    volumes:
      - brain_egress_audit:/var/log/brain-egress:rw
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
      test: ["CMD", "python3", "/app/entrypoint.py", "healthcheck", "brain"]
      interval: 30s
      timeout: 4s
      retries: 3
      start_period: 30s
      start_interval: 1s

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
      HTTPS_PROXY: http://shimpz-brain-egress:8888
      HTTP_PROXY: http://shimpz-brain-egress:8888
      https_proxy: http://shimpz-brain-egress:8888
      http_proxy: http://shimpz-brain-egress:8888
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
      shimpz-brain-egress:
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
      SHIMPZ_ADMIN_ALLOWED_ORIGINS: ${SHIMPZ_ADMIN_ALLOWED_ORIGINS:?installer must pin Admin origins}
    volumes:
      - config:/repo
      - data:/data
      - controller_token:/run/shimpz-local:ro
      - supervisor_key:/run/shimpz-local-supervisor:rw
      - release_status:/run/shimpz-local-release:ro
    tmpfs:
      - /tmp:rw,noexec,nosuid,nodev,size=32m
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; request=urllib.request.Request('http://127.0.0.1:4600/api/session', method='POST'); urllib.request.urlopen(request, timeout=2).read()"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 30s
      start_interval: 1s
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
  controller_action_journal:
  controller_publications:
  controller_cosign_trust:
  controller_assistant_integration_state:
  controller_assistant_integration_key:
  controller_chat_continuation_state:
  controller_chat_continuation_key:
  supervisor_key:
  release_status:
  assistant_egress_policy:
  assistant_egress_audit:
  assistant_release_audit:
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
  assistant_release:
    driver: bridge
    internal: true
  assistant_release_out:
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
	compose logs --no-color --tail 20 shimpz-assistant-egress >&2 || true
	compose logs --no-color --tail 20 shimpz-assistant-release >&2 || true
	compose logs --no-color --tail 20 shimpz-account-egress >&2 || true
	compose logs --no-color --tail 20 shimpz-brain-egress >&2 || true
	compose logs --no-color --tail 20 brain >&2 || true
		if [ "$had_previous" -eq 1 ]; then
			step "Verifying the previous pinned release"
			if ! hydrate_previous_release; then
				mv "${ENV_FILE}.previous" "$ENV_FILE"
				mv "${COMPOSE_FILE}.previous" "$COMPOSE_FILE"
				remember_failed_release
				write_optional_release_status \
					"rollback-needed" "$release_image_ref" "$release_ordinal" "$admin_image_ref"
				die "the candidate failed and rollback images could not be verified; previous files were restored without deleting Docker data"
			fi
	fi
	compose down --remove-orphans >/dev/null || true
	if [ "$had_previous" -eq 1 ]; then
			step "Restoring the previous pinned release"
			mv "${ENV_FILE}.previous" "$ENV_FILE"
			mv "${COMPOSE_FILE}.previous" "$COMPOSE_FILE"
			if ! compose up -d --wait --wait-timeout 120 --no-build --pull never --remove-orphans; then
				remember_failed_release
				write_optional_release_status \
					"rollback-needed" "$release_image_ref" "$release_ordinal" "$previous_admin_ref"
				die "rollback also failed; inspect with: (cd \"${SHIMPZ_HOME}\" && docker compose -p ${PROJECT_NAME} logs)"
			fi
			remember_failed_release
			write_optional_release_status \
				"rollback-needed" "$release_image_ref" "$release_ordinal" "$previous_admin_ref"
			warn "Previous version restored; your Admin data was preserved"
			die "the update failed, so Shimpz is still running the previous version"
		fi
		remember_failed_release
		write_optional_release_status \
			"rollback-needed" "$release_image_ref" "$release_ordinal" "$admin_image_ref"
		die "installation failed"
	fi

	rm -f "${ENV_FILE}.previous" "${COMPOSE_FILE}.previous"
	persist_reconciler
	rm -f "$FAILED_RELEASE_FILE"
	write_release_status "$release_outcome" "$release_image_ref" "$release_ordinal"
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
printf '  Team     %s\n' "$team_image_ref"
printf '  Brain    %s\n' "$brain_image_ref"
	printf '  Egress   %s\n' "$egress_image_ref"
	printf '  Release  %s (ordinal %s)\n' "$release_image_ref" "$release_ordinal"
if [ "$install_port" != "7777" ]; then
	printf '  OAuth    Sign in through https://local.shimpz.com to authorize Assistant Integrations\n'
fi
printf '  Reset    %s\n' "$reset_command"
