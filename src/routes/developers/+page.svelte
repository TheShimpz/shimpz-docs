<svelte:head>
  <title>Shimpz developer quick start — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/" />
  <meta
    name="description"
    content="Learn the Shimpz Assistant SPEC one small concept at a time."
  />
</svelte:head>

<header class="docs-page-header">
  <span class="section-label">Developer quick start</span>
  <h1>Learn one contract, one step at a time</h1>
  <p class="docs-lede">
    Shimpz has one public extension contract: the Assistant SPEC. Each page below explains one part, why it
    exists, what to write, and what Shimpz will reject.
  </p>
</header>

<aside class="scope-note" aria-labelledby="current-scope-title">
  <span id="current-scope-title" class="kicker">Current stable scope</span>
  <p>
    This guide covers only fields and files that belong to the Assistant SPEC. Internal controllers, databases,
    provider registration, deployment channels, and Store operations are deliberately outside this guide.
  </p>
</aside>

<section class="guide-section" aria-labelledby="choose-path-title">
  <span class="section-label">Choose your task</span>
  <h2 id="choose-path-title">Follow the SPEC in this order</h2>
  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/">
        <strong>1. Understand the complete contract</strong>
        <span>See what belongs to an Assistant and what never does.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/">
        <strong>2. Create the project files</strong>
        <span>Build the smallest valid folder before writing runtime code.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/manifest/">
        <strong>3. Fill the manifest</strong>
        <span>Start with identity, no network, and one Power.</span>
      </a>
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="mental-model-title">
  <span class="section-label">One sentence to remember</span>
  <h2 id="mental-model-title">The SPEC declares intent; it grants nothing</h2>
  <ol>
    <li>You describe the Assistant and its named Powers.</li>
    <li>You attach only the Accounts, Secrets, and hosts each Power needs.</li>
    <li>Shimpz validates those declarations before anything can execute.</li>
    <li>Unknown fields and undeclared access fail instead of being guessed.</li>
  </ol>
</section>

<nav class="docs-page-nav" aria-label="Continue the developer guide">
  <a href="/developers/assistants/spec/"><span>Next</span><strong>Assistant SPEC overview</strong></a>
</nav>
