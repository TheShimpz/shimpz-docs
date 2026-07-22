<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant manifest and identity — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/manifest/" />
  <meta name="description" content="Write the identity and top-level fields of a Shimpz Assistant manifest." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant SPEC</a><span aria-hidden="true">/</span>
  <strong>Manifest and identity</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Baby step 2</span>
  <h1>Name one Assistant clearly</h1>
  <p class="docs-lede">
    <code>shimpz.assistant.toml</code> is the index of the project. It identifies the Assistant and lists every
    Power, private dependency, and external host it may request.
  </p>
</header>

<section class="guide-section" aria-labelledby="minimal-title">
  <span class="section-label">Smallest valid manifest</span>
  <h2 id="minimal-title">Begin with no internet and one Power</h2>
  <CodeBlock
    label="Minimal Assistant manifest"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.manifest}
  />
  <p>
    <code>schema_version = 2</code> is a fixed machine value in the current contract. There is still only one
    Assistant SPEC to learn and use.
  </p>
</section>

<section class="guide-section" aria-labelledby="identity-title">
  <span class="section-label">Identity fields</span>
  <h2 id="identity-title">Fill them from top to bottom</h2>
  <dl>
    <dt><code>name</code></dt>
    <dd>A human-readable name from 1 to 80 characters. No leading or trailing whitespace or line breaks.</dd>
    <dt><code>summary</code></dt>
    <dd>One useful sentence from 1 to 240 characters. Describe the outcome, not the implementation.</dd>
    <dt><code>creators</code></dt>
    <dd>At least one unique GitHub username including <code>@</code>, such as <code>@octocat</code>.</dd>
    <dt><code>github</code></dt>
    <dd>An optional, exact HTTPS GitHub repository URL. Query strings, fragments, and other hosts are invalid.</dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="remaining-title">
  <span class="section-label">Capability fields</span>
  <h2 id="remaining-title">Add access only when another page requires it</h2>
  <ul>
    <li><code>allowed_hosts</code> is required. Use <code>[]</code> when no Power needs the internet.</li>
    <li><code>powers</code> is required and must contain at least one Power.</li>
    <li><code>accounts</code> is optional and contains only OAuth intent.</li>
    <li><code>secrets</code> is optional and contains only public descriptions of private values.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="validation-title">
  <span id="validation-title" class="kicker">The document is closed</span>
  <p>
    Unknown top-level fields fail validation. Validate the exact shape with the
    <a href="/specs/assistant/manifest.schema.json">machine-readable manifest schema</a>. Passing that schema
    proves only the document shape; it does not grant runtime authority.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant SPEC">
  <a href="/developers/assistants/"><span>Back</span><strong>Project files</strong></a>
  <a href="/developers/assistants/spec/genesis/"><span>Next</span><strong>Genesis</strong></a>
</nav>
