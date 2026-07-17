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
    <code>shimpz.assistant.toml</code> connects identity, Rules, Powers, permissions, and the runnable
    artifact in one closed contract.
  </p>
</header>

<aside class="scope-note" aria-labelledby="manifest-request-title">
  <span id="manifest-request-title" class="kicker">A request, not a grant</span>
  <p>
    The manifest declares what the Assistant needs. Installation, owner consent, and Capsule controller
    policy still decide what it may use.
  </p>
</aside>

<section class="guide-section" aria-labelledby="manifest-example-title">
  <span class="section-label">Smallest useful example</span>
  <h2 id="manifest-example-title">Keep the first manifest boring</h2>
  <p>
    This project has one Rule file, one Power, no external permissions, and a local development artifact.
    Add a concept only when the Assistant needs it.
  </p>
  <CodeBlock
    label="Minimal Assistant Spec v2 manifest"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.manifest}
  />
</section>

<section class="guide-section" aria-labelledby="manifest-fields-title">
  <span class="section-label">Mental model</span>
  <h2 id="manifest-fields-title">Read it from top to bottom</h2>
  <ul>
    <li><code>id</code>, <code>name</code>, <code>version</code>, and <code>description</code> identify the release.</li>
    <li><code>rules</code> points to the Assistant's behavior guide.</li>
    <li><code>artifact</code> describes how the process is started and checked.</li>
    <li><code>powers</code> define the only Assistant capabilities it may request.</li>
    <li><code>permissions</code> request narrowly scoped access outside this Assistant.</li>
    <li><code>routines</code> are optional, owner-disabled schedules for declared Powers.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="manifest-validation-title">
  <span class="section-label">Fail closed</span>
  <h2 id="manifest-validation-title">Let validation catch drift early</h2>
  <p>
    Unknown fields, mixed vocabulary, duplicate IDs, unsafe paths, mutable release images, and undeclared
    routine Powers are rejected. The <a
      class="external-link"
      href="/specs/assistant/v2/manifest.schema.json"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Assistant Manifest v2 JSON Schema (opens in a new tab)">JSON Schema</a
    > documents the data shape; the SDK parser also performs filesystem, UTF-8, and secret-safety checks.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/"><span>Back</span><strong>Spec v2 overview</strong></a>
  <a href="/developers/assistants/spec/rules/"><span>Next</span><strong>Rules</strong></a>
</nav>
