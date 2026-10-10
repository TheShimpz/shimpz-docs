#!/bin/sh
# Every prerendered page must carry its hash-bound script policy (svelte.config.js). The served script-src admits
# exactly the union of those hashes, so no page needs 'unsafe-inline' and the image build fails closed when a page is
# missing its policy. Run from the build root after `pnpm run build`: renders security-headers.conf, with SCRIPT_HASHES
# replaced by that union, into ./served-security-headers.conf.
set -eu
pages="$(find build -name '*.html' | wc -l)"
policies="$(grep -rhoE --include='*.html' '<meta http-equiv="content-security-policy" content="[^"]*"' build)"
test "$pages" -gt 0
test "$(printf '%s\n' "$policies" | wc -l)" -eq "$pages"
hashes="$(printf '%s\n' "$policies" | grep -oE "'sha256-[A-Za-z0-9+/]{43}='" | sort -u | paste -sd' ' -)"
test -n "$hashes"
test "$(grep -c "script-src 'self' SCRIPT_HASHES;" security-headers.conf)" -eq 1
sed "s|script-src 'self' SCRIPT_HASHES;|script-src 'self' $hashes;|" security-headers.conf >served-security-headers.conf
test "$(grep -c "script-src 'self' 'sha256-" served-security-headers.conf)" -eq 1
touch -d "@${SOURCE_DATE_EPOCH:?}" served-security-headers.conf
