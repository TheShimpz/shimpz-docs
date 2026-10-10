# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
# shimpz-docs — docs.shimpz.com. Prerendered SvelteKit (adapter-static) served as plain static files.
# Multi-arch by construction (node + nginx are both multi-arch), so it runs native on any host.

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
