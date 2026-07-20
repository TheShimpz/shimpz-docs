<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant manifest — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/manifest/" />
  <meta
    name="description"
    content="Create a small, valid shimpz.assistant.toml manifest for an Assistant Spec v2 project."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Manifest</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Spec v2 · start here</span>
  <h1>Describe one Assistant.</h1>
  <p class="docs-lede">
    <code>shimpz.assistant.toml</code> contains identity, narrow Powers, public Secret metadata, OAuth Account
    intent, and exact external hosts. Shimpz owns private values, OAuth execution, runtime enforcement,
    packaging, and infrastructure decisions.
  </p>
</header>

<aside class="scope-note" aria-labelledby="manifest-request-title">
  <span id="manifest-request-title" class="kicker">A request, not a grant</span>
  <p>
    Power, <code>secrets</code>, <code>accounts</code>, and <code>allowed_hosts</code> declarations describe intent.
    Installation, owner consent, catalog review, and Team controller policy still decide what can run, which
    private values can be delivered, and which hosts can be reached.
  </p>
</aside>

<section class="guide-section" aria-labelledby="manifest-example-title">
  <span class="section-label">Smallest example</span>
  <h2 id="manifest-example-title">Start with no private access or egress</h2>
  <p>
    This is a complete manifest for one local, read-only Power. The conventional input and output schemas,
    <code>GENESIS.md</code>, localized Help, and executable adapter live beside it; infrastructure details do not.
  </p>
  <CodeBlock
    label="Minimal Assistant Spec v2 manifest"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.minimalManifest}
  />
</section>

<section class="guide-section" aria-labelledby="manifest-private-title">
  <span class="section-label">Private access example</span>
  <h2 id="manifest-private-title">Declare each dependency where it is used</h2>
  <p>
    This example combines manual Mux BYOK with an OAuth X Account. Values and tokens are absent. Each Power
    references only its own dependencies, so listing Mux uploads cannot receive X access and publishing to X
    cannot receive Mux credentials.
  </p>
  <CodeBlock
    label="Assistant manifest with Secrets and an Account"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.integrationManifest}
  />
</section>

<section class="guide-section" aria-labelledby="manifest-fields-title">
  <span class="section-label">Mental model</span>
  <h2 id="manifest-fields-title">Read it from top to bottom</h2>
  <ul>
    <li><code>schema_version</code> selects the closed v2 parser.</li>
    <li><code>name</code> is the display identity; Shimpz derives the stable kebab-case ID once.</li>
    <li><code>summary</code> gives people and the Brain one concise purpose.</li>
    <li><code>creators</code> contains one or more real GitHub users, including the leading <code>@</code>.</li>
    <li><code>github</code> is an optional public repository URL.</li>
    <li>
      <code>allowed_hosts</code> is the required, reviewable list of exact public DNS hosts the Assistant may
      request through the Team proxy. Use <code>[]</code> when it needs no internet access.
    </li>
    <li>
      <code>secrets</code> is optional public metadata. Each kebab-case ID has only a human-readable
      <code>name</code> and <code>summary</code>, and is bounded to 64 characters so admission and encrypted
      storage enforce the same identifier contract. An Assistant may declare at most 32; values never belong
      in source.
    </li>
    <li>
      <code>accounts</code> optionally names a reviewed OAuth provider and its narrow scopes. Endpoints,
      callbacks, Client IDs, authorization codes, PKCE verifiers, and tokens are controller-owned, not
      manifest fields. An Assistant may declare at most 16 Accounts, with at most 32 scopes each.
    </li>
    <li><code>powers</code> defines the only Assistant capabilities the Brain may request.</li>
    <li>
      <code>powers.&lt;id&gt;.secrets</code> lists the exact declared secret IDs delivered to that Power for one
      invocation, with at most 16 references.
    </li>
    <li>
      <code>powers.&lt;id&gt;.accounts</code> lists the exact declared Accounts delivered to that Power for one
      invocation, with at most four references.
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="manifest-validation-title">
  <span class="section-label">Fail closed</span>
  <h2 id="manifest-validation-title">Let validation catch drift early</h2>
  <p>
    Unknown fields, invalid creator names, duplicate IDs, unused Accounts, undefined Power Secret or Account
    references, provider credentials in source, unsafe conventional files, and open schemas are rejected.
    Each allowed host must be a unique, lowercase, exact public DNS hostname. URLs, ports, paths, wildcards,
    IP addresses, localhost, and internal names are rejected. The list accepts at most 32 hosts. The <a
      class="external-link"
      href="/specs/assistant/v2/manifest.schema.json"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Assistant Manifest v2 JSON Schema (opens in a new tab)">JSON Schema</a
    > documents the data shape. Admission also validates the conventional root <code>GENESIS.md</code>,
    localized <code>help/HELP-&lt;locale&gt;.md</code> files, and
    <code>schemas/&lt;power&gt;.(input|output).schema.json</code> files.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/"><span>Back</span><strong>Spec v2 overview</strong></a>
  <a href="/developers/assistants/spec/genesis/"><span>Next</span><strong>Genesis</strong></a>
</nav>
