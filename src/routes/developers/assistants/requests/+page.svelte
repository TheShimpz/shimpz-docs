<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Action human requests — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/requests/" />
  <meta
    name="description"
    content="Pause a Shimpz Action for attributable approval, closed input, or platform authentication."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Developers</a><span aria-hidden="true">/</span><strong>Action requests</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Human-in-the-loop SDK</span>
  <h1>Pause an Action for one accountable human decision</h1>
  <p class="docs-lede">
    An Action can request approval, one closed input field, or fresh platform authentication. Shimpz pauses the
    operation, identifies the exact Assistant and Action to the human, and resumes only after a valid response.
  </p>
</header>

<section class="guide-section" aria-labelledby="choose-title">
  <span class="section-label">Choose the narrowest request</span>
  <h2 id="choose-title">Three SDK calls, three different contracts</h2>
  <dl>
    <dt><a href="/developers/assistants/requests/approval/"><code>ctx.request_approval(...)</code></a></dt>
    <dd>Ask the authenticated human to approve one fully described action. Success returns <code>None</code>.</dd>
    <dt><a href="/developers/assistants/requests/input/"><code>ctx.request_input(...)</code></a></dt>
    <dd>Collect exactly one text, selection, phone, or third-party secret value.</dd>
    <dt><a href="/developers/assistants/requests/auth/"><code>ctx.request_auth(...)</code></a></dt>
    <dd>Ask Shimpz to prove a platform assurance class without exposing the factor to the Action.</dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="declare-title">
  <span class="section-label">Declare before use</span>
  <h2 id="declare-title">The decorator is the reviewed capability boundary</h2>
  <CodeBlock label="Declared human request capabilities" title="actions/create_record.py" variant="code" {...data.action} />
  <p>
    Every exact kind must appear in <code>@action(human_requests=[...])</code>. An undeclared kind is rejected before
    a modal appears. Titles, descriptions, labels, and options are bounded inert text; they never grant authority.
  </p>
</section>

<aside class="scope-note" aria-labelledby="before-action-title">
  <span id="before-action-title" class="kicker">Request before action</span>
  <p>
    A request ends the current operating-system process. Shimpz later re-runs the same immutable Action with a
    verified response transcript. Everything before a request may execute again, so keep that prefix deterministic
    and free of external side effects. Issue all requests before reading an Integration token or changing anything.
  </p>
</aside>

<section class="guide-section" aria-labelledby="outcome-title">
  <span class="section-label">Blocking behavior</span>
  <h2 id="outcome-title">Success resumes; every other outcome stops</h2>
  <ul>
    <li>Approval, valid input, or successful assurance resumes the logical Action.</li>
    <li>Denial, modal dismissal, cancellation, expiry, invalid authentication, or unavailable assurance stops it.</li>
    <li>A blocked request never returns control to Assistant code and is never retried automatically.</li>
    <li>One Action may request at most 8 decisions; one Team turn may request at most 16.</li>
    <li>Each displayed challenge expires after 300 seconds.</li>
  </ul>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue Action requests">
  <a href="/developers/assistants/spec/actions/"><span>Back</span><strong>Actions</strong></a>
  <a href="/developers/assistants/requests/approval/"><span>Next</span><strong>Approval</strong></a>
</nav>
