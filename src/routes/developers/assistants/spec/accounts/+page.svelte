<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Accounts and ctx.accounts — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/accounts/" />
  <meta name="description" content="Request reviewed OAuth scopes and consume a bounded Account token." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v3</a><span aria-hidden="true">/</span>
  <strong>Accounts</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">OAuth access</span>
  <h1>Declare scopes; let the Controller own credentials</h1>
  <p class="docs-lede">
    An Account connects one registered OAuth provider to the Powers that need it. The provider id is
    the Account id, so the declaration cannot redirect authorization or token exchange.
  </p>
</header>

<section class="guide-section" aria-labelledby="declare-title">
  <span class="section-label">Security intent</span>
  <h2 id="declare-title">Request a reviewed scope set in shimpz.toml</h2>
  <CodeBlock label="Cloudflare Account intent" title="shimpz.toml" variant="code" {...data.manifest} />
  <p>
    The current catalog registers <code>cloudflare</code> with <code>zone.read</code>,
    <code>dns.read</code>, and <code>offline_access</code>. Unknown providers, unsupported scopes,
    duplicates, and empty lists fail admission.
  </p>
</section>

<section class="guide-section" aria-labelledby="consume-title">
  <span class="section-label">Power boundary</span>
  <h2 id="consume-title">Attach and read the Account in app.py</h2>
  <CodeBlock label="Power-scoped Account access" title="app.py" variant="code" {...data.power} />
  <p>
    A Power receives only Accounts listed in its <code>@power(accounts=[...])</code> declaration.
    Read the bearer token from <code>ctx.accounts.&lt;provider&gt;.access_token</code>.
  </p>
</section>

<section class="guide-section" aria-labelledby="flow-title">
  <span class="section-label">Token flow</span>
  <h2 id="flow-title">Private material enters at the last boundary</h2>
  <ol>
    <li>The Controller resolves provider metadata from its reviewed catalog.</li>
    <li>The person authorizes the exact scopes; Shimpz stores tokens encrypted and refreshes them.</li>
    <li>Immediately before execution, the Controller injects a bearer token only for the selected Power.</li>
    <li>The SDK exposes that token through <code>ctx.accounts</code> in the isolated process.</li>
    <li>Outputs containing injected tokens are rejected before the Brain receives them.</li>
  </ol>
</section>

<aside class="scope-note" aria-labelledby="secrets-title">
  <span id="secrets-title" class="kicker">No static Secrets surface</span>
  <p>
    Durable credentials use Accounts. Per-execution values use <code>ctx.human.request</code>.
    Never put client secrets, access tokens, refresh tokens, or ad-hoc private values in
    <code>shimpz.toml</code>, source, logs, arguments, or returned data.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/approvals/"><span>Back</span><strong>ctx.human.approval</strong></a>
  <a href="/developers/assistants/spec/network/"><span>Next</span><strong>Network access</strong></a>
</nav>
