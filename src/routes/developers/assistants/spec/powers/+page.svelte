<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>File-backed Powers — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/powers/" />
  <meta name="description" content="Define one callable async Power per Python file." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v1</a><span aria-hidden="true">/</span>
  <strong>Powers</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Callable behavior</span>
  <h1>Define one Power per file</h1>
  <p class="docs-lede">
    A direct <code>powers/*.py</code> file contains exactly one decorated <code>async def run</code>.
    Its filename, parameters, Account ids, and return annotation become the reviewed contract.
  </p>
</header>

<section class="guide-section" aria-labelledby="declare-title">
  <span class="section-label">Declaration</span>
  <h2 id="declare-title">Use a narrow verb and object in the filename</h2>
  <CodeBlock label="One file-backed Power" title="powers/inspect_zone.py" variant="code" {...data.power} />
  <ul>
    <li><code>inspect_zone.py</code> becomes the Power id <code>inspect-zone</code>.</li>
    <li>The only decorated function is named <code>run</code> and is asynchronous.</li>
    <li><code>accounts=[...]</code> lists only Account ids declared in <code>shimpz.toml</code>.</li>
    <li>Typed parameters become required Brain input; <code>ctx</code> is invocation context.</li>
    <li>The typed return value defines the output the Brain may receive.</li>
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
    The generated route is fixed to <code>POST /v1/powers/&lt;id&gt;</code>. The Controller validates
    every input and result against the reviewed schemas.
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
  <a href="/developers/assistants/"><span>Back</span><strong>Project layout</strong></a>
  <a href="/developers/assistants/spec/accounts/"><span>Next</span><strong>Accounts</strong></a>
</nav>
