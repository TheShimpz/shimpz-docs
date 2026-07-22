<svelte:head>
  <title>Shimpz developer quick start — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/" />
  <meta
    name="description"
    content="Choose the supported Shimpz extension path and start from the production Cloudflare Assistant."
  />
</svelte:head>

<header class="docs-page-header">
  <span class="section-label">Developer quick start</span>
  <h1>Start from code that runs today</h1>
  <p class="docs-lede">
    The supported extension surface is Assistant Spec v2. Shimpz Cloudflare is the first production example:
    one OAuth Account, two read-only Powers, exact network access, and closed input and output schemas.
  </p>
</header>

<aside class="scope-note" aria-labelledby="current-scope-title">
  <span id="current-scope-title" class="kicker">Current stable scope</span>
  <p>
    Cloudflare is the only enabled OAuth provider today. Internal PostgreSQL and controller components are
    platform infrastructure, not public plugins. Stable does not yet include a generic third-party Store or
    another public extension surface.
  </p>
</aside>

<section class="guide-section" aria-labelledby="choose-path-title">
  <span class="section-label">Choose your task</span>
  <h2 id="choose-path-title">Change the smallest correct layer</h2>
  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/developers/assistants/">
        <strong>Add a Power to an Assistant</strong>
        <span>Start with the project shape, schemas, runtime, and tests.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/accounts/providers/">
        <strong>Add another OAuth provider</strong>
        <span>Coordinate the trusted platform adapter and its least-privilege Assistant.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/shimpz-cloudflare/">
        <strong>Read the complete Cloudflare example</strong>
        <span>Follow one request from manifest to a validated API response.</span>
      </a>
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="mental-model-title">
  <span class="section-label">Mental model</span>
  <h2 id="mental-model-title">The Brain proposes; the controller authorizes</h2>
  <ol>
    <li>An Assistant declares what it needs, but receives no authority from its manifest.</li>
    <li>The Brain may request a declared Power while answering a Team message.</li>
    <li>The controller validates the Team, Assistant, Power, schema, Account, scopes, and approval.</li>
    <li>Only then does the isolated Assistant execute the bounded operation.</li>
  </ol>
</section>

<nav class="docs-page-nav" aria-label="Continue the developer guide">
  <a href="/developers/assistants/"><span>Next</span><strong>Assistant project guide</strong></a>
</nav>
