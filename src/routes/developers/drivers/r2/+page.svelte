<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Cloudflare R2 Driver — Shimpz docs</title>
  <meta
    name="description"
    content="Driver Spec v1 discovery for brokered Cloudflare R2 storage, managed fallback, and declarative Capsule-scoped BYOK."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/drivers/">Drivers</a><span aria-hidden="true">/</span><strong>Cloudflare R2</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Declarative reference · Driver Spec v1</span>
  <h1>Cloudflare R2 Driver</h1>
  <p class="docs-lede">
    One Space service brokers object-storage operations. Its public discovery contract describes both the
    Space-managed credential and optional, isolated credential sets owned by each Capsule.
  </p>
</header>

<aside class="scope-note" aria-labelledby="r2-proof-boundary-title">
  <span id="r2-proof-boundary-title" class="kicker">Current proof boundary</span>
  <p>
    R2 currently conforms at manifest and credential-form discovery. The end-to-end Capsule credential
    lifecycle is not implemented yet, so this page does not claim that BYOK values can already be created,
    stored, rotated, removed, or used safely through the Admin.
  </p>
</aside>

<section class="guide-section" aria-labelledby="r2-model-title">
  <span class="section-label">Topology</span>
  <h2 id="r2-model-title">Space service, brokered data plane</h2>
  <ul>
    <li><code>scope = space</code>: one Driver service belongs to the Space, not to each Capsule.</li>
    <li><code>data_plane = brokered</code>: operations remain behind the Driver instead of exposing its key.</li>
    <li>
      <code>credential_policy = managed-or-byok</code>: BYOK is optional and the managed Space credential is
      the fallback only when a Capsule has no active override.
    </li>
    <li>
      The declarative form fixes <code>owner_scope</code> to <code>capsule</code> and
      <code>cardinality</code> to <code>many</code>, allowing multiple named R2 credential sets per Capsule.
    </li>
  </ul>
  <p>
    These are validated v1 declarations. Runtime fallback, ownership checks, encryption, and fail-closed
    selection still require the lifecycle implementation and its isolation proofs.
  </p>
</section>

<section class="guide-section" aria-labelledby="r2-discovery-title">
  <span class="section-label">Discovery</span>
  <h2 id="r2-discovery-title">Definitions are public inside the private Driver network</h2>
  <CodeBlock
    label="Cloudflare R2 Driver discovery routes"
    title="HTTP · shimpz.r2/v1"
    lines={[
      { value: "GET /healthz" },
      { value: "GET /v1/driver" },
      { value: "GET /v1/driver/credentials" },
    ]}
  />
  <p>
    The manifest endpoint returns the validated service contract. The credential endpoint returns only
    form definitions—field identifiers, labels, types, named formats, and bounds. Neither endpoint returns
    a credential value, credential inventory, provider token, environment variable, or bucket contents.
  </p>
</section>

<section class="guide-section" aria-labelledby="r2-conformance-title">
  <span class="section-label">Conformance proof</span>
  <h2 id="r2-conformance-title">What conforms now</h2>
  <ul>
    <li>The closed manifest selects Driver Spec v1, Space scope, brokered data, and optional BYOK.</li>
    <li>The closed credential form accepts only the reusable v1 field formats needed by an R2 access key.</li>
    <li>Both files pass strict parsers before the service starts and are returned unchanged by discovery.</li>
    <li>Discovery is definition-only and has no field where a submitted key or provider token can appear.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="r2-next-title">
  <span class="section-label">Next delivery slice</span>
  <h2 id="r2-next-title">Prove the complete credential lifecycle</h2>
  <p>
    The next implementation must connect the Admin to <code>credential.create</code>,
    <code>credential.list</code>, <code>credential.verify</code>, <code>credential.rotate</code>, and
    <code>credential.remove</code>; enforce Capsule ownership, compare-and-swap generations, authenticated
    encryption with bound AAD, provider verification, and request-scoped R2 use; then prove managed fallback
    and failure behavior. Until those tests pass, declarative discovery is the only BYOK conformance claim.
  </p>
  <p>
    Read the <a
      class="external-link"
      href="https://github.com/roxygens/shimpz-drivers/tree/main/r2"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Cloudflare R2 Driver source on GitHub (opens in a new tab)">Cloudflare R2 Driver source</a
    >.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/drivers/postgresql/"><span>Back</span><strong>PostgreSQL Driver</strong></a>
  <a href="/developers/drivers/spec/"><span>Reference</span><strong>Driver Spec v1</strong></a>
</nav>
