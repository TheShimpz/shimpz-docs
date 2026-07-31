# Public Docs repository rules

## Authority

- This repository owns public user and Creator documentation plus the installer served by `install.shimpz.com`.
- It projects published protocols and current product behavior; it does not own engineering architecture,
  producer protocols, image publication, Team authority, or runtime secrets.
- Preserve `docs.shimpz.com` and `install.shimpz.com`. Read the canonical
  [Shimpz architecture](https://github.com/TheShimpz/shimpz/blob/main/.context/ARCHITECTURE.md) before changing product
  vocabulary, installation topology, protocol mirrors, or public flows.

## Delivery and engineering

- Deliver the smallest useful microtask, validate it, commit it with a clear English conventional message, and
  push it immediately.
- When working through the umbrella checkout, commit and push this repository before committing its umbrella
  gitlink.
- Shimpz is pre-production. Document only implemented behavior; change runtime-coupled commands and paths
  atomically with their implementation and retain no compatibility instructions.
- The installer-emitted Compose is the Local topology authority. Preserve fail-closed image verification,
  loopback exposure, secret files, reset semantics, and architecture/platform checks.
- Use Node.js 24 and the pinned pnpm release. User-visible Svelte behavior requires Playwright against the built
  site.
- Tests that support workers use half of local processors and all GitHub Actions runner processors. Do not add
  Cypress or an experimental component-test runner.

## Validation

- Run `corepack pnpm@11.9.0 test`,
  `corepack pnpm@11.9.0 exec svelte-check --tsconfig ./tsconfig.json`, and
  `corepack pnpm@11.9.0 build` as applicable.
- A `static/install.sh` change cannot be committed without the umbrella checks
  `python docs/tests/test_installer.py` and `python .tests/test-team-local-delivery.py`.
