<svelte:head>
  <title>Build Shimpz Drivers — Shimpz docs</title>
  <meta
    name="description"
    content="Understand the Space-wide Shimpz Driver architecture and the incremental Driver Spec v1 migration."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <span>Developer guide</span><span aria-hidden="true">/</span><strong>Drivers</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Developer guide</span>
  <h1>Build one service for the Space.</h1>
  <p class="docs-lede">
    A Driver owns one infrastructure capability and exposes a narrow, authenticated interface to the
    Capsules authorized to use it. Driver Spec v1 makes that boundary portable across languages and
    repositories.
  </p>
</header>

<aside class="scope-note" aria-labelledby="conformance-status-title">
  <span id="conformance-status-title" class="kicker">Conformance status</span>
  <p>
    PostgreSQL is the only Driver conforming to v1. Existing Drivers remain unchanged until each one is
    migrated and proved independently. R2 is the next migration target.
  </p>
</aside>

<section class="guide-section" aria-labelledby="driver-model-title">
  <span class="section-label">Architecture</span>
  <h2 id="driver-model-title">Space-wide control, Capsule-scoped resources</h2>
  <ul>
    <li>One Driver instance serves one Space. v1 does not deploy a copy inside every Capsule.</li>
    <li>The control API authenticates the caller and derives tenant identifiers on the server.</li>
    <li>Resources and credentials are bound to the exact Capsule or App that requested them.</li>
    <li>Apps receive only the scoped data-plane access they need, never the Driver's control credential.</li>
    <li>BYOK is optional. A Driver may support it alongside a managed credential, but cannot require it in v1.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="driver-reference-title">
  <span class="section-label">Reference</span>
  <h2 id="driver-reference-title">Start with the contract</h2>
  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/developers/drivers/spec/">
        <strong>Driver Spec v1</strong>
        <span>Manifest, security boundary, and conformance rules</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/drivers/postgresql/">
        <strong>PostgreSQL Driver</strong>
        <span>The first v1-conforming reference</span>
      </a>
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="migration-title">
  <span class="section-label">Migration</span>
  <h2 id="migration-title">One Driver at a time</h2>
  <p>
    Each migrated Driver is intended to live in its own repository. Repository extraction is a
    distribution step, not a field in the runtime manifest: the same contract must remain valid before
    and after the source moves. PostgreSQL establishes the pattern without forcing unreviewed changes on
    the other Drivers.
  </p>
</section>

<nav class="docs-page-nav" aria-label="Continue the developer guide">
  <a href="/developers/drivers/spec/"><span>Next</span><strong>Driver Spec v1</strong></a>
</nav>
