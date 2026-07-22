<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Assistant Spec v2 — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/" />
  <meta name="description" content="The current Shimpz Assistant manifest, runtime flow, and security contract." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Developers</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span><strong>Contract</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Assistant Spec v2</span>
  <h1>Declare intent, not authority</h1>
  <p class="docs-lede">
    The manifest tells Shimpz what an Assistant is and what it may request. The controller still decides what
    can run, where it can connect, and which private value may enter one invocation.
  </p>
</header>

<section class="guide-section" aria-labelledby="manifest-title">
  <span class="section-label">Small complete example</span>
  <h2 id="manifest-title">Cloudflare's production manifest</h2>
  <CodeBlock
    label="shimpz.assistant.toml"
    title="TOML · Assistant contract"
    lines={[
      { value: "schema_version = 2" },
      { value: 'name = "Shimpz Cloudflare"' },
      { value: 'summary = "List Cloudflare zones and inspect their DNS records through OAuth."' },
      { value: 'creators = ["@roxygens"]' },
      { value: 'github = "https://github.com/TheShimpz/shimpz-cloudflare"' },
      { value: 'allowed_hosts = ["api.cloudflare.com"]' },
      { value: "" },
      { value: "[accounts.cloudflare]" },
      { value: 'provider = "cloudflare"' },
      { value: 'scopes = ["zone.read", "dns.read", "offline_access"]' },
      { value: "" },
      { value: "[powers.list-zones]" },
      { value: 'summary = "List a bounded page of Cloudflare zones and domains."' },
      { value: 'approval = "never"' },
      { value: 'accounts = ["cloudflare"]' },
      { value: "" },
      { value: "[powers.list-dns-records]" },
      { value: 'summary = "List a bounded page of DNS records from one Cloudflare zone."' },
      { value: 'approval = "never"' },
      { value: 'accounts = ["cloudflare"]' },
    ]}
  />
</section>

<section class="guide-section" aria-labelledby="fields-title">
  <span class="section-label">What each part means</span>
  <h2 id="fields-title">Four decisions, four boundaries</h2>
  <dl>
    <dt><code>allowed_hosts</code></dt>
    <dd>Exact public DNS hosts requested by the Assistant. It is not permission for arbitrary internet access.</dd>
    <dt><code>accounts</code></dt>
    <dd>Provider and scope intent. Client credentials, endpoints, codes, and tokens never belong here.</dd>
    <dt><code>powers</code></dt>
    <dd>Named actions the Brain may request. Every Power has conventional closed input and output schemas.</dd>
    <dt><code>approval</code></dt>
    <dd><code>never</code> is only appropriate for reviewed read operations. Writes need an explicit policy.</dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="runtime-title">
  <span class="section-label">Runtime flow</span>
  <h2 id="runtime-title">Private data takes the shortest path</h2>
  <ol>
    <li>The Brain requests one declared Power with schema-shaped input.</li>
    <li>The controller validates the Team, installed image, Power, input, approval, Account, and scopes.</li>
    <li>The egress proxy admits only reviewed hosts for this Assistant.</li>
    <li>The controller delivers a short-lived Account envelope only to the selected Power.</li>
    <li>The Assistant calls the fixed provider API and returns bounded, schema-valid JSON.</li>
    <li>The Brain receives the result, never the Account token or internal execution envelope.</li>
  </ol>
</section>

<aside class="scope-note" aria-labelledby="account-secret-title">
  <span id="account-secret-title" class="kicker">Account is not Secret</span>
  <p>
    An OAuth integration is always an Account. The optional <code>secrets</code> manifest table exists for
    manually supplied opaque values, but it must never be used to collect an OAuth client secret or user token.
  </p>
</aside>

<section class="guide-section" aria-labelledby="schema-title">
  <span class="section-label">Machine-readable reference</span>
  <h2 id="schema-title">Validate the exact document</h2>
  <p>
    The <a href="/specs/assistant/v2/manifest.schema.json">Assistant v2 JSON Schema</a> is closed: unknown
    fields fail validation. Runtime admission is still the authority; passing the schema grants nothing.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/assistants/"><span>Back</span><strong>Project guide</strong></a>
  <a href="/developers/assistants/shimpz-cloudflare/"><span>Next</span><strong>Cloudflare example</strong></a>
</nav>
