<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>shimpz.toml — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/manifest/" />
  <meta name="description" content="Declare a Shimpz Assistant's identity and security intent." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v3</a><span aria-hidden="true">/</span>
  <strong>shimpz.toml</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Authored file 1 of 2</span>
  <h1>Declare the smallest security boundary</h1>
  <p class="docs-lede">
    <code>shimpz.toml</code> contains public identity and access intent. It never contains Power schemas,
    approval policy, OAuth endpoints, client credentials, tokens, or secret values.
  </p>
</header>

<section class="guide-section" aria-labelledby="example-title">
  <span class="section-label">Complete example</span>
  <h2 id="example-title">Five keys and optional Account tables</h2>
  <CodeBlock label="Assistant security intent" title="shimpz.toml" variant="code" {...data.manifest} />
</section>

<section class="guide-section" aria-labelledby="identity-title">
  <span class="section-label">Identity</span>
  <h2 id="identity-title">Describe one Assistant</h2>
  <dl>
    <dt><code>name</code></dt>
    <dd>A display name from 1 to 80 characters, without surrounding whitespace or line breaks.</dd>
    <dt><code>summary</code></dt>
    <dd>A single-line outcome description from 1 to 160 characters.</dd>
    <dt><code>creators</code></dt>
    <dd>One to 16 unique GitHub handles, each beginning with <code>@</code>.</dd>
    <dt><code>github</code></dt>
    <dd>The exact HTTPS URL of the public GitHub repository.</dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="access-title">
  <span class="section-label">Access intent</span>
  <h2 id="access-title">Request only what the code needs</h2>
  <dl>
    <dt><code>allowed_hosts</code></dt>
    <dd>
      A unique list of exact public DNS hostnames. Use <code>[]</code> for no network access. Schemes,
      ports, paths, wildcards, IP literals, and private or reserved names are invalid.
    </dd>
    <dt><code>[accounts.&lt;provider&gt;]</code></dt>
    <dd>
      An optional table keyed by a registered provider id. Its only key is a unique, non-empty
      <code>scopes</code> list from that provider's supported catalog.
    </dd>
  </dl>
</section>

<aside class="scope-note" aria-labelledby="validation-title">
  <span id="validation-title" class="kicker">Closed and reviewed</span>
  <p>
    Unknown keys fail validation. The
    <a href="/specs/assistant/manifest.schema.json">published shimpz.toml schema</a> describes the
    document shape; installation still cross-checks it against the generated, image-bound Power contract.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/"><span>Back</span><strong>Spec overview</strong></a>
  <a href="/developers/assistants/"><span>Next</span><strong>app.py</strong></a>
</nav>
