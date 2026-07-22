<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Shimpz Service Spec v1 — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/services/spec/" />
  <meta
    name="description"
    content="The language-neutral manifest, isolation, credential, discovery, and conformance contract for Shimpz Services."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/services/">Services</a><span aria-hidden="true">/</span><strong>Spec v1</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Normative contract</span>
  <h1>Service Spec v1</h1>
  <p class="docs-lede">
    A small, closed contract for discovering a Service and proving that its control plane preserves the
    Space and Team boundaries.
  </p>
</header>

<aside class="scope-note" aria-labelledby="service-wire-compatibility-title">
  <span id="service-wire-compatibility-title" class="kicker">Wire compatibility</span>
  <p>
    Service is the canonical product name. Spec v1 deliberately retains the legacy identifiers
    <code>shimpz.driver.toml</code>, <code>/v1/driver</code>, and <code>/specs/driver/v1/</code> so existing
    runtimes keep working. They may change only in a separately versioned migration.
  </p>
</aside>

<section class="guide-section" aria-labelledby="manifest-title">
  <span class="section-label">Manifest</span>
  <h2 id="manifest-title">Declare only what the platform enforces</h2>
  <p>
    Every conforming source tree contains <code>shimpz.driver.toml</code>. Unknown fields, missing fields,
    malformed TOML, unsupported values, and repeated operations must stop the Service before it listens.
  </p>

  <CodeBlock
    label="PostgreSQL Service Spec v1 compatibility manifest"
    title="shimpz.driver.toml"
    variant="code"
    {...data.manifest}
  />

  <p>
    This example matches the current PostgreSQL manifest. <code>App</code> and <code>team.app.*</code> inside
    the block are internal wire identifiers; the public workload name is Assistant, and renaming those
    operation IDs requires a versioned interface migration.
  </p>

  <p>
    The machine-readable shape contract is the <a
      class="external-link"
      href="/specs/driver/v1/manifest.schema.json"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Service Manifest v1 JSON Schema on the legacy driver path (opens in a new tab)">Service Manifest v1 JSON Schema</a
    >.
  </p>
</section>

<section class="guide-section" aria-labelledby="fields-title">
  <span class="section-label">Fields</span>
  <h2 id="fields-title">Separate artifact, interface, and topology</h2>
  <ul>
    <li><code>schema_version</code> selects this manifest schema. v1 accepts only integer <code>1</code>.</li>
    <li>
      <code>id</code>, <code>title</code>, <code>summary</code>, and <code>version</code> identify the Service
      artifact.
    </li>
    <li><code>interface</code> versions the capability API independently from the artifact.</li>
    <li>
      <code>scope</code> is <code>space</code>. Tenant isolation belongs to resources and authorization, not
      to duplicate Service processes.
    </li>
    <li>
      <code>credential_policy</code> is <code>none</code>, <code>managed</code>, or
      <code>managed-or-byok</code>. There is deliberately no required-BYOK mode.
    </li>
    <li>
      <code>credential_schema_path</code> is an absolute internal HTTP path required only for
      <code>managed-or-byok</code>. Services using <code>none</code> or <code>managed</code> must omit it.
    </li>
    <li>
      <code>data_plane</code> is <code>direct</code> when the runtime issues a scoped connection, or
      <code>brokered</code> when bytes and operations continue through the Service. This field does not
      claim that the Assistant capability-binding runtime is released.
    </li>
    <li><code>port</code> is the Service's fixed internal container port.</li>
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
    Every <code>interface</code> identifier must resolve to versioned Service documentation that defines its
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
    <li>
      Tenant and provider resource identifiers are derived and validated by the Service, not trusted from
      an Assistant request.
    </li>
    <li>Lifecycle retries cannot widen access, duplicate authority, or report success over known residue.</li>
    <li>One Team cannot enumerate, read, mutate, or delete another Team's resources.</li>
    <li>The Service's control credential never enters an Assistant or its Team data plane.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="byok-title">
  <span class="section-label">Credentials</span>
  <h2 id="byok-title">BYOK is an optional Team override</h2>
  <p>
    <code>none</code> means the capability has no provider credential. <code>managed</code> means only the
    Space operator configures it. <code>managed-or-byok</code> uses the Space-managed credential by
    default and permits an authenticated Captain to set or rotate an override for one Team; clearing
    it returns that Team to the managed credential. A missing or invalid update fails closed without
    replacing the last valid configuration.
  </p>
  <p>
    A BYOK value is Team-scoped secret configuration: it cannot appear in the manifest, discovery
    metadata, logs, error bodies, or another Team, and it must pass through the platform's secret
    boundary rather than an Assistant-owned environment file.
  </p>
</section>

<section class="guide-section" aria-labelledby="credential-form-title">
  <span class="section-label">Declarative form</span>
  <h2 id="credential-form-title">The Admin renders data; it never executes Service JavaScript</h2>
  <p>
    A <code>managed-or-byok</code> Service serves a credential-form document from its declared internal
    path. The platform fetches that path through the authenticated control plane, validates the complete
    document, and renders it with a platform-owned component. It never evaluates a script, imports a
    Service component, opens an iframe, or follows a provider URL supplied by the document.
  </p>

  <CodeBlock
    label="Service Spec v1 declarative credential form"
    title="credential form · JSON"
    variant="code"
    {...data.credentialForm}
  />

  <p>
    The canonical shape is the <a
      class="external-link"
      href="/specs/driver/v1/credential-form.schema.json"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Service Credential Form v1 JSON Schema on the legacy driver path (opens in a new tab)"
      >Service Credential Form v1 JSON Schema</a
    >. It is closed: unknown profile kinds, fields, formats, and options fail before the Admin displays
    or submits anything. Profile and field identifiers must also be unique within their arrays.
  </p>
  <ul>
    <li><code>owner_scope</code> is always <code>team</code>.</li>
    <li><code>cardinality</code> is <code>one</code> or <code>many</code> credential sets per Team.</li>
    <li>
      <code>secret-fields</code> accepts only <code>text</code>, <code>secret</code>, and
      <code>select</code> fields. It has no executable validator, regular-expression field, or endpoint URL.
    </li>
    <li>
      Every text or secret field selects a named v1 format and declares tighter minimum and maximum
      lengths. The Admin and Service both validate the same constraints; client validation is never authority.
    </li>
    <li>
      Secret fields require <code>write_only: true</code>. They are accepted only during create or rotate
      and are never returned by list, discovery, verification, or error responses.
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="credential-formats-title">
  <span class="section-label">Bounded formats</span>
  <h2 id="credential-formats-title">Named validation replaces arbitrary regex</h2>
  <p>
    v1 text formats are <code>plain-text</code> (256), <code>account-id</code> (128),
    <code>bucket-name</code> (63), <code>hostname</code> (253), <code>region</code> (64),
    <code>tenant-id</code> (128), and <code>username</code> (128). Secret formats are
    <code>access-key-id</code> (256), <code>api-key</code> (4096), <code>password</code> (1024),
    <code>private-key</code> (16384), <code>secret-access-key</code> (4096), and
    <code>secret-token</code> (4096). Numbers are maximum characters; the declared
    <code>max_length</code> may only narrow them, and <code>min_length</code> cannot exceed it.
  </p>
  <p>
    A <code>select</code> contains at most 64 closed, unique options. Provider endpoints, redirects, and
    network destinations come from audited platform adapters, never from a form value or form metadata.
  </p>
</section>

<section class="guide-section" aria-labelledby="credential-lifecycle-title">
  <span class="section-label">Lifecycle</span>
  <h2 id="credential-lifecycle-title">Create, list, verify, rotate, and remove share one contract</h2>
  <ul>
    <li>
      <code>credential.create</code> validates ownership, the selected profile, every field, and a
      non-destructive provider check before atomically storing a server-generated opaque credential ID at
      generation <code>1</code>. An idempotency key prevents a lost response from creating a duplicate.
    </li>
    <li>
      <code>credential.list</code> returns only the credential ID, profile ID, label, status, generation,
      and timestamps. It never returns a submitted value, encryption envelope, or provider token.
    </li>
    <li>
      <code>credential.verify</code> exercises the stored set through its Service and returns only a typed
      verdict and trace ID; verification neither reveals values nor advances the generation.
    </li>
    <li>
      <code>credential.rotate</code> requires the complete replacement plus
      <code>expected_generation</code>. The Service verifies first, commits with compare-and-swap, then
      increments the generation. A failure or stale generation preserves the previous set unchanged.
    </li>
    <li>
      <code>credential.remove</code> also requires <code>expected_generation</code>, revokes use before
      reporting success, and is idempotent for an already removed exact ID. Foreign IDs remain invisible.
    </li>
  </ul>
  <p>
    Encryption at rest uses authenticated encryption. Its additional authenticated data binds at least
    the Service ID, schema version, Team ID, credential ID, profile ID, and generation. Moving ciphertext
    between any of those identities must fail authentication. Keys, ciphertext, nonces, Bearers, and OAuth
    material never enter logs or public audit fields.
  </p>
  <p>
    No active Team override means the Service uses the Space-managed credential. Explicit removal returns
    to that managed fallback. A rejected update leaves the last valid override active, while an expired or
    failing configured override fails closed instead of silently widening authority through the managed key.
  </p>
  <p>
    Service Spec v1 defines credential custody and lifecycle, but the Assistant capability-binding runtime
    has not been released. Assistants cannot consume these credential sets today. A future binding must
    carry only an opaque reference and an exact operation grant; secret values remain inside the Service
    boundary.
  </p>
</section>

<section class="guide-section" aria-labelledby="credential-oauth-title">
  <span class="section-label">OAuth and identity</span>
  <h2 id="credential-oauth-title">Adapters own OAuth; passkeys authenticate the Admin</h2>
  <p>
    An <code>oauth2-authorization-code</code> profile declares only an Admin-allowlisted
    <code>adapter_id</code>, bounded scopes, and mandatory <code>PKCE S256</code>. Unknown adapters or scopes
    fail closed. The document cannot carry authorization URLs, token URLs, redirect URLs, client secrets,
    or executable callback code.
  </p>
  <p>
    The central OAuth broker owns provider endpoints and client registration, generates one-use state and
    the PKCE verifier, checks the exact callback, exchanges the authorization code server-side, and stores
    access and refresh tokens through the same Team-scoped secret boundary. OAuth codes and tokens never
    pass through browser storage, URL logs, a Service manifest, or an Assistant environment.
  </p>
  <p>
    A passkey is a WebAuthn credential for signing in to the Shimpz Admin. It authorizes the Captain's intent
    but is never a Service profile, provider credential, or value forwarded to a Service.
  </p>
  <p>
    PostgreSQL is the only durable coordination datastore in the current runtime. Assistant composition
    happens through reviewed Powers and Controller authorization; there is no separate event-bus credential
    or cross-Team topic path. The Service credential runtime executes the R2
    <code>secret-fields</code> lifecycle without placing secret material in Assistant environments.
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
  <a href="/developers/services/"><span>Back</span><strong>Services overview</strong></a>
  <a href="/developers/services/postgresql/"><span>Next</span><strong>PostgreSQL Service</strong></a>
</nav>
