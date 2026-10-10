# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
# shimpz-docs — docs.shimpz.com. Prerendered SvelteKit (adapter-static) served as plain static files.
# Multi-arch by construction (node + caddy are both multi-arch), so it runs native on any host.

# ── stage 1: prerender the static site ──────────────────────────────────────────────────────────
FROM node:24-slim@sha256:d6aa754f16b3197301076f047b5def2f02ea1dbbc2ca920407d46d7ec7f87b20 AS web
ARG SOURCE_DATE_EPOCH=0
WORKDIR /w
# No dependency install script runs: the shared frontend package ships its sources and the build needs none.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN corepack enable \
 && corepack prepare pnpm@11.9.0 --activate \
 && pnpm install --frozen-lockfile --ignore-scripts
COPY . .
RUN pnpm run build \
 && find /w/build -depth -exec touch -h -d "@${SOURCE_DATE_EPOCH}" {} + \
 && rm -rf /root/.cache/node /root/.local/share/pnpm /root/.npm
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
