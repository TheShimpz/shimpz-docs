<svelte:head>
  <title>Build Shimpz Assistants — Shimpz docs</title>
  <meta
    name="description"
    content="Understand the Capsule-owned Shimpz Assistant boundary before building your first Assistant."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <span>Developer guide</span><span aria-hidden="true">/</span><strong>Assistants</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Developer preview</span>
  <h1>Give one Capsule a focused capability.</h1>
  <p class="docs-lede">
    An Assistant is an immutable workload owned by one isolated Capsule. It combines a skill, named
    operations, explicit Service access, and optional routines without inheriting Space-level authority.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-status-title">
  <span id="assistant-status-title" class="kicker">What is available now</span>
  <p>
    Assistant Spec v1 begins as a source-validation and developer-experience contract. The public install
    path, capability-enforcing Capsule controller, persistent scheduler, provider OAuth broker, Telegram
    delivery, and commerce are not released capabilities yet.
  </p>
</aside>

<section class="guide-section" aria-labelledby="assistant-model-title">
  <span class="section-label">Boundary</span>
  <h2 id="assistant-model-title">Capsule-owned by construction</h2>
  <ul>
    <li>An Assistant belongs to one Capsule and shares only that Capsule's admitted resource budget.</li>
    <li>Its manifest declares named operations with closed input and output schemas.</li>
    <li>Service and Assistant access is allowlisted by interface and operation, never by generic reach.</li>
    <li>Credential declarations are opaque references; secret values stay in the responsible Service.</li>
    <li>Egress is exact and routines start disabled, single-flight, and idempotent.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="assistant-collaboration-title">
  <span class="section-label">Collaboration</span>
  <h2 id="assistant-collaboration-title">Ask for an operation, not another workload</h2>
  <p>
    Collaboration means invoking one declared operation through a scoped capability. It never grants
    access to another Assistant's workspace, database, container, secrets, or generic network endpoint.
    Redpanda may carry durable events later, but a queue does not replace caller identity or authorization.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-reference-title">
  <span class="section-label">First references</span>
  <h2 id="assistant-reference-title">Prove the smallest useful loop</h2>
  <ul>
    <li><strong>Hello Pulse</strong> validates health, one operation, and one opt-in routine.</li>
    <li>
      <strong>Salesnator</strong> starts as a read-only campaign-health skeleton. Meta and Telegram tokens
      stay in Services, and campaign mutations remain outside the MVP.
    </li>
  </ul>
  <p>
    Creators may eventually distribute and sell Assistants. That marketplace is a later product layer,
    not permission to weaken the Capsule boundary or claim an unavailable checkout today.
  </p>
</section>

<nav class="docs-page-nav" aria-label="Continue the developer guide">
  <a href="/developers/services/"><span>Back</span><strong>Services</strong></a>
</nav>
