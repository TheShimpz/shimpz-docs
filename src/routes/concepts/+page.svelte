<svelte:head>
  <title>Shimpz core concepts — Shimpz docs</title>
  <meta name="description" content="Understand the current Space, Service, Capsule, and Assistant boundaries." />
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
    <strong>Service</strong> is a shared capability operated by the Space. It authorizes each Capsule and
    keeps provider or administrator credentials outside Assistants.
  </li>
  <li><strong>Capsule</strong> is an isolated tenant environment inside the Space.</li>
  <li>
    <strong>Assistant</strong> belongs to exactly one Capsule. It can request only the Service and
    Assistant operations granted to it inside that Capsule.
  </li>
</ul>

<aside class="scope-note" aria-labelledby="legacy-names-title">
  <span id="legacy-names-title" class="kicker">Compatibility names</span>
  <p>
    Existing code and APIs may still say <code>Driver</code> for Service and <code>App</code> for Assistant.
    Those identifiers remain during the versioned migration; they do not change the architecture above.
  </p>
</aside>

<nav class="docs-page-nav" aria-label="Return to the beginning">
  <a href="/"><span>Back to</span><strong>Overview</strong></a>
</nav>
