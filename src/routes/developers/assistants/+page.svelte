<svelte:head>
  <title>Build Shimpz Assistants — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/" />
  <meta
    name="description"
    content="Understand the Team-owned Shimpz Assistant boundary before building your first Assistant."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <span>Developer guide</span><span aria-hidden="true">/</span><strong>Assistants</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Developer preview</span>
  <h1>Give one Team a focused capability.</h1>
  <p class="docs-lede">
    An Assistant is an immutable workload owned by one isolated Team. It combines a Genesis operating
    playbook, user Help, and named Powers without inheriting Space-level authority.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-status-title">
  <span id="assistant-status-title" class="kicker">What is available now</span>
  <p>
    Assistant Spec v2 defines the intent-only manifest, Genesis, Powers, closed schemas, and user Help.
    Shimpz Assistant is the executable runtime reference. For each turn, the provider-neutral LangGraph Brain
    receives only the enabled Assistants' validated context and Powers, while the controller retains all
    execution authority.
  </p>
</aside>

<section class="guide-section" aria-labelledby="assistant-model-title">
  <span class="section-label">Boundary</span>
  <h2 id="assistant-model-title">Team-owned by construction</h2>
  <ul>
    <li>An Assistant belongs to one Team and shares only that Team's admitted resource budget.</li>
    <li>Genesis defines behavior and Power composition but cannot add authority.</li>
    <li>
      Its manifest declares identity, named Powers, manual Secret metadata, OAuth Account intent, and a
      transparent exact-host allowlist; conventional files carry closed schemas.
    </li>
    <li>Service operations and Assistant Powers are allowlisted by controller policy, never generic reach.</li>
    <li>
      Secret values are write-only and OAuth tokens are controller-owned. Both are isolated to one Team and
      Assistant installation, then delivered only to a referencing Power through its private invocation envelope.
    </li>
    <li>
      Egress is exact and proxy-brokered. The controller must match the packaged host list to the reviewed
      catalog policy before granting it.
    </li>
  </ul>
  <p>
    OpenAI and Anthropic inference use API keys configured in the authenticated Admin. A key is never exposed
    to an Assistant or returned to the browser; it is delivered to the Brain only in memory for the provider
    request. The Brain has no ambient shell, filesystem, network, or provider-native tools.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-collaboration-title">
  <span class="section-label">Collaboration</span>
  <h2 id="assistant-collaboration-title">Compose Powers without crossing boundaries</h2>
  <p>
    The user talks to the Team, not to a selected Assistant. Its Brain can request declared Powers from
    multiple installed Assistants and continue the graph until it can answer naturally under the Team's
    name. Each request still goes through the controller and never grants direct access to another
    Assistant's workspace, database, container, secrets, or generic network endpoint.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-reference-title">
  <span class="section-label">First references</span>
  <h2 id="assistant-reference-title">Prove the smallest useful loop</h2>
  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/">
        <strong>Assistant Spec v2</strong>
        <span>Intent-only manifest, Genesis, Help, Powers, and runtime boundaries</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/runtime/">
        <strong>Brain runtime</strong>
        <span>LangGraph inference, controller-owned Powers, API keys, and opaque files</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/secrets/">
        <strong>Assistant secrets</strong>
        <span>Team-scoped custody, just-in-time collection, and per-Power delivery</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/accounts/">
        <strong>Assistant Accounts</strong>
        <span>Controller-owned OAuth consent, refresh, revocation, and per-Power delivery</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/shimpz-assistant/">
        <strong>Shimpz Assistant</strong>
        <span>Study X Accounts and Mux Secrets in one executable reference</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/salesnator/">
        <strong>Salesnator</strong>
        <span>Prove read-only campaign health and idempotent notification intent</span>
      </a>
    </li>
  </ul>
  <p>
    Salesnator uses only synthetic data and stores no tokens. A future live integration must declare
    every provider Account or Secret on the exact Powers that need it; campaign mutations remain outside
    this MVP.
  </p>
  <p>
    Creators may eventually distribute and sell Assistants. That marketplace is a later product layer,
    not permission to weaken the Team boundary or imply that commerce is part of this delivery.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/services/"><span>Back</span><strong>Services</strong></a>
  <a href="/developers/assistants/spec/"><span>Next</span><strong>Assistant Spec v2</strong></a>
</nav>
