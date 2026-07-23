<svelte:head>
  <title>Build a Shimpz Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/" />
  <meta
    name="description"
    content="Build a Python Assistant from shimpz.toml and app.py with the Shimpz SDK."
  />
</svelte:head>

<header class="docs-page-header">
  <span class="section-label">Developer quick start</span>
  <h1>Build an Assistant from two authored files</h1>
  <p class="docs-lede">
    Put security intent in <code>shimpz.toml</code> and Python behavior in <code>app.py</code>.
    The Shimpz SDK turns them into the one machine contract that the Controller reviews and executes.
  </p>
</header>

<section class="guide-section" aria-labelledby="path-title">
  <span class="section-label">Learning path</span>
  <h2 id="path-title">Start with the model, then write the files</h2>
  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/">
        <strong>1. Understand Assistant Spec v3</strong>
        <span>See how authored intent becomes a reviewed runtime contract.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/manifest/">
        <strong>2. Declare security intent</strong>
        <span>Name the Assistant, allow exact hosts, and request OAuth scopes.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/">
        <strong>3. Write the Python application</strong>
        <span>Define typed inputs and async Powers with the SDK.</span>
      </a>
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="boundary-title">
  <span class="section-label">Trust boundary</span>
  <h2 id="boundary-title">The SDK describes; the Controller decides</h2>
  <ol>
    <li>The SDK derives a machine contract from <code>app.py</code>.</li>
    <li>The image carries that contract beside <code>shimpz.toml</code>.</li>
    <li>The Controller validates both artifacts and rejects inconsistencies.</li>
    <li>Every input and output is validated again when a Power runs.</li>
  </ol>
</section>

<aside class="scope-note" aria-labelledby="python-title">
  <span id="python-title" class="kicker">Reference SDK</span>
  <p>
    Python is the complete reference implementation. The wire contract is language-neutral so other
    SDKs can implement the same behavior without changing the Controller.
  </p>
</aside>

<nav class="docs-page-nav" aria-label="Continue the developer guide">
  <a href="/developers/assistants/spec/"><span>Next</span><strong>Assistant Spec v3</strong></a>
</nav>
