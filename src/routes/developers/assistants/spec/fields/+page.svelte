<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>field() Brain inputs — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/fields/" />
  <meta name="description" content="Declare typed, prompted Brain inputs with the Shimpz Python SDK." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v3</a><span aria-hidden="true">/</span>
  <strong>field()</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Brain input</span>
  <h1>Describe every Power argument with field()</h1>
  <p class="docs-lede">
    A <code>field</code> is a required value the Brain supplies before execution. Its Python type
    constrains the value; its prompt tells the Brain what the value means.
  </p>
</header>

<section class="guide-section" aria-labelledby="types-title">
  <span class="section-label">Supported types</span>
  <h2 id="types-title">Use the smallest type that fits</h2>
  <dl>
    <dt><code>str</code></dt>
    <dd>Text.</dd>
    <dt><code>int</code></dt>
    <dd>A whole number.</dd>
    <dt><code>float</code></dt>
    <dd>A JSON number.</dd>
    <dt><code>bool</code></dt>
    <dd><code>true</code> or <code>false</code>.</dd>
    <dt><code>choice("a", "b")</code></dt>
    <dd>Exactly one string from a closed option set.</dd>
    <dt><code>choices("a", "b")</code></dt>
    <dd>A unique list of strings from a closed option set.</dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="declare-title">
  <span class="section-label">Declaration</span>
  <h2 id="declare-title">Put validation next to the parameter</h2>
  <CodeBlock label="Typed Brain fields" title="app.py" variant="code" {...data.fields} />
  <p>
    Use <code>typing.Annotated</code> for compatible JSON Schema bounds such as string length,
    numeric minimum or maximum, array length, and string patterns.
  </p>
</section>

<section class="guide-section" aria-labelledby="schema-title">
  <span class="section-label">Generated input schema</span>
  <h2 id="schema-title">Names and prompts become the Brain contract</h2>
  <CodeBlock label="Excerpt of generated input schema" title="shimpz.contract.json" variant="code" {...data.schema} />
</section>

<aside class="scope-note" aria-labelledby="human-title">
  <span id="human-title" class="kicker">Brain input is not human input</span>
  <p>
    Use <code>field()</code> for arguments the Brain knows when it selects a Power. Use
    <code>ctx.human.request(...)</code> when execution must pause and ask a person directly.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/powers/"><span>Back</span><strong>@power</strong></a>
  <a href="/developers/assistants/spec/human/"><span>Next</span><strong>ctx.human.request</strong></a>
</nav>
