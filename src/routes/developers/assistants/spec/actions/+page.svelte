<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>File-backed Actions — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/actions/" />
  <meta name="description" content="Define one callable async Action per Python file." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Creator overview</a><span aria-hidden="true">/</span>
  <strong>Actions</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Callable behavior</span>
  <h1>Define one Action per file</h1>
  <p class="docs-lede">
    A direct <code>actions/*.py</code> file contains exactly one decorated <code>async def run</code>.
    Its filename, parameters, Integration ids, and return annotation become the reviewed contract.
  </p>
</header>

<section class="guide-section" aria-labelledby="declare-title">
  <span class="section-label">Declaration</span>
  <h2 id="declare-title">Use a narrow verb and object in the filename</h2>
  <CodeBlock label="One file-backed Action" title="actions/inspect_zone.py" variant="code" {...data.action} />
  <ul>
    <li><code>inspect_zone.py</code> becomes the Action id <code>inspect-zone</code>.</li>
    <li>The only decorated function is named <code>run</code> and is asynchronous.</li>
    <li><code>integrations=[...]</code> lists only Integration ids declared in <code>shimpz.toml</code>.</li>
    <li>Typed parameters become required Brain input; <code>ctx</code> is invocation context.</li>
    <li>The typed return value defines the output the Brain may receive.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="contract-title">
  <span class="section-label">Derived contract</span>
  <h2 id="contract-title">Do not hand-write transport or schemas</h2>
  <CodeBlock
    label="Illustrative generated Action entry"
    title="shimpz.contract.json"
    variant="code"
    {...data.contract}
  />
  <p>
    The entry contains only the canonical Action id, declared Integrations and human-request capabilities, and the
    two closed schemas. The Controller addresses the Action by id and validates every input and result against those
    reviewed schemas; Assistants do not declare HTTP transport.
  </p>
  <p>One Assistant contract contains between 1 and 128 Actions in canonical id order.</p>
</section>

<aside class="scope-note" aria-labelledby="boundary-title">
  <span id="boundary-title" class="kicker">Keep Actions specific</span>
  <p>
    Do not expose arbitrary URLs, methods, headers, shell commands, or raw provider responses.
    An Action should describe one useful result and return only the fields the Brain needs.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/icons/"><span>Back</span><strong>Assistant icon</strong></a>
  <a href="/developers/assistants/spec/integrations/"><span>Next</span><strong>Integrations</strong></a>
</nav>
