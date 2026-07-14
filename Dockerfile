# syntax=docker/dockerfile:1@sha256:87999aa3d42bdc6bea60565083ee17e86d1f3339802f543c0d03998580f9cb89
# shimpz-docs — docs.shimpz.com. Prerendered SvelteKit (adapter-static) served as plain static files.
# Multi-arch by construction (node + caddy are both multi-arch), so it runs native on any host.

# ── stage 1: prerender the static site ──────────────────────────────────────────────────────────
FROM node:24-slim@sha256:b31e7a42fdf8b8aa5f5ed477c72d694301273f1069c5a2f71d53c6482e99a2fc AS web
ARG SOURCE_DATE_EPOCH=0
WORKDIR /w
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN corepack enable \
 && corepack prepare pnpm@11.9.0 --activate \
 && pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build \
 && find /w/build -depth -exec touch -h -d "@${SOURCE_DATE_EPOCH}" {} + \
 && rm -rf /root/.cache/node /root/.local/share/pnpm /root/.npm
# adapter-static writes the prerendered site to /w/build

# ── stage 2: serve ──────────────────────────────────────────────────────────────────────────────
FROM caddy:2.11.4-alpine@sha256:5f5c8640aae01df9654968d946d8f1a56c497f1dd5c5cda4cf95ab7c14d58648 AS serve
ARG SOURCE_DATE_EPOCH=0
COPY --from=web /w/build /srv
COPY Caddyfile /etc/caddy/Caddyfile
# The upstream binary carries cap_net_bind_service for ports below 1024. This image listens only on
# 8080, so remove the file capability; otherwise a Compose-level `cap_drop: ALL` makes exec fail.
RUN setcap -r /usr/bin/caddy
EXPOSE 8080
