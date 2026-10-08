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
  <a href="/developers/assistants/spec/">Assistant Spec v1</a><span aria-hidden="true">/</span>
  <strong>shimpz.toml</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Manifest and Genesis</span>
  <h1>Declare identity and the smallest security boundary</h1>
  <p class="docs-lede">
    <code>shimpz.toml</code> contains public identity, Brain guidance, and access intent. It never
    contains Action schemas, runtime commands, OAuth endpoints, client credentials, or tokens.
  </p>
</header>

<section class="guide-section" aria-labelledby="example-title">
  <span class="section-label">Complete example</span>
  <h2 id="example-title">Two required tables and optional Integration tables</h2>
  <CodeBlock label="Assistant security intent" title="shimpz.toml" variant="code" {...data.manifest} />
</section>

<section class="guide-section" aria-labelledby="identity-title">
  <span class="section-label">Identity</span>
  <h2 id="identity-title">Describe one Assistant under [shimpz]</h2>
  <dl>
    <dt><code>[shimpz]</code></dt>
    <dd>The required parent table for identity, publication disclosure, and Genesis.</dd>
    <dt><code>spec</code></dt>
    <dd>The integer <code>1</code>. No other Assistant Spec version is supported.</dd>
    <dt><code>id</code></dt>
    <dd>
      A stable identifier of 1 to 40 characters: lowercase letters and digits in hyphen-separated
      segments, starting with a letter. It is independent of repository and Python project names.
      <code>postgres</code>, <code>assistant-egress</code>, and
      <code>shimpz-assistant-egress</code> are reserved.
    </dd>
    <dt><code>version</code></dt>
    <dd>A stable semantic version such as <code>0.1.0</code>.</dd>
    <dt><code>name</code></dt>
    <dd>A display name from 1 to 80 characters, without surrounding whitespace or line breaks.</dd>
    <dt><code>summary</code></dt>
    <dd>
      A short, single-line outcome description from 1 to 80 characters, shown in full under the Assistant's name. With
      SDK 0.6.0, it joins the <a href="/developers/assistants/requests/copy/">message catalog</a> and is translated with
      it, so it must be NFC-normalized English without braces, and every translation must fit 80 characters too.
    </dd>
    <dt><code>creators</code></dt>
    <dd>One to 16 unique Account-owned Creator handles, each beginning with <code>@</code>.</dd>
    <dt><code>github</code></dt>
    <dd>The exact HTTPS URL of the public GitHub repository.</dd>
    <dt><code>genesis</code></dt>
    <dd>
      Bounded behavior and Action-composition guidance loaded by the Brain. Genesis never grants
      authority. <code>help.md</code> is not part of Assistant Spec v1 and is not loaded as Brain guidance.
    </dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="access-title">
  <span class="section-label">Access intent</span>
  <h2 id="access-title">Request only what the code needs</h2>
  <dl>
    <dt><code>[network]</code></dt>
    <dd>The required parent table for Assistant outbound network intent.</dd>
    <dt><code>allowed_hosts</code></dt>
    <dd>
      A unique list of exact public DNS hostnames. Use <code>[]</code> for no network access. Schemes,
      ports, paths, wildcards, IP literals, and private or reserved names are invalid.
    </dd>
    <dt><code>[integrations.&lt;provider&gt;]</code></dt>
    <dd>
      An optional table keyed by a registered provider id. Its only key is a unique, non-empty
      <code>scopes</code> list from that provider's supported catalog. Both the provider and every scope must exist in
      the current published catalog. Provider endpoints and OAuth client configuration remain Controller-owned.
    </dd>
    <dt><code>[stored_inputs.&lt;id&gt;]</code></dt>
    <dd>
      An optional table for a token-like third-party value that Team keeps encrypted for the Team after the first
      successful Action, at most eight per manifest. It holds <code>kind = "password"</code>, a <code>label</code> of
      1 to 80 characters, and a <code>description</code> of 1 to 500 characters, which are never translated. An Action
      names the id it uses; see
      <a href="/developers/assistants/requests/input/#password-title">password input</a>.
    </dd>
    <dt><code>help_url</code></dt>
    <dd>
      An optional key of a <code>[stored_inputs.&lt;id&gt;]</code> table: the page where a person creates the value,
      such as an API key page. It must be one canonical <code>https</code> URL of at most 2,048 characters on a public
      DNS host, with a path and an optional query, and without a port, credentials, a fragment, or a <code>.</code> or
      <code>..</code> segment, written exactly as a browser prints it: for example
      <code>https://dashboard.exa.ai/api-keys</code>, not <code>https://dashboard.exa.ai</code>.
    </dd>
  </dl>
</section>

<aside class="scope-note" aria-labelledby="validation-title">
  <span id="validation-title" class="kicker">Closed and reviewed</span>
  <p>
    Root-level fields, misplaced fields, and unknown keys fail validation. The
    <a href="/specs/assistant/manifest.schema.json">published shimpz.toml schema</a> describes the
    document shape; SDK validation and Controller admission enforce additional semantic invariants.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/"><span>Back</span><strong>Spec overview</strong></a>
  <a href="/developers/assistants/spec/execution/"><span>Next</span><strong>Execution model</strong></a>
</nav>
