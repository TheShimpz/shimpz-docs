<svelte:head>
  <title>Build Shimpz Services — Shimpz docs</title>
  <meta
    name="description"
    content="Build shared Shimpz Space capabilities with narrow operations and Capsule-scoped resources."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <span>Developer guide</span><span aria-hidden="true">/</span><strong>Services</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Developer guide</span>
  <h1>Build one capability for the Space.</h1>
  <p class="docs-lede">
    A Service owns one shared infrastructure capability and exposes narrow, authenticated operations to
    authorized Capsules. It keeps provider and administrator credentials outside every Assistant.
  </p>
</header>

<aside class="scope-note" aria-labelledby="service-compatibility-title">
  <span id="service-compatibility-title" class="kicker">Compatibility boundary</span>
  <p>
    Service is the canonical product name. <code>Driver</code>, <code>shimpz.driver.toml</code>, and
    <code>/v1/driver</code> remain compatibility identifiers in Spec v1; changing those wire contracts
    requires a separate versioned migration.
  </p>
</aside>

<section class="guide-section" aria-labelledby="service-model-title">
  <span class="section-label">Architecture</span>
  <h2 id="service-model-title">Shared process, isolated authority</h2>
  <ul>
    <li>One Service instance serves one Space instead of being duplicated in every Capsule.</li>
    <li>The Service authenticates the caller and derives the exact Capsule resource server-side.</li>
    <li>Assistants request named operations; they never receive a Service control credential.</li>
    <li>BYOK is optional and remains encrypted, Capsule-bound, rotatable, and revocable in the Service.</li>
    <li>PostgreSQL and Cloudflare R2 are the current Spec v1 references.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="service-reference-title">
  <span class="section-label">Reference</span>
  <h2 id="service-reference-title">Use the proved compatibility contract</h2>
  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/developers/drivers/spec/">
        <strong>Service Spec v1</strong>
        <span>Closed <code>shimpz.driver.toml</code> manifest and security guarantees</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/drivers/postgresql/">
        <strong>PostgreSQL Service</strong>
        <span>Space-shared control with exact Capsule and workload database scope</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/drivers/r2/">
        <strong>Cloudflare R2 Service</strong>
        <span>Brokered object storage and optional Capsule-scoped BYOK</span>
      </a>
    </li>
  </ul>
</section>

<nav class="docs-page-nav" aria-label="Continue the developer guide">
  <a href="/developers/assistants/"><span>Next</span><strong>Assistants</strong></a>
</nav>
