<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>@power — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/powers/" />
  <meta name="description" content="Declare callable async operations with the Shimpz Python SDK." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v3</a><span aria-hidden="true">/</span>
  <strong>@power</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Callable behavior</span>
  <h1>Expose one bounded async operation</h1>
  <p class="docs-lede">
    <code>@power()</code> registers an async function for the Brain. The function name, declared fields,
    Account ids, and return annotation become the reviewed machine contract.
  </p>
</header>

<section class="guide-section" aria-labelledby="declare-title">
  <span class="section-label">Declaration</span>
  <h2 id="declare-title">Use a narrow verb and object</h2>
  <CodeBlock label="One SDK-authored Power" title="app.py" variant="code" {...data.power} />
  <ul>
    <li>The Python function name is the Power id.</li>
    <li>The body must be asynchronous.</li>
    <li><code>accounts=[...]</code> lists only Account ids declared in <code>shimpz.toml</code>.</li>
    <li>Each <code>field(...)</code> parameter becomes required Brain input.</li>
    <li>The return annotation defines the output the Brain may receive.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="contract-title">
  <span class="section-label">Derived contract</span>
  <h2 id="contract-title">Do not hand-write transport or schemas</h2>
  <CodeBlock
    label="Illustrative generated Power entry"
    title="shimpz.contract.json"
    variant="code"
    {...data.contract}
  />
  <p>
    The SDK fixes the route to <code>POST /v1/powers/&lt;id&gt;</code>. The Controller reviews this
    generated entry and validates every request and response against it.
  </p>
</section>

<aside class="scope-note" aria-labelledby="boundary-title">
  <span id="boundary-title" class="kicker">Keep Powers specific</span>
  <p>
    Do not expose arbitrary URLs, methods, headers, shell commands, or raw provider responses.
    A Power should describe one useful result and return only the fields the Brain needs.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/"><span>Back</span><strong>app.py</strong></a>
  <a href="/developers/assistants/spec/fields/"><span>Next</span><strong>field()</strong></a>
</nav>
