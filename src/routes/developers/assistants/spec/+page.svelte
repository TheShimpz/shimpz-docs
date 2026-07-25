<svelte:head>
  <title>Assistant Spec v1 — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/" />
  <meta
    name="description"
    content="Understand the minimal file-backed contract for Shimpz Assistants."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Developers</a><span aria-hidden="true">/</span><strong>Assistant Spec v1</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">One reviewed contract</span>
  <h1>Author source; let Shimpz generate delivery</h1>
  <p class="docs-lede">
    Assistant Spec v1 has one small manifest and one Python file per Power. Contracts, locks,
    Dockerfiles, health endpoints, and runtime adapters are generated during platform pre-build.
  </p>
</header>

<section class="guide-section" aria-labelledby="source-title">
  <span class="section-label">Authored source</span>
  <h2 id="source-title">Every decision has one home</h2>
  <dl>
    <dt><code>shimpz.toml</code></dt>
    <dd>Version, identity, Genesis, exact outbound hosts, and optional OAuth Account scopes.</dd>
    <dt><code>powers/*.py</code></dt>
    <dd>Exactly one decorated <code>async def run</code> per direct file.</dd>
    <dt><code>pyproject.toml</code></dt>
    <dd>Python version and direct dependencies, including the released <code>shimpz</code> SDK.</dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="build-title">
  <span class="section-label">Platform pre-build</span>
  <h2 id="build-title">Generated artifacts never pollute source</h2>
  <ol>
    <li>Shimpz Genesis validates the project and imports each Power in isolation.</li>
    <li>It derives the canonical <code>shimpz.contract.json</code>.</li>
    <li>The platform resolves and locks dependencies and creates the runtime/container files.</li>
    <li>The Controller admits only the reviewed immutable build.</li>
  </ol>
</section>

<section class="guide-section" aria-labelledby="runtime-title">
  <span class="section-label">Runtime</span>
  <h2 id="runtime-title">Invocation contains only input and Accounts</h2>
  <p>
    The Controller validates Power input, resolves only declared OAuth bearer tokens, and invokes
    <code>/usr/local/bin/shimpz-power &lt;power-id&gt;</code> over bounded stdin. A Power returns one
    validated JSON object over stdout.
  </p>
</section>

<aside class="scope-note" aria-labelledby="closed-title">
  <span id="closed-title" class="kicker">Version 1 is the only version</span>
  <p>
    There are no compatibility parsers, v1 Secrets, answer logs, suspension frames, dynamic approvals,
    author-written HTTP servers, runtime commands, or health endpoints.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/"><span>Back</span><strong>Developer start</strong></a>
  <a href="/developers/assistants/spec/manifest/"><span>Next</span><strong>shimpz.toml</strong></a>
</nav>
