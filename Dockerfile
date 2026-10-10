# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
# shimpz-docs — docs.shimpz.com. Prerendered SvelteKit (adapter-static) served as plain static files.
# Multi-arch by construction (node + caddy are both multi-arch), so it runs native on any host.

# ── stage 1: prerender the static site ──────────────────────────────────────────────────────────
FROM node:26.11.1-bookworm-slim@sha256:86f07bc9c5dce4578cf37e5a418b7bfc7f817cda25cde66e2b66e95ed86c4567 AS web
ARG SOURCE_DATE_EPOCH=0
# pnpm is the npm registry's JavaScript release, admitted only by this exact digest and run by this Node.js; with
# pmOnFail=error (pnpm-workspace.yaml) it never downloads another pnpm when packageManager disagrees.
ARG PNPM_SHA256=2b567aa66026238078ac2e0a33bec3febd60e962987aac697456f3180819b287
RUN node --input-type=module -e ' \
      import { createHash } from "node:crypto"; \
      import { writeFileSync } from "node:fs"; \
      const response = await fetch("https://registry.npmjs.org/pnpm/-/pnpm-11.9.0.tgz"); \
      if (!response.ok) throw new Error(`pnpm download failed: ${response.status}`); \
      const bytes = Buffer.from(await response.arrayBuffer()); \
      const digest = createHash("sha256").update(bytes).digest("hex"); \
      if (digest !== process.env.PNPM_SHA256) throw new Error(`pnpm digest mismatch: ${digest}`); \
      writeFileSync("/tmp/pnpm.tgz", bytes);' \
 && mkdir /opt/pnpm \
 && tar -xzf /tmp/pnpm.tgz -C /opt/pnpm --strip-components=1 --no-same-owner \
 && rm /tmp/pnpm.tgz \
 && ln -s /opt/pnpm/bin/pnpm.mjs /usr/local/bin/pnpm \
 && node --version && pnpm --version \
 && test "$(node --version)" = v26.11.1 \
 && test "$(pnpm --version)" = 11.9.0
WORKDIR /w
# No dependency install script runs: the shared frontend package ships its sources and the build needs none.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile --ignore-scripts
COPY . .
RUN pnpm run build \
 && find /w/build -depth -exec touch -h -d "@${SOURCE_DATE_EPOCH}" {} + \
 && rm -rf /root/.cache /root/.local/share/pnpm
# adapter-static writes the prerendered site to /w/build
# Collect each prerendered page's script hash for the Caddy script-src header (script-hashes.sh).
RUN sh script-hashes.sh

# ── stage 2: serve ──────────────────────────────────────────────────────────────────────────────
FROM caddy:2.11.4-alpine@sha256:6aeddd44c3078b0f9a35206472a11420648a79c184603ef95957d0a20044cb2b AS serve
ARG SOURCE_DATE_EPOCH=0
COPY --from=web /w/build /srv
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=web /w/script-hashes /etc/caddy/script-hashes
# The upstream binary carries cap_net_bind_service for ports below 1024. This image listens only on
# 8080, so remove the file capability; otherwise a Compose-level `cap_drop: ALL` makes exec fail.
RUN setcap -r /usr/bin/caddy
# Caddy runs as an unprivileged identity; its /config and /data are tmpfs mounts the graph gives this uid.
USER 65532:65532
EXPOSE 8080
