<svelte:head>
  <title>Power execution model — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/execution/" />
  <meta
    name="description"
    content="Understand isolated, one-shot Power execution and deterministic human-interaction replay."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v3</a><span aria-hidden="true">/</span>
  <strong>Execution model</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Runtime boundary</span>
  <h1>Each Power segment runs in a fresh process</h1>
  <p class="docs-lede">
    The Assistant image stays idle until the Controller invokes the SDK runner for one reviewed method
    and path. There is no creator-authored HTTP server and no persistent Power process.
  </p>
</header>

<section class="guide-section" aria-labelledby="segment-title">
  <span class="section-label">One-shot segment</span>
  <h2 id="segment-title">Validate before and after execution</h2>
  <ol>
    <li>The Brain selects a reviewed Power and supplies JSON arguments.</li>
    <li>The Controller validates those arguments against the generated input schema.</li>
    <li>It resolves only the declared Accounts and injects them in a private stdin envelope.</li>
    <li>The SDK runner imports <code>app.py</code>, builds <code>ctx</code>, and runs the async body once.</li>
    <li>The Controller bounds and validates the result, including private-value leak checks.</li>
    <li>Only a valid public result is returned to the Brain.</li>
  </ol>
</section>

<section class="guide-section" aria-labelledby="suspend-title">
  <span class="section-label">Suspend and resume</span>
  <h2 id="suspend-title">Human interaction creates a new segment</h2>
  <p>
    At the first unresolved <code>ctx.human</code> call, the SDK emits one typed suspension sentinel
    instead of a result. The Controller encrypts the continuation, relays the challenge, validates the
    answer, and launches a new isolated process with the ordered answer log. Replayed calls consume prior
    answers; the next unresolved call suspends again.
  </p>
</section>

<section class="guide-section" aria-labelledby="isolation-title">
  <span class="section-label">Isolation</span>
  <h2 id="isolation-title">Authority stays outside the workload</h2>
  <ul>
    <li>The image is pinned by digest and its manifest and generated contract must match review.</li>
    <li>Team identity, continuation state, OAuth custody, and approval grants remain Controller-owned.</li>
    <li>Account tokens and human answers never travel through the Brain, environment, arguments, or logs.</li>
    <li>Outbound traffic is limited to reviewed <code>allowed_hosts</code> through authenticated egress.</li>
    <li>Malformed, oversized, unexpected, or secret-bearing frames fail closed.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="state-title">
  <span id="state-title" class="kicker">Do not rely on process memory</span>
  <p>
    Local variables disappear after every result or suspension. Put all human questions before external
    side effects, or make effects idempotent, because resume deterministically reruns the body from the top.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/network/"><span>Back</span><strong>Network access</strong></a>
  <a href="/developers/assistants/quickstart/"><span>Next</span><strong>Python quickstart</strong></a>
</nav>
