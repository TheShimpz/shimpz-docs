<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Shimpz Driver Spec v1 — Shimpz docs</title>
  <meta
    name="description"
    content="The language-neutral manifest, isolation, credential, discovery, and conformance contract for Shimpz Drivers."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/drivers/">Drivers</a><span aria-hidden="true">/</span><strong>Spec v1</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Normative contract</span>
  <h1>Driver Spec v1</h1>
  <p class="docs-lede">
    A small, closed contract for discovering a Driver and proving that its control plane preserves the
    Space and Capsule boundaries.
  </p>
</header>

<section class="guide-section" aria-labelledby="manifest-title">
  <span class="section-label">Manifest</span>
  <h2 id="manifest-title">Declare only what the platform enforces</h2>
  <p>
    Every conforming source tree contains <code>shimpz.driver.toml</code>. Unknown fields, missing fields,
    malformed TOML, unsupported values, and repeated operations must stop the Driver before it listens.
  </p>

  <CodeBlock
    label="PostgreSQL Driver Spec v1 manifest"
    title="shimpz.driver.toml"
    variant="code"
    language="toml"
    lines={[
      { value: "schema_version = 1" },
      { value: 'id = "postgresql"' },
      { value: 'title = "PostgreSQL"' },
      { value: 'version = "3.0.0"' },
      { value: 'summary = "Managed PostgreSQL databases isolated per Capsule and App."' },
      { value: 'interface = "shimpz.postgresql/v1"' },
      { value: 'scope = "space"' },
      { value: 'credential_policy = "managed"' },
      { value: 'data_plane = "direct"' },
      { value: "port = 7072" },
      { value: 'health_path = "/healthz"' },
      { value: 'metadata_path = "/v1/driver"' },
      { value: "[capabilities]" },
      { value: "operations = [" },
      { value: '  "capsule.provision",' },
      { value: '  "capsule.finalize",' },
      { value: '  "capsule.drop",' },
      { value: '  "capsule.app.create",' },
      { value: '  "capsule.app.drop",' },
      { value: "]" },
    ]}
  />

  <p>
    The machine-readable shape contract is the <a
      class="external-link"
      href="/specs/driver/v1/manifest.schema.json"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Driver Manifest v1 JSON Schema (opens in a new tab)">Driver Manifest v1 JSON Schema</a
    >.
  </p>
</section>

<section class="guide-section" aria-labelledby="fields-title">
  <span class="section-label">Fields</span>
  <h2 id="fields-title">Separate artifact, interface, and topology</h2>
  <ul>
    <li><code>schema_version</code> selects this manifest schema. v1 accepts only integer <code>1</code>.</li>
    <li><code>id</code>, <code>title</code>, <code>summary</code>, and <code>version</code> identify the Driver artifact.</li>
    <li><code>interface</code> versions the capability API independently from the artifact.</li>
    <li>
      <code>scope</code> is <code>space</code>. Tenant isolation belongs to resources and authorization, not
      to duplicate Driver processes.
    </li>
    <li>
      <code>credential_policy</code> is <code>none</code>, <code>managed</code>, or
      <code>managed-or-byok</code>. There is deliberately no required-BYOK mode.
    </li>
    <li>
      <code>data_plane</code> is <code>direct</code> when an App receives a scoped connection, or
      <code>brokered</code> when bytes and operations continue through the Driver.
    </li>
    <li><code>port</code> is the Driver's fixed internal container port.</li>
    <li>
      <code>health_path</code> and <code>metadata_path</code> identify distinct, unauthenticated discovery
      endpoints on the private Space network.
    </li>
    <li><code>capabilities.operations</code> is the exact allowlist implemented by its control API.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="interface-title">
  <span class="section-label">Interface contract</span>
  <h2 id="interface-title">An operation name is not a payload schema</h2>
  <p>
    Every <code>interface</code> identifier must resolve to versioned Driver documentation that defines its
    transport, routes, authentication authorities, request fields, response fields, status semantics,
    and retry behavior. <code>capabilities.operations</code> is a discovery allowlist; it does not replace
    that interface contract. The PostgreSQL reference documents <code>shimpz.postgresql/v1</code> with its
    implementation.
  </p>
</section>

<section class="guide-section" aria-labelledby="security-title">
  <span class="section-label">Required guarantees</span>
  <h2 id="security-title">Conformance is behavior, not a manifest badge</h2>
  <ul>
    <li>The health endpoint returns only a generic liveness verdict.</li>
    <li>The metadata endpoint returns the validated manifest and no secret or tenant inventory.</li>
    <li>Discovery endpoints are not Internet routes; they remain reachable only on private Space networks.</li>
    <li>Every state-changing operation is authenticated, allowlisted, input-validated, and audited.</li>
    <li>Tenant and provider resource identifiers are derived and validated by the Driver, not trusted from an App.</li>
    <li>Lifecycle retries cannot widen access, duplicate authority, or report success over known residue.</li>
    <li>One Capsule cannot enumerate, read, mutate, or delete another Capsule's resources.</li>
    <li>The Driver's control credential never enters an App or its Capsule data plane.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="byok-title">
  <span class="section-label">Credentials</span>
  <h2 id="byok-title">BYOK is an optional Capsule override</h2>
  <p>
    <code>none</code> means the capability has no provider credential. <code>managed</code> means only the
    Space operator configures it. <code>managed-or-byok</code> uses the Space-managed credential by
    default and permits an authenticated Captain to set or rotate an override for one Capsule; clearing
    it returns that Capsule to the managed credential. A missing or invalid update fails closed without
    replacing the last valid configuration.
  </p>
  <p>
    A BYOK value is Capsule-scoped secret configuration: it cannot appear in the manifest, discovery
    metadata, logs, error bodies, or another Capsule, and it must pass through the platform's secret
    boundary rather than an App-owned environment file.
  </p>
</section>

<section class="guide-section" aria-labelledby="language-title">
  <span class="section-label">Implementation</span>
  <h2 id="language-title">No required language or framework</h2>
  <p>
    Python, Rust, or another runtime may implement the contract. Conformance depends on the manifest,
    external interface, isolation proofs, and failure behavior. Repository location and source language
    are intentionally absent from the runtime schema.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/drivers/"><span>Back</span><strong>Drivers overview</strong></a>
  <a href="/developers/drivers/postgresql/"><span>Next</span><strong>PostgreSQL Driver</strong></a>
</nav>
