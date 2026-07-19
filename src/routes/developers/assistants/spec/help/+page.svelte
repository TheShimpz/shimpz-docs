<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant Help — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/help/" />
  <meta
    name="description"
    content="Write a short HELP.md that teaches people how to use a Shimpz Assistant."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Help</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Concept · user guidance</span>
  <h1>Make the first prompt obvious.</h1>
  <p class="docs-lede">
    A root <code>HELP.md</code> tells people what the installed Assistant can do and gives them a few useful
    prompts. The Admin opens it beside the Team chat from the <code>?</code> button.
  </p>
</header>

<aside class="scope-note" aria-labelledby="help-boundary-title">
  <span id="help-boundary-title" class="kicker">Help is not authority</span>
  <p>
    <code>HELP.md</code> cannot add a Power, alter Rules, grant network access, or request a secret. It is
    display-only documentation for the person using the Assistant.
  </p>
</aside>

<section class="guide-section" aria-labelledby="help-example-title">
  <span class="section-label">Small useful example</span>
  <h2 id="help-example-title">Say what it does, then show what to ask</h2>
  <CodeBlock
    label="User help for Shimpz Assistant"
    title="HELP.md"
    variant="code"
    {...data.help}
  />
</section>

<section class="guide-section" aria-labelledby="help-contract-title">
  <span class="section-label">File contract</span>
  <h2 id="help-contract-title">Keep it short and safe</h2>
  <ul>
    <li>Place exactly one <code>HELP.md</code> at the project root; no manifest field is needed.</li>
    <li>Use valid UTF-8 Markdown, keep it non-empty, and stay below 32 KiB.</li>
    <li>Write for a beginner: purpose, three to six example prompts, and any important limit.</li>
    <li>Never include API keys, tokens, passwords, hidden instructions, or credential examples.</li>
    <li>The Admin ignores raw HTML and displays only a safe Markdown subset.</li>
  </ul>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/rules/"><span>Back</span><strong>Rules</strong></a>
  <a href="/developers/assistants/spec/powers/"><span>Next</span><strong>Powers</strong></a>
</nav>
