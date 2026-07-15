<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>PostgreSQL Service — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/services/postgresql/" />
  <meta
    name="description"
    content="The first Service Spec v1 implementation: one PostgreSQL control service with exact Capsule and workload database scope."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/services/">Services</a><span aria-hidden="true">/</span><strong>PostgreSQL</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Conforming reference · Service Spec v1</span>
  <h1>PostgreSQL Service</h1>
  <p class="docs-lede">
    One Space service owns the PostgreSQL administrator credential, provisions exact database roles,
    and gives each Capsule access only to its registered database set.
  </p>
</header>

<aside class="scope-note" aria-labelledby="postgres-assistant-status-title">
  <span id="postgres-assistant-status-title" class="kicker">Assistant binding status</span>
  <p>
    The Service control plane and its Capsule isolation proofs exist today. The Assistant capability-binding
    runtime has not been released, so this page does not claim that an Assistant can request or receive a
    PostgreSQL database yet.
  </p>
</aside>

<section class="guide-section" aria-labelledby="postgres-boundary-title">
  <span class="section-label">Security boundary</span>
  <h2 id="postgres-boundary-title">The control credential stops at the Service</h2>
  <ul>
    <li>Only the PostgreSQL Service holds the administrator DSN.</li>
    <li>The provisioner uses a dedicated Bearer token for Capsule creation and finalization.</li>
    <li>Each Capsule receives a random principal; the Service stores its hash and exact database set.</li>
    <li>Database and role names are derived on the server from validated Capsule and workload identifiers.</li>
    <li>The current compatibility runtime issues only a database URL scoped to the registered workload.</li>
    <li>No generic SQL, global list, arbitrary create, or arbitrary drop operation is exposed.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="postgres-discovery-title">
  <span class="section-label">Discovery</span>
  <h2 id="postgres-discovery-title">Internal discovery, protected mutations</h2>
  <CodeBlock
    label="PostgreSQL Service discovery and protected control routes"
    title="HTTP · shimpz.postgresql/v1"
    lines={[
      { value: "GET  /healthz" },
      { value: "GET  /v1/driver" },
      { value: "POST /v1/capsules/provision" },
      { value: "POST /v1/capsules/finalize" },
      { value: "POST /v1/capsules/apps/create" },
      { value: "POST /v1/capsules/apps/drop" },
      { value: "POST /v1/capsules/drop" },
    ]}
  />
  <p>
    <code>/v1/driver</code> and the <code>/apps/</code> route segments are retained wire identifiers from
    before the public Service and Assistant rename. The two <code>GET</code> routes reveal only liveness and
    validated manifest metadata. Every
    <code>POST</code> route requires the correct Bearer authority for its exact operation. These endpoints
    are internal to private Space networks and must not be routed to the Internet.
  </p>
</section>

<section class="guide-section" aria-labelledby="postgres-interface-title">
  <span class="section-label">shimpz.postgresql/v1</span>
  <h2 id="postgres-interface-title">Request and response contract</h2>
  <p>
    Control requests are JSON objects with <code>Content-Type: application/json</code>. A successful
    mutation returns HTTP 200 and a <code>trace_id</code>; errors return a generic <code>error</code> without
    reflecting SQL, subprocess output, credentials, or an upstream body.
  </p>
  <p>
    The <code>capsule.app.*</code> operation names and <code>app_id</code> field below are legacy wire
    compatibility identifiers. New public documentation calls that workload an Assistant; these identifiers
    can change only through a versioned interface migration.
  </p>
  <ul>
    <li>
      <code>capsule.provision</code> uses provisioner authority with <code>capsule_id</code> and
      <code>principal_token</code>; it returns <code>database_url</code> and <code>created</code>.
    </li>
    <li>
      <code>capsule.finalize</code> uses provisioner authority with <code>capsule_id</code>; it returns
      <code>finalized</code>.
    </li>
    <li>
      <code>capsule.app.create</code> uses that Capsule's principal with <code>capsule_id</code> and
      <code>app_id</code>; it returns <code>database_url</code> and <code>created</code>.
    </li>
    <li>
      <code>capsule.app.drop</code> uses that Capsule's principal with <code>capsule_id</code> and
      <code>app_id</code>; it returns the exact <code>dropped</code> database and may report
      <code>already_absent</code> for a proved retry.
    </li>
    <li>
      <code>capsule.drop</code> uses that Capsule's principal with <code>capsule_id</code>; it returns the
      exact <code>dropped</code> database list and retires the principal for retry-safe finalization.
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="postgres-proof-title">
  <span class="section-label">Conformance proof</span>
  <h2 id="postgres-proof-title">What conforms now</h2>
  <ul>
    <li>The manifest is parsed with a closed allowlist before the listener or token state starts.</li>
    <li>Malformed, incomplete, unknown, Capsule-scoped, and required-BYOK declarations fail closed.</li>
    <li>Discovery metadata matches the in-image manifest exactly.</li>
    <li>Unauthenticated mutations remain forbidden, including the Docker healthcheck's live auth probe.</li>
    <li>
      Provision, retry, workload teardown, Capsule retirement, and legacy-route denial retain their isolation
      tests.
    </li>
  </ul>
  <p>
    Read the <a
      class="external-link"
      href="https://github.com/roxygens/shimpz-drivers/tree/main/pg"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="PostgreSQL Service source on GitHub (opens in a new tab)">PostgreSQL Service source</a
    >.
  </p>
</section>

<aside class="scope-note" aria-labelledby="delivery-boundary-title">
  <span id="delivery-boundary-title" class="kicker">Delivery boundary</span>
  <p>
    Conformance covers the current source and control contract. It does not claim that the public
    Admin installer can install this Service, that Assistants can bind to it, or that a standalone Service
    image has been released.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/services/spec/"><span>Back to</span><strong>Service Spec v1</strong></a>
  <a href="/developers/services/r2/"><span>Next</span><strong>Cloudflare R2 Service</strong></a>
</nav>
