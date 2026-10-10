#!/bin/sh
# Every prerendered page must carry its hash-bound script policy (svelte.config.js). Caddy's script-src header admits
# exactly the union of those hashes (Caddyfile), so no page needs 'unsafe-inline' and the image build fails closed when
# a page is missing its policy. Run from the build root after `pnpm run build`; writes ./script-hashes.
set -eu
pages="$(find build -name '*.html' | wc -l)"
policies="$(grep -rhoE --include='*.html' '<meta http-equiv="content-security-policy" content="[^"]*"' build)"
test "$pages" -gt 0
test "$(printf '%s\n' "$policies" | wc -l)" -eq "$pages"
printf '%s' "$(printf '%s\n' "$policies" | grep -oE "'sha256-[A-Za-z0-9+/]{43}='" | sort -u | paste -sd' ' -)" >script-hashes
test -s script-hashes
touch -d "@${SOURCE_DATE_EPOCH:?}" script-hashes
