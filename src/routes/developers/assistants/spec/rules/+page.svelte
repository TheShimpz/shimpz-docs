<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant Rules — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/rules/" />
  <meta
    name="description"
    content="Write clear Assistant Rules that guide behavior without granting capabilities."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Rules</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Concept · behavior</span>
  <h1>Teach behavior with Rules.</h1>
  <p class="docs-lede">
    Rules tell the inference model how this Assistant should reason, when to suggest a Power, and how to
    communicate the result.
  </p>
</header>

<aside class="scope-note" aria-labelledby="rules-boundary-title">
  <span id="rules-boundary-title" class="kicker">Rules are not authority</span>
  <p>
    A sentence in Markdown cannot add a Power, grant a permission, bypass approval, or expose a credential.
    Those boundaries remain controller-enforced.
  </p>
</aside>

<section class="guide-section" aria-labelledby="rules-example-title">
  <span class="section-label">Example</span>
  <h2 id="rules-example-title">Write for the next decision</h2>
  <p>
    Start with the Assistant's purpose, the Power it may use, what to ask when input is missing, and the
    expected communication style.
  </p>
  <CodeBlock
    label="Minimal Rules for Shimpz Assistant"
    title="assistant/RULES.md"
    variant="code"
    {...data.rules}
  />
</section>

<section class="guide-section" aria-labelledby="rules-file-title">
  <span class="section-label">File contract</span>
  <h2 id="rules-file-title">Keep one bounded Markdown file</h2>
  <ul>
    <li>Reference it with a project-relative <code>.md</code> path such as <code>assistant/RULES.md</code>.</li>
    <li>Keep it non-empty, valid UTF-8, inside the project, and below 128 KiB.</li>
    <li>Do not place passwords, API keys, tokens, or other credentials in Rules.</li>
    <li>Name Powers exactly as declared; prose never creates a missing capability.</li>
  </ul>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/manifest/"><span>Back</span><strong>Manifest</strong></a>
  <a href="/developers/assistants/spec/help/"><span>Next</span><strong>Help</strong></a>
</nav>
