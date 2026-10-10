#!/bin/sh
# Real-server contracts for the built Docs origin image (SHIMPZ_DOCS_TEST_IMAGE). The image runs as the graph runs it:
# read-only, every capability dropped, /tmp on a tmpfs, on a disposable internal network the host reaches directly.
# This driver owns the container's lifecycle; tests/check_origin.py owns the contracts.
set -eu
image="${SHIMPZ_DOCS_TEST_IMAGE:?SHIMPZ_DOCS_TEST_IMAGE names the built Docs image}"
here="$(cd "$(dirname "$0")" && pwd)"
name="shimpz-docs-origin-$$"
work="$(mktemp -d)"
cleanup() {
  docker rm -f "$name" >/dev/null 2>&1 || true
  docker network rm "$name" >/dev/null 2>&1 || true
  rm -rf "$work"
}
trap cleanup EXIT
docker network create --internal "$name" >/dev/null
docker run --detach --name "$name" --network "$name" --read-only --cap-drop ALL \
  --security-opt no-new-privileges:true --tmpfs /tmp:size=8m,mode=1777 "$image" >/dev/null
tries=0
until docker exec "$name" wget -q -O /dev/null http://127.0.0.1:8080/ 2>/dev/null; do
  tries=$((tries + 1))
  if [ "$tries" -ge 300 ]; then
    docker logs "$name" >&2
    echo "test-origin: the Docs origin never answered" >&2
    exit 1
  fi
  sleep 0.2
done
address="$(docker inspect --format "{{(index .NetworkSettings.Networks \"$name\").IPAddress}}" "$name")"
user="$(docker image inspect --format '{{.Config.User}}' "$image")"
docker cp "$name:/srv/_app/immutable" "$work/immutable"
python3 "$here/check_origin.py" "$address" "$work/immutable" "$user"
