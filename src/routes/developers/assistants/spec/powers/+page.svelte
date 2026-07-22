<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant Powers and schemas — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/powers/" />
  <meta name="description" content="Define bounded Assistant Powers with closed JSON input and output schemas." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant SPEC</a><span aria-hidden="true">/</span>
  <strong>Powers and schemas</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Baby step 4</span>
  <h1>Turn one useful result into one Power</h1>
  <p class="docs-lede">
    A Power is a named operation the Brain may request. It is not a general tool: its name, purpose, input,
    output, approval, Accounts, and Secrets are all known before execution.
  </p>
</header>

<section class="guide-section" aria-labelledby="declare-title">
  <span class="section-label">Declare the operation</span>
  <h2 id="declare-title">Use a verb and a narrow object</h2>
  <CodeBlock
    label="One Power"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.power}
  />
  <p>
    Power IDs use lowercase kebab-case, begin with a letter, and are 1–80 characters. A manifest supports from
    1 to 128 unique Powers. Each summary is 1–160 characters.
  </p>
</section>

<section class="guide-section" aria-labelledby="input-title">
  <span class="section-label">Close the input</span>
  <h2 id="input-title">Accept only the value the operation needs</h2>
  <CodeBlock
    label="Power input schema"
    title="schemas/inspect-record.input.schema.json"
    variant="code"
    {...data.input}
  />
  <p>
    Avoid input fields such as <code>url</code>, <code>host</code>, <code>method</code>, <code>path</code>,
    <code>headers</code>, or an arbitrary JSON payload. Those turn one bounded Power into a generic client.
  </p>
</section>

<section class="guide-section" aria-labelledby="output-title">
  <span class="section-label">Close the output</span>
  <h2 id="output-title">Return only what the Brain may see</h2>
  <CodeBlock
    label="Power output schema"
    title="schemas/inspect-record.output.schema.json"
    variant="code"
    {...data.output}
  />
  <p>
    Do not return credentials, raw provider responses, debug traces, request headers, or fields the person did
    not ask for. Shimpz validates the result before the Brain receives it.
  </p>
</section>

<aside class="scope-note" aria-labelledby="pair-title">
  <span id="pair-title" class="kicker">One Power, two schemas</span>
  <p>
    The conventional filenames are <code>schemas/&lt;power-id&gt;.input.schema.json</code> and
    <code>schemas/&lt;power-id&gt;.output.schema.json</code>. Keep both root objects closed with
    <code>additionalProperties: false</code> and bound every string, array, and page size.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant SPEC">
  <a href="/developers/assistants/spec/genesis/"><span>Back</span><strong>Genesis</strong></a>
  <a href="/developers/assistants/spec/approvals/"><span>Next</span><strong>Approvals</strong></a>
</nav>
