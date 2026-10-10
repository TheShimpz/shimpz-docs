# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
# shimpz-docs — docs.shimpz.com. Prerendered SvelteKit (adapter-static) served as plain static files.
# Multi-arch by construction (node + nginx are both multi-arch), so it runs native on any host.

# ── stage 1: prerender the static site ──────────────────────────────────────────────────────────
FROM node:26.11.1-bookworm-slim@sha256:86f07bc9c5dce4578cf37e5a418b7bfc7f817cda25cde66e2b66e95ed86c4567 AS web
ARG SOURCE_DATE_EPOCH=0
WORKDIR /w
# No dependency install script runs: the shared frontend package ships its sources and the build needs none.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml bootstrap-pnpm.sh ./
# The exact pnpm the manifest names, its registry tarball verified by bootstrap-pnpm.sh (Node.js 26 bundles no
# Corepack); with pmOnFail=error (pnpm-workspace.yaml) it never downloads another pnpm when packageManager disagrees.
ENV PATH="/opt/pnpm/bin:$PATH"
RUN sh bootstrap-pnpm.sh /tmp/pnpm-cache /opt/pnpm \
 && rm -rf /tmp/pnpm-cache \
 && node --version && pnpm --version \
 && pnpm install --frozen-lockfile --ignore-scripts
COPY . .
RUN pnpm run build \
 && find /w/build -depth -exec touch -h -d "@${SOURCE_DATE_EPOCH}" {} + \
 && rm -rf /root/.cache /root/.local/share/pnpm
# adapter-static writes the prerendered site to /w/build. Bind the served script-src to each prerendered page's script
# hash (script-hashes.sh renders the security-header snippet and fails when a page has no policy).
RUN sh script-hashes.sh

# ── stage 2: serve ──────────────────────────────────────────────────────────────────────────────
FROM nginxinc/nginx-unprivileged:1.30.5-alpine3.24@sha256:15c994d10d6d78658721c3bcafff14cb281fba2a4bdf9d5ba92c416a472516e3 AS serve
# nginx.conf is the whole configuration: the vendor server and the entrypoint's startup config rewrites are not used.
USER root
RUN rm /etc/nginx/conf.d/default.conf
COPY --from=web /w/build /srv
COPY nginx.conf /etc/nginx/nginx.conf
COPY installer.conf /etc/nginx/installer.conf
COPY --from=web /w/served-security-headers.conf /etc/nginx/security-headers.conf
# The graph's exact non-root identity; nginx writes only its pid and temporary files under the /tmp tmpfs.
USER 65532:65532
EXPOSE 8080
ENTRYPOINT ["nginx"]
