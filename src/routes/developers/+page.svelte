<svelte:head>
  <title>Build a Shimpz Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/" />
  <meta
    name="description"
    content="Build and test a file-backed Python Assistant with the Shimpz SDK and CLI."
  />
</svelte:head>

<header class="docs-page-header">
  <span class="section-label">Developer quick start</span>
  <h1>Write Actions, not infrastructure</h1>
  <p class="docs-lede">
    Put identity and Genesis in <code>shimpz.toml</code>. Put each Action in its own Python file.
    The Shimpz CLI validates and tests the project locally without Docker.
  </p>
</header>

<section class="guide-section" aria-labelledby="path-title">
  <span class="section-label">Learning path</span>
  <h2 id="path-title">Start with the contract, then write one Action</h2>
  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/">
        <strong>1. Understand Assistant Spec v1</strong>
        <span>See what belongs in source and what Shimpz generates during pre-build.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/">
        <strong>2. Create the minimal project</strong>
        <span>Use the required actions directory and one async run function per file.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/quickstart/">
        <strong>3. Test it with the native CLI</strong>
        <span>Run shimpz check and shimpz test without building a container.</span>
      </a>
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="boundary-title">
  <span class="section-label">Trust boundary</span>
  <h2 id="boundary-title">The SDK describes; the Controller decides</h2>
  <ol>
    <li>Shimpz Genesis derives a machine contract from the files in <code>actions/</code>.</li>
    <li>The platform generates locks and runtime/container artifacts during pre-build.</li>
    <li>The Controller validates the manifest and generated contract without importing source.</li>
    <li>Every input and output is validated again when an Action runs.</li>
  </ol>
</section>

<aside class="scope-note" aria-labelledby="sdk-title">
  <span id="sdk-title" class="kicker">SDK architecture</span>
  <p>
    Shared deterministic behavior lives in the Rust <code>shimpz-genesis</code> foundation. The public
    Python package and import are both <code>shimpz</code>.
  </p>
</aside>

<nav class="docs-page-nav" aria-label="Continue the developer guide">
  <a href="/developers/assistants/spec/"><span>Next</span><strong>Assistant Spec v1</strong></a>
</nav>
