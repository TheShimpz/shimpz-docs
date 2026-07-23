<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>ctx.human.request — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/human/" />
  <meta name="description" content="Pause a Power for typed human input and resume it deterministically." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v3</a><span aria-hidden="true">/</span>
  <strong>ctx.human.request</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Human input</span>
  <h1>Pause execution to ask one clear question</h1>
  <p class="docs-lede">
    <code>ctx.human.request(...)</code> suspends the Power when a value is missing. The Controller
    presents a typed challenge, stores the answer privately, and starts a fresh isolated execution.
  </p>
</header>

<section class="guide-section" aria-labelledby="types-title">
  <span class="section-label">Request types</span>
  <h2 id="types-title">The same six types, now answered by a person</h2>
  <p>
    Request <code>str</code>, <code>int</code>, <code>float</code>, <code>bool</code>,
    <code>choice(...)</code>, or <code>choices(...)</code>. Supply a short <code>title</code>, a
    specific <code>summary</code>, and an optional public <code>docs</code> URL.
  </p>
  <CodeBlock label="Typed human requests" title="app.py" variant="code" {...data.request} />
</section>

<section class="guide-section" aria-labelledby="replay-title">
  <span class="section-label">Deterministic replay</span>
  <h2 id="replay-title">A resumed Power runs again from the top</h2>
  <ol>
    <li>The first unanswered request suspends execution with its zero-based ordinal.</li>
    <li>The Controller validates and appends the person's answer to an encrypted answer log.</li>
    <li>A new process reruns the Power from the beginning.</li>
    <li>Resolved request sites receive recorded answers in order; the next unanswered site suspends.</li>
  </ol>
</section>

<aside class="scope-note" aria-labelledby="side-effects-title">
  <span id="side-effects-title" class="kicker">Place side effects after interaction</span>
  <p>
    Code before a resolved human interaction runs again on every replay. Put external side effects
    after all <code>ctx.human.request</code> and <code>ctx.human.approval</code> calls, or make those
    effects idempotent. Keep the interaction order stable for the lifetime of a continuation.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/fields/"><span>Back</span><strong>field()</strong></a>
  <a href="/developers/assistants/spec/approvals/"><span>Next</span><strong>ctx.human.approval</strong></a>
</nav>
