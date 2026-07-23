<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>app.py project layout — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/" />
  <meta name="description" content="Structure the Python application of a Shimpz Assistant." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v3</a><span aria-hidden="true">/</span>
  <strong>app.py</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Authored file 2 of 2</span>
  <h1>Put all Assistant behavior in app.py</h1>
  <p class="docs-lede">
    Import <code>field</code> and <code>power</code> from the Python SDK, then write ordinary async
    functions. The decorators supply the metadata needed to generate the machine contract.
  </p>
</header>

<section class="guide-section" aria-labelledby="shape-title">
  <span class="section-label">Repository shape</span>
  <h2 id="shape-title">Keep authored intent separate from delivery</h2>
  <CodeBlock label="Minimal Assistant project" title="Project files" variant="code" {...data.projectFiles} />
  <p>
    Only <code>shimpz.toml</code> and <code>app.py</code> define the v3 Assistant contract.
    Dependency, container, test, Genesis, and Help files support packaging or current runtime surfaces;
    they do not add hidden Powers or authority.
  </p>
</section>

<section class="guide-section" aria-labelledby="application-title">
  <span class="section-label">Smallest application</span>
  <h2 id="application-title">One typed Power is enough</h2>
  <CodeBlock label="Minimal SDK-authored application" title="app.py" variant="code" {...data.application} />
</section>

<section class="guide-section" aria-labelledby="rules-title">
  <span class="section-label">Authoring rules</span>
  <h2 id="rules-title">Let Python remain Python</h2>
  <ul>
    <li>Power bodies are <code>async def</code> functions decorated with <code>@power(...)</code>.</li>
    <li>Parameters exposed to the Brain use <code>field(type, prompt=...)</code>.</li>
    <li><code>ctx</code> receives Accounts, human interaction, execution metadata, and logs.</li>
    <li>A typed return annotation becomes the closed output schema.</li>
    <li>Helper functions and internal Python values remain private implementation details.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="artifact-title">
  <span id="artifact-title" class="kicker">Build artifact</span>
  <p>
    Run <code>shimpz-assistant-contract</code> while building the image. It imports <code>app.py</code>
    and writes the canonical <code>shimpz.contract.json</code>; creators do not hand-edit that file.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/manifest/"><span>Back</span><strong>shimpz.toml</strong></a>
  <a href="/developers/assistants/spec/powers/"><span>Next</span><strong>@power</strong></a>
</nav>
