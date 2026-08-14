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

## Public documentation quality contract

### Information architecture

- Every page serves one primary audience, one user goal, and one content type: guided learning, task instructions,
  explanation, or reference. Split pages that require different reading modes; link to the canonical page instead
  of repeating it.
- Organize navigation by the reader's journey and current Shimpz product vocabulary, never by repository names,
  deployables, or internal service boundaries. Preserve the two entrances `Use Shimpz` and `Build Assistants`.
- Keep navigation no deeper than two levels beneath a section. A section contains two to eight destinations; split
  a larger group by user task. Do not add a navigation label before its destination exists and fulfills that label.
- Keep reference structure congruent with the current CLI, protocols, and product objects. Documentation must not
  invent parallel names, aliases, compatibility paths, or roadmap behavior.

### Page contracts

- Start every page with a descriptive, search-useful title and one sentence stating the outcome or reason to read.
  State audience, prerequisites, and expected time when they affect success.
- A tutorial reaches one real, observable success before optional features. It includes exact commands, expected
  state or output, the fastest likely recovery steps, and two or three deliberate next destinations.
- A task page contains only the steps needed to achieve its named result and says how to verify it. Reference is
  exhaustive and neutral. Explanation gives rationale and tradeoffs without disguising itself as a procedure.
- Every risky or state-changing flow names the authority, scope, effect, cancellation or failure behavior, and the
  visible evidence of success. Troubleshooting follows symptom, likely cause, exact check, safe fix, then escalation.

### Writing and product truth

- Lead with the user's action or outcome. Use active voice, `you`, current product labels, one concept per paragraph,
  and the minimum explanation needed at that point. Link to deeper explanation or reference.
- Every command and code sample is executable against the current contract or explicitly marked illustrative.
  Include its working directory or environment when ambiguous and show the meaningful expected result.
- Architecture owns ontology and system facts; Product owns audience, narrative, voice, evidence, and claim
  admissibility. Verify both before public copy changes. Never present planned, unavailable, or inferred behavior as
  current.
- Keep one canonical owner for each fact. Derive protocol pins, versions, commands, schemas, and generated reference
  from their authoritative artifact whenever possible; never hand-copy a value that can drift.
- A change that hand-copies CLI commands, scopes, states, output, or error codes must re-verify them against the
  published CLI source. Record the verified CLI version or commit in the change evidence; a Docs-only source test
  must not claim that it proves an independent repository's contract.
- Do not make absolute custody, browser, secrecy, availability, or security claims from a visual impression. State
  the precise current boundary and preserve enough context for the claim to remain true without an image.

### Product visuals

- Render Shimpz-owned UI states with the actual pinned public frontend primitives and inert, typed documentation
  fixtures. Do not use bitmap screenshots of approval, input, authentication, installation, error, or other
  Shimpz-owned interfaces.
- Documentation examples never submit, authenticate, fetch, mutate state, start countdowns, or import private Admin
  or Store orchestration. Render one selected request variant at a time when shared controls use document-wide ids.
- Use a screenshot only for third-party UI or spatial orientation that cannot be represented natively. Crop to the
  necessary context, remove identity and secrets, provide descriptive alt text, and keep the prose complete without
  the image. Keep diagrams source-controlled; never screenshot text or a diagram.

### Maintenance gates

- Delete stale pages, images, fixtures, and compatibility prose; Git history is the archive. Do not keep a page or
  example merely to preserve an earlier public shape while Shimpz is pre-production.
- A documentation change updates its navigation, breadcrumbs, metadata, next links, tests, and generated discovery
  artifacts in the same microtask when those surfaces are affected.
- Static tests may protect source artifacts and contract projections. They never claim rendered layout, navigation,
  interaction, accessibility, or responsive behavior; prove those against the built site with Playwright.
- Before delivery, check affected internal links and anchors, orphaned destinations, duplicate labels or titles,
  missing headings and introductions, stale generated facts, semantic controls, keyboard use, and mobile overflow.
