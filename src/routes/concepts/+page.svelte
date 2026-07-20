<svelte:head>
  <title>Shimpz core concepts — Shimpz docs</title>
  <meta name="description" content="Understand the current Space, Service, Team, and Assistant boundaries." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><span>Reference</span
  ><span aria-hidden="true">/</span><strong>Core concepts</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Reference</span>
  <h1>Know the boundaries</h1>
</header>

<ul>
  <li><strong>Space</strong> is the server-wide Shimpz installation owned by this machine.</li>
  <li>
    <strong>Service</strong> is a shared capability operated by the Space. It authorizes each Team and
    keeps its own provider or administrator credentials outside Assistants.
  </li>
  <li>
    <strong>Team</strong> is an isolated environment that owns its Assistants, files, conversation state,
    and resource budget. Chat addresses the Team by its chosen name.
  </li>
  <li>
    <strong>Assistant</strong> belongs to exactly one Team. It contributes a Genesis playbook and named Powers
    to that Team, but is not a speaker the user selects. Genesis guides behavior and Power composition but
    grants nothing. Its own declared secret values are scoped to that Team and Assistant and delivered only
    to a referencing Power. It cannot access another Team's Assistants, secrets, files, or resources.
  </li>
</ul>

<aside class="scope-note" aria-labelledby="canonical-names-title">
  <span id="canonical-names-title" class="kicker">Canonical platform names</span>
  <p>
    A Team is the platform's isolation boundary. Code, routes, and payloads use the same concept through
    names such as <code>team_id</code> and <code>Team Controller</code>. Internal implementation surfaces may
    still say <code>Driver</code> for Service and <code>App</code> for Assistant; those names do not create a
    second product concept.
  </p>
</aside>

<nav class="docs-page-nav" aria-label="Return to the beginning">
  <a href="/"><span>Back to</span><strong>Overview</strong></a>
</nav>
