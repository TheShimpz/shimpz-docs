<svelte:head>
  <title>Assistant routines — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/routines/" />
  <meta
    name="description"
    content="Understand why Assistant scheduling is owner-controlled runtime policy rather than creator manifest authority."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Routines</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Runtime policy</span>
  <h1>Schedule a Power, never arbitrary code.</h1>
  <p class="docs-lede">
    Scheduling is not a creator-controlled field in Assistant Spec v2. The current MVP runs Powers only as
    part of an active Team turn.
  </p>
</header>

<aside class="scope-note" aria-labelledby="routines-status-title">
  <span id="routines-status-title" class="kicker">Not released yet</span>
  <p>
    Owner-managed routines will arrive as Team runtime state. Installing an Assistant will never silently
    start a schedule.
  </p>
</aside>

<section class="guide-section" aria-labelledby="routines-boundary-title">
  <span class="section-label">Required boundary</span>
  <h2 id="routines-boundary-title">Recheck authority on every run</h2>
  <ul>
    <li>A routine may reference only a Power declared by an installed Assistant.</li>
    <li>The Team owner must explicitly create and enable it.</li>
    <li>Every run must reevaluate installation, policy, approval, schema, and resource limits.</li>
    <li>Single-flight execution and stable idempotency keys must make retries predictable.</li>
    <li>Disabling, uninstalling, or revoking access must stop future authority immediately.</li>
  </ul>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/permissions/"><span>Back</span><strong>Permissions</strong></a>
  <a href="/developers/assistants/spec/runtime/"><span>Next</span><strong>Brain runtime</strong></a>
</nav>
