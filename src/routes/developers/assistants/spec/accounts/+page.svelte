<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant Accounts — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/accounts/" />
  <meta name="description" content="Declare OAuth Account intent and attach it only to Powers that need it." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant SPEC</a><span aria-hidden="true">/</span><strong>Accounts</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Baby step 6</span>
  <h1>Request an OAuth identity without handling tokens</h1>
  <p class="docs-lede">
    An Account says which registered provider and scopes a Power needs. The manifest contains public intent
    only; OAuth endpoints, client credentials, authorization codes, and tokens never belong in it.
  </p>
</header>

<section class="guide-section" aria-labelledby="declare-title">
  <span class="section-label">Step 1</span>
  <h2 id="declare-title">Name the Account and its complete scope set</h2>
  <CodeBlock
    label="OAuth Account declaration"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.account}
  />
  <p>
    <code>records</code> is the local Account ID used by Powers. <code>registered-provider</code> is a placeholder:
    a real provider ID and every scope must already exist in Shimpz's trusted provider registry.
  </p>
</section>

<section class="guide-section" aria-labelledby="attach-title">
  <span class="section-label">Step 2</span>
  <h2 id="attach-title">Attach it only to the Power that needs it</h2>
  <CodeBlock
    label="Power Account reference"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.power}
  />
  <p>A Power without the reference receives no Account envelope, even when another Power uses that Account.</p>
</section>

<section class="guide-section" aria-labelledby="runtime-title">
  <span class="section-label">What the declaration causes</span>
  <h2 id="runtime-title">Consent happens only when needed</h2>
  <ol>
    <li>The Brain requests a Power that references the Account.</li>
    <li>If the Account is missing or expired, Shimpz pauses the turn.</li>
    <li>The person reviews the provider and exact scopes on the provider's website.</li>
    <li>Shimpz resumes the same turn after successful authorization.</li>
    <li>Only the selected Power receives a bounded private Account envelope.</li>
  </ol>
</section>

<section class="guide-section" aria-labelledby="limits-title">
  <span class="section-label">Closed limits</span>
  <h2 id="limits-title">Keep Account intent small</h2>
  <ul>
    <li>At most 16 Accounts per Assistant.</li>
    <li>Account IDs are lowercase kebab-case and at most 64 characters.</li>
    <li>Each Account has 1–32 unique scopes; each scope is at most 80 characters.</li>
    <li>Each Power may reference at most four declared Accounts.</li>
    <li>Undefined Account IDs and unregistered providers or scopes fail admission.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="not-secret-title">
  <span id="not-secret-title" class="kicker">Account is not Secret</span>
  <p>
    Never collect an OAuth client secret, access token, or refresh token through <code>secrets</code>. OAuth
    identities always use <code>accounts</code> so Shimpz can own consent, encrypted custody, refresh, and revocation.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant SPEC">
  <a href="/developers/assistants/spec/approvals/"><span>Back</span><strong>Approvals</strong></a>
  <a href="/developers/assistants/spec/secrets/"><span>Next</span><strong>Secrets</strong></a>
</nav>
