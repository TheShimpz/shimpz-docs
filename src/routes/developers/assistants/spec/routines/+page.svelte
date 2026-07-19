<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant routines — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/routines/" />
  <meta
    name="description"
    content="Declare owner-disabled, single-flight schedules for existing Assistant Powers."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Routines</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Concept · scheduled request</span>
  <h1>Schedule a Power, not arbitrary code.</h1>
  <p class="docs-lede">
    A routine asks the runtime to invoke one Power on an interval with bounded timing and deterministic
    retry identity.
  </p>
</header>

<aside class="scope-note" aria-labelledby="routines-disabled-title">
  <span id="routines-disabled-title" class="kicker">Always owner-disabled</span>
  <p>
    A manifest cannot activate its own routine. Every routine declares <code>enabled_by_default = false</code>
    and still depends on runtime support, an owner decision, current grants, and controller policy.
  </p>
</aside>

<section class="guide-section" aria-labelledby="routines-example-title">
  <span class="section-label">Example</span>
  <h2 id="routines-example-title">Reuse a declared Power</h2>
  <CodeBlock
    label="Owner-disabled Shimpz Assistant routine"
    title="shimpz.assistant.toml · routine"
    variant="code"
    {...data.routine}
  />
</section>

<section class="guide-section" aria-labelledby="routines-fields-title">
  <span class="section-label">Boundaries</span>
  <h2 id="routines-fields-title">Make retries predictable</h2>
  <ul>
    <li><code>power</code> must name a Power declared by the same Assistant.</li>
    <li><code>interval_seconds</code> starts at 60 seconds.</li>
    <li><code>timeout_seconds</code> and <code>jitter_seconds</code> must fit inside the interval.</li>
    <li><code>single_flight = true</code> prevents overlapping runs of the same routine.</li>
    <li>The idempotency key must include <code>{"{scheduled_at}"}</code> so retries keep one identity.</li>
  </ul>
  <p>
    At execution time, the controller must reevaluate the Power declaration, grant, approval, and input. A
    schedule must not preserve authority that has been revoked.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/permissions/"><span>Back</span><strong>Permissions</strong></a>
  <a href="/developers/assistants/spec/runtime/"><span>Next</span><strong>Brain runtime</strong></a>
</nav>
