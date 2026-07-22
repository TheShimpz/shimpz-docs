<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant Genesis — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/genesis/" />
  <meta name="description" content="Teach an Assistant's purpose, behavior, safety, and Power composition in GENESIS.md." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant SPEC</a><span aria-hidden="true">/</span><strong>Genesis</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Baby step 3</span>
  <h1>Teach judgment without granting authority</h1>
  <p class="docs-lede">
    <code>GENESIS.md</code> tells the Brain when a Power is useful, how Powers compose, and how to explain results.
    It can guide behavior, but it cannot create a Power or bypass the manifest.
  </p>
</header>

<section class="guide-section" aria-labelledby="write-title">
  <span class="section-label">Start small</span>
  <h2 id="write-title">Write four short sections</h2>
  <CodeBlock
    label="Minimal Genesis"
    title="GENESIS.md"
    variant="code"
    {...data.genesis}
  />
</section>

<section class="guide-section" aria-labelledby="include-title">
  <span class="section-label">What belongs here</span>
  <h2 id="include-title">Describe decisions the Brain must understand</h2>
  <ul>
    <li>The Assistant's purpose and the requests it should handle.</li>
    <li>When to use each declared Power and when to answer without one.</li>
    <li>How results from multiple declared Powers may be combined.</li>
    <li>Important limitations, uncertainty, and language the answer must avoid.</li>
    <li>A concise response style that matches the Power's real output.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="exclude-title">
  <span class="section-label">What does not belong here</span>
  <h2 id="exclude-title">Never hide authority in prose</h2>
  <ul>
    <li>Secrets, access tokens, passwords, API keys, or private user data.</li>
    <li>Undeclared tools, shell commands, arbitrary URLs, or filesystem paths.</li>
    <li>Instructions to ignore approval, schema, Account, Secret, or network checks.</li>
    <li>Claims that prose can add permissions not present in the manifest.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="file-title">
  <span id="file-title" class="kicker">File contract</span>
  <p>
    Genesis is one non-empty UTF-8 Markdown file, at most 128 KiB, packaged as a read-only regular file. Control
    characters and invalid text fail admission. Keep it much smaller so people can review it easily.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant SPEC">
  <a href="/developers/assistants/spec/manifest/"><span>Back</span><strong>Manifest and identity</strong></a>
  <a href="/developers/assistants/spec/powers/"><span>Next</span><strong>Powers and schemas</strong></a>
</nav>
