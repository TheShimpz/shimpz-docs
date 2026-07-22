<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant Help — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/help/" />
  <meta name="description" content="Write localized Assistant Help that non-technical people can use." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant SPEC</a><span aria-hidden="true">/</span><strong>Help</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Baby step 9</span>
  <h1>Show people what they can ask</h1>
  <p class="docs-lede">
    Help is user documentation, not an API reference. It should let someone get one useful result without
    understanding providers, JSON, schemas, OAuth, or the Assistant's code.
  </p>
</header>

<section class="guide-section" aria-labelledby="file-title">
  <span class="section-label">First Help file</span>
  <h2 id="file-title">Start with English and one working prompt</h2>
  <CodeBlock
    label="Minimal user Help"
    title="help/HELP-en.md"
    variant="code"
    {...data.help}
  />
</section>

<section class="guide-section" aria-labelledby="content-title">
  <span class="section-label">What good Help contains</span>
  <h2 id="content-title">Answer five beginner questions</h2>
  <ol>
    <li>What result can this Assistant produce?</li>
    <li>What information must the person provide?</li>
    <li>What exact sentence can they try?</li>
    <li>Will Shimpz ask for an Account, Secret, or approval?</li>
    <li>What important thing can the Assistant not do?</li>
  </ol>
</section>

<section class="guide-section" aria-labelledby="locales-title">
  <span class="section-label">Localization</span>
  <h2 id="locales-title">Add a complete file for each language</h2>
  <p>
    Use <code>help/HELP-&lt;locale&gt;.md</code>. Supported locale IDs are <code>en</code>, <code>pt</code>,
    <code>es</code>, <code>zh</code>, <code>fr</code>, <code>de</code>, <code>ja</code>, and <code>ar</code>.
    Translate the examples and limitations, not only the heading.
  </p>
</section>

<aside class="scope-note" aria-labelledby="limits-title">
  <span id="limits-title" class="kicker">Bounded Markdown</span>
  <p>
    Each Help response is one non-empty UTF-8 Markdown document and may not exceed 32 KiB. It must contain no
    control characters, secrets, tokens, raw provider responses, hidden commands, or capabilities absent from
    the manifest.
  </p>
</aside>

<section class="guide-section" aria-labelledby="finish-title">
  <span class="section-label">Final self-review</span>
  <h2 id="finish-title">Ask a non-developer to read only Help</h2>
  <p>
    If they can choose a prompt, understand the required input, and predict whether the operation changes
    anything, the Help is doing its job. If they must read code or provider documentation, simplify it.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Finish the Assistant SPEC">
  <a href="/developers/assistants/spec/network/"><span>Back</span><strong>Network access</strong></a>
  <a href="/developers/assistants/spec/"><span>Finish</span><strong>SPEC overview</strong></a>
</nav>
