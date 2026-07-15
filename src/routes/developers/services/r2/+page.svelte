<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Cloudflare R2 Service — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/services/r2/" />
  <meta
    name="description"
    content="Service Spec v1 control plane for brokered Cloudflare R2 storage, managed fallback, and Capsule-scoped BYOK."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/services/">Services</a><span aria-hidden="true">/</span><strong>Cloudflare R2</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Control-plane reference · Service Spec v1</span>
  <h1>Cloudflare R2 Service</h1>
  <p class="docs-lede">
    One Space service brokers object-storage operations. Its public discovery contract describes both the
    Space-managed credential and optional, isolated credential sets owned by each Capsule.
  </p>
</header>

<aside class="scope-note" aria-labelledby="r2-proof-boundary-title">
  <span id="r2-proof-boundary-title" class="kicker">Current proof boundary</span>
  <p>
    The Admin-to-Capsule-to-R2 credential control plane is implemented for the
    <code>secret-fields</code> profile: an authorized Captain can create, list, verify, rotate, and remove
    multiple named R2 credential sets per Capsule. This does not claim Assistant consumption or production
    activation: the Assistant capability-binding runtime has not been released, and the current deployment
    host cannot complete the live Admin proof until Docker exposes the required <code>runsc</code> runtime.
  </p>
</aside>

<section class="guide-section" aria-labelledby="r2-model-title">
  <span class="section-label">Topology</span>
  <h2 id="r2-model-title">Space service, brokered data plane</h2>
  <ul>
    <li><code>scope = space</code>: one Service belongs to the Space, not to each Capsule.</li>
    <li><code>data_plane = brokered</code>: operations remain behind the Service instead of exposing its key.</li>
    <li>
      <code>credential_policy = managed-or-byok</code>: the contract keeps BYOK optional and declares the
      intended selection policy. When Assistant binding lands, the managed Space credential is the fallback
      if no Capsule override is selected; no released Assistant data plane executes that selection today.
    </li>
    <li>
      The declarative form fixes <code>owner_scope</code> to <code>capsule</code> and
      <code>cardinality</code> to <code>many</code>, allowing multiple named R2 credential sets per Capsule.
    </li>
  </ul>
  <p>
    The current runtime executes the credential lifecycle, exact Capsule ownership checks, encrypted
    custody, and fail-closed updates. Selection of a credential set by an Assistant remains outside this proof.
  </p>
</section>

<section class="guide-section" aria-labelledby="r2-discovery-title">
  <span class="section-label">Discovery</span>
  <h2 id="r2-discovery-title">Definitions are public inside the private Service network</h2>
  <CodeBlock
    label="Cloudflare R2 Service discovery routes"
    title="HTTP · shimpz.r2/v1"
    lines={[
      { value: "GET /healthz" },
      { value: "GET /v1/driver" },
      { value: "GET /v1/driver/credentials" },
    ]}
  />
  <p>
    The <code>/v1/driver</code> path is retained for wire compatibility with existing runtimes. The manifest
    endpoint returns the validated Service contract. The credential endpoint returns only
    form definitions—field identifiers, labels, types, named formats, and bounds. Neither endpoint returns
    a credential value, credential inventory, provider token, environment variable, or bucket contents.
  </p>
</section>

<section class="guide-section" aria-labelledby="r2-conformance-title">
  <span class="section-label">Conformance proof</span>
  <h2 id="r2-conformance-title">What conforms now</h2>
  <ul>
    <li>The closed manifest selects Service Spec v1, Space scope, brokered data, and optional BYOK.</li>
    <li>The closed credential form accepts only the reusable v1 field formats needed by an R2 access key.</li>
    <li>Both files pass strict parsers before the service starts and are returned unchanged by discovery.</li>
    <li>The Admin renders that form and proxies the five lifecycle operations without returning secret values.</li>
    <li>A separate per-Capsule principal prevents one Capsule from listing or mutating another's inventory.</li>
    <li>
      Create and rotate verify the candidate first; authenticated encryption binds its identities and
      generation, while compare-and-swap rejects stale changes.
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="r2-next-title">
  <span class="section-label">Deliberate boundary</span>
  <h2 id="r2-next-title">Bind Assistants without exposing keys</h2>
  <p>
    Service Spec v1 now covers custody and lifecycle, but the Assistant capability-binding runtime is not
    released and has no admitted <code>credential_ref</code> or scoped grant path. Assistants cannot consume
    these credential sets today, and the existing R2 object routes continue to use the Space-managed
    credential. The next data-plane slice must
    pass only an opaque reference and an exact operation grant to the broker; it must never inject the
    submitted access key into an Assistant or Capsule environment.
  </p>
  <p>
    OAuth, passkeys, and Redpanda are not part of this R2 runtime. Their Service Spec shapes are architecture
    for later platform-owned adapters and events, not a claim that Cloudflare OAuth or passkey authorization
    is available today.
  </p>
  <p>
    Production Capsule operations are hard-gated on gVisor. Because <code>runsc</code> is not registered on
    the current host, the Capsule controller (internally still named <code>capsule-driver</code>) fails closed
    instead of silently using <code>runc</code>; focused contract and lifecycle tests do not replace that
    pending live isolation proof.
  </p>
  <p>
    Read the <a
      class="external-link"
      href="https://github.com/roxygens/shimpz-drivers/tree/main/r2"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Cloudflare R2 Service source on GitHub (opens in a new tab)">Cloudflare R2 Service source</a
    >.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/services/postgresql/"><span>Back</span><strong>PostgreSQL Service</strong></a>
  <a href="/developers/services/spec/"><span>Reference</span><strong>Service Spec v1</strong></a>
</nav>
