# shimpz-docs — docs.shimpz.com. Prerendered SvelteKit (adapter-static) served as plain static files.
# Multi-arch by construction (node + caddy are both multi-arch), so it runs native on any host.

# ── stage 1: prerender the static site ──────────────────────────────────────────────────────────
FROM node:24-slim AS web
WORKDIR /w
COPY . .
RUN corepack enable \
 && corepack prepare pnpm@11.9.0 --activate \
 && pnpm install --no-frozen-lockfile \
 && pnpm run build
# adapter-static writes the prerendered site to /w/build

# ── stage 2: serve ──────────────────────────────────────────────────────────────────────────────
FROM caddy:2.11.4-alpine AS serve
COPY --from=web /w/build /srv
# SPA-safe static serving with a clean 404 fallback to the prerendered root.
RUN printf ':8080 {\n\troot * /srv\n\ttry_files {path} {path}/ {path}.html /index.html\n\tfile_server\n\tencode gzip\n}\n' > /etc/caddy/Caddyfile
EXPOSE 8080
