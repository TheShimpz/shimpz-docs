<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Integrations and ctx.integrations — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/integrations/" />
  <meta name="description" content="Request reviewed OAuth scopes and consume a bounded Integration token." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v1</a><span aria-hidden="true">/</span>
  <strong>Integrations</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">OAuth access</span>
  <h1>Declare scopes; let the Controller own credentials</h1>
  <p class="docs-lede">
    An Integration connects one registered OAuth provider to the Actions that need it. The provider id is
    the Integration id, so the declaration cannot redirect authorization or token exchange.
  </p>
</header>

<section class="guide-section" aria-labelledby="declare-title">
  <span class="section-label">Security intent</span>
  <h2 id="declare-title">Request a reviewed scope set in shimpz.toml</h2>
  <CodeBlock label="Cloudflare Integration intent" title="shimpz.toml" variant="code" {...data.manifest} />
  <p>
    The current catalog registers <code>cloudflare</code> with <code>zone.read</code>,
    <code>dns.read</code>, <code>dns.write</code>, and <code>offline_access</code>. Unknown providers,
    unsupported scopes, duplicates, and empty lists fail admission. A DNS mutation Action must separately
    declare and perform <code>auth:password</code> before it reads the bearer token; that ceremony both proves the
    mechanism and authorizes the exact pending Action. The scope declaration alone does not satisfy that gate. Shimpz is pre-production and
    <code>dns.write</code> is not yet enabled on the Cloudflare OAuth client, so a four-scope grant cannot currently
    be completed and DNS mutation Actions cannot execute.
  </p>
</section>

<section class="guide-section" aria-labelledby="consume-title">
  <span class="section-label">Action boundary</span>
  <h2 id="consume-title">Attach and read the Integration in one Action file</h2>
  <CodeBlock label="Action-scoped Integration access" title="actions/inspect_zone.py" variant="code" {...data.action} />
  <p>
    An Action receives only Integrations listed in its <code>@action(integrations=[...])</code> declaration.
    Read the bearer token from <code>ctx.integrations.&lt;provider&gt;.access_token</code>.
  </p>
</section>

<section class="guide-section" aria-labelledby="flow-title">
  <span class="section-label">Token flow</span>
  <h2 id="flow-title">Private material enters at the last boundary</h2>
  <ol>
    <li>The Controller resolves provider metadata from its reviewed catalog.</li>
    <li>The person authorizes the exact scopes; Shimpz stores tokens encrypted and refreshes them.</li>
    <li>Immediately before execution, the Controller injects a bearer token only for the selected Action.</li>
    <li>The SDK exposes that token through <code>ctx.integrations</code> in the isolated process.</li>
    <li>Outputs containing injected tokens are rejected before the Brain receives them.</li>
  </ol>
</section>

<aside class="scope-note" aria-labelledby="secrets-title">
  <span id="secrets-title" class="kicker">No static Secrets surface</span>
  <p>
    OAuth credentials use Integrations. When OAuth is unavailable, an Action may explicitly declare a final
    <a href="/developers/assistants/requests/input/#password-title"><code>input:password</code></a> request for a
    third-party secret. Never put client secrets, access tokens, refresh tokens, or private values in
    <code>shimpz.toml</code>, source, logs, arguments, or returned data.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/actions/"><span>Back</span><strong>Actions</strong></a>
  <a href="/developers/assistants/spec/network/"><span>Next</span><strong>Network access</strong></a>
</nav>
