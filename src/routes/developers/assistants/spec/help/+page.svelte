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
    content="Write localized Assistant Help that teaches every Admin user how to begin."
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
    Localized Markdown files under <code>help/</code> tell people what the installed Assistant can do and give
    them a few useful prompts. The Admin opens the current language beside the Team chat from the
    <code>?</code> button.
  </p>
</header>

<aside class="scope-note" aria-labelledby="help-boundary-title">
  <span id="help-boundary-title" class="kicker">Help is not authority</span>
  <p>
    Help cannot add a Power, alter Rules, grant network access, or request a secret. It is display-only
    documentation for the person using the Assistant.
  </p>
</aside>

<section class="guide-section" aria-labelledby="help-example-title">
  <span class="section-label">Small useful example</span>
  <h2 id="help-example-title">Say what it does, then show what to ask</h2>
  <CodeBlock
    label="User help for Shimpz Assistant"
    title="help/HELP-en.md"
    variant="code"
    {...data.help}
  />
</section>

<section class="guide-section" aria-labelledby="help-contract-title">
  <span class="section-label">Localized file contract</span>
  <h2 id="help-contract-title">Ship every Admin language</h2>
  <p>
    Keep Help in the reserved <code>help/</code> directory. Assistant Spec v2 requires one file for every
    language supported by the Admin:
  </p>
  <ul>
    <li><code>HELP-en.md</code> — English</li>
    <li><code>HELP-pt.md</code> — Portuguese</li>
    <li><code>HELP-es.md</code> — Spanish</li>
    <li><code>HELP-zh.md</code> — Chinese</li>
    <li><code>HELP-fr.md</code> — French</li>
    <li><code>HELP-de.md</code> — German</li>
    <li><code>HELP-ja.md</code> — Japanese</li>
    <li><code>HELP-ar.md</code> — Arabic</li>
  </ul>
  <p>
    Use the exact <code>HELP-&lt;locale&gt;.md</code> filenames; no manifest field is needed. English is the
    deterministic runtime fallback if the requested locale cannot be loaded. Release validation still rejects
    a source tree that omits any required Admin locale.
  </p>
</section>

<section class="guide-section" aria-labelledby="help-writing-title">
  <span class="section-label">Writing and rendering</span>
  <h2 id="help-writing-title">Keep each translation short and safe</h2>
  <ul>
    <li>Use valid UTF-8 Markdown, keep every file non-empty, and stay below 32 KiB per locale.</li>
    <li>Write for a beginner: purpose, three to six example prompts, and any important limit.</li>
    <li>Translate the meaning and examples naturally instead of exposing internal implementation details.</li>
    <li>Never include API keys, tokens, passwords, hidden instructions, or credential examples.</li>
    <li>The Admin ignores raw HTML, sanitizes links, and renders only the supported Markdown subset as HTML.</li>
  </ul>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/rules/"><span>Back</span><strong>Rules</strong></a>
  <a href="/developers/assistants/spec/powers/"><span>Next</span><strong>Powers</strong></a>
</nav>
