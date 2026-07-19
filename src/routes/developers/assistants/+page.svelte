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
    An Assistant is an immutable workload owned by one isolated Team. It combines Rules, named Powers,
    explicit Service access, and optional routines without inheriting Space-level authority.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-status-title">
  <span id="assistant-status-title" class="kicker">What is available now</span>
  <p>
    Assistant Spec v2 defines Rules, Powers, permissions, routines, immutable releases, and user Help. Shimpz
    Assistant is the executable runtime reference. For each turn, the provider-neutral LangGraph Brain
    receives every installed, available Assistant's validated Rules and Powers, while the controller retains
    all execution authority.
  </p>
</aside>

<section class="guide-section" aria-labelledby="assistant-model-title">
  <span class="section-label">Boundary</span>
  <h2 id="assistant-model-title">Team-owned by construction</h2>
  <ul>
    <li>An Assistant belongs to one Team and shares only that Team's admitted resource budget.</li>
    <li>Rules orient behavior but cannot add authority.</li>
    <li>Its manifest declares named Powers with closed input and output schemas.</li>
    <li>Service operations and Assistant Powers are allowlisted by interface and name, never generic reach.</li>
    <li>Credential declarations are opaque references; secret values stay in the responsible Service.</li>
    <li>Egress is exact and routines start disabled, single-flight, and idempotent.</li>
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
        <span>Rules, Powers, immutable artifacts, permissions, and routines</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/runtime/">
        <strong>Brain runtime</strong>
        <span>LangGraph inference, controller-owned Powers, API keys, and opaque files</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/shimpz-assistant/">
        <strong>Shimpz Assistant</strong>
        <span>Compose three typed weather Powers through one bounded public API</span>
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
    Salesnator uses only synthetic data. Meta and notification tokens remain in Services, and campaign
    mutations remain outside this MVP.
  </p>
  <p>
    Creators may eventually distribute and sell Assistants. That marketplace is a later product layer,
    not permission to weaken the Team boundary or claim an unavailable checkout today.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/services/"><span>Back</span><strong>Services</strong></a>
  <a href="/developers/assistants/spec/"><span>Next</span><strong>Assistant Spec v2</strong></a>
</nav>
