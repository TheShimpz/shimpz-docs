<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant Secrets — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/secrets/" />
  <meta name="description" content="Describe opaque Assistant Secrets without committing or exposing their values." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant SPEC</a><span aria-hidden="true">/</span><strong>Secrets</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Baby step 7</span>
  <h1>Describe a private value without knowing it</h1>
  <p class="docs-lede">
    A Secret declaration contains only a name and purpose. The person supplies the value privately, and Shimpz
    delivers it only to a Power that explicitly references its ID.
  </p>
</header>

<section class="guide-section" aria-labelledby="declare-title">
  <span class="section-label">Step 1</span>
  <h2 id="declare-title">Write public metadata</h2>
  <CodeBlock
    label="Secret declaration"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.secret}
  />
  <p>The actual key must never appear in this file, Genesis, Help, source code, tests, examples, or logs.</p>
</section>

<section class="guide-section" aria-labelledby="attach-title">
  <span class="section-label">Step 2</span>
  <h2 id="attach-title">Reference the ID from one Power</h2>
  <CodeBlock
    label="Power Secret reference"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.power}
  />
</section>

<section class="guide-section" aria-labelledby="lifecycle-title">
  <span class="section-label">Private lifecycle</span>
  <h2 id="lifecycle-title">The value takes the shortest path</h2>
  <ol>
    <li>A Power needs a declared Secret that is not configured.</li>
    <li>Shimpz pauses the turn and shows the Secret's public name and summary.</li>
    <li>The person enters the value in the private Secret form.</li>
    <li>Shimpz resumes the same turn and delivers the value only to that Power.</li>
    <li>The Power output is rejected if it contains the protected value.</li>
  </ol>
  <p>
    Rotation replaces the value behind the same declared Secret ID. A complete replacement may rotate one or
    several IDs for the same Assistant atomically; paused work cannot restore an older generation afterward.
  </p>
</section>

<section class="guide-section" aria-labelledby="limits-title">
  <span class="section-label">Closed limits</span>
  <h2 id="limits-title">Keep each private dependency explicit</h2>
  <ul>
    <li>At most 32 Secrets per Assistant.</li>
    <li>Secret IDs are lowercase kebab-case and at most 64 characters.</li>
    <li><code>name</code> is 1–80 characters; <code>summary</code> is 1–160 characters.</li>
    <li>Each Power may reference at most 16 unique declared Secret IDs.</li>
    <li>Undefined IDs, duplicate references, and extra Secret fields fail validation.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="choice-title">
  <span id="choice-title" class="kicker">Use the right private dependency</span>
  <p>
    Use a Secret for a manually supplied opaque value. Use an Account for OAuth authorization. A database,
    controller, filesystem, or arbitrary network capability is neither and cannot be requested through this table.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant SPEC">
  <a href="/developers/assistants/spec/accounts/"><span>Back</span><strong>Accounts</strong></a>
  <a href="/developers/assistants/spec/network/"><span>Next</span><strong>Network access</strong></a>
</nav>
