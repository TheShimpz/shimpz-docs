<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant Genesis — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/genesis/" />
  <meta
    name="description"
    content="Write a required Assistant Genesis playbook that teaches the Team Brain how to choose and compose declared Powers."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Genesis</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Concept · Power orchestration</span>
  <h1>Teach the Brain how Powers work together.</h1>
  <p class="docs-lede">
    The required root <code>GENESIS.md</code> is the Assistant's stable operating playbook. It explains when
    to choose a declared Power, how to compose several Powers, when to ask for clarification, and when to
    stop without inventing a result.
  </p>
</header>

<aside class="scope-note" aria-labelledby="genesis-boundary-title">
  <span id="genesis-boundary-title" class="kicker">Context, never authority</span>
  <p>
    Genesis cannot add a Power, approve an invocation, grant network access, or weaken controller policy.
    The Brain receives this stable context only while the Assistant is explicitly enabled for the current
    Team chat.
  </p>
</aside>

<section class="guide-section" aria-labelledby="genesis-example-title">
  <span class="section-label">Minimal example</span>
  <h2 id="genesis-example-title">Describe one useful composition</h2>
  <p>
    Name only declared Powers. Give the Brain a clear start condition, the smallest useful sequence, and a
    safe stop condition.
  </p>
  <CodeBlock
    label="Minimal Genesis for a weather Assistant"
    title="GENESIS.md"
    variant="code"
    {...data.genesis}
  />
</section>

<section class="guide-section" aria-labelledby="genesis-files-title">
  <span class="section-label">File contract</span>
  <h2 id="genesis-files-title">Use one conventional root file</h2>
  <ul>
    <li>Name it exactly <code>GENESIS.md</code> at the project root; no manifest field is needed.</li>
    <li>Keep it a non-empty regular UTF-8 Markdown file no larger than 128 KiB (131,072 bytes).</li>
    <li>Never include credentials, private user data, conversation state, or instructions fetched at runtime.</li>
    <li>
      The immutable image carries the reviewed file at <code>/opt/shimpz-assistant/GENESIS.md</code> with
      read-only mode <code>0444</code>.
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="genesis-separation-title">
  <span class="section-label">Responsibility</span>
  <h2 id="genesis-separation-title">Keep each document focused</h2>
  <ul>
    <li><code>assistant/RULES.md</code> defines invariant behavior, answer style, and safety boundaries.</li>
    <li><code>GENESIS.md</code> defines the operational playbook for choosing and composing declared Powers.</li>
    <li><code>help/HELP-&lt;locale&gt;.md</code> teaches a person what to ask in the Admin.</li>
    <li>The manifest and controller define the actual Power and authority boundary.</li>
  </ul>
  <p>
    The Brain pre-caches Genesis as stable context for the immutable Assistant release. Every model turn
    includes it only for Assistants enabled in that turn; disabling an Assistant removes both its Genesis
    and its Powers from the next validated context.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/rules/"><span>Back</span><strong>Rules</strong></a>
  <a href="/developers/assistants/spec/help/"><span>Next</span><strong>Help</strong></a>
</nav>
