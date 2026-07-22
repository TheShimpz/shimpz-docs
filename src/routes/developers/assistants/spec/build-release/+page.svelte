<svelte:head>
  <title>Build and release an Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/build-release/" />
  <meta
    name="description"
    content="Validate one Assistant source tree and publish a tested immutable release without adding build details to its manifest."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Build and release</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Platform-owned packaging</span>
  <h1>Describe intent once.</h1>
  <p class="docs-lede">
    Your manifest stays the same from development to release. Shimpz derives the runtime contract from
    conventions, then binds the reviewed image to an immutable digest outside your source manifest.
  </p>
</header>

<aside class="scope-note" aria-labelledby="build-abstraction-title">
  <span id="build-abstraction-title" class="kicker">No infrastructure form</span>
  <p>
    Creators do not choose a runtime port, health path, source mode, architecture list, or image digest in
    <code>shimpz.assistant.toml</code>. Those are platform and publisher responsibilities.
  </p>
</aside>

<section class="guide-section" aria-labelledby="build-conventions-title">
  <span class="section-label">Source contract</span>
  <h2 id="build-conventions-title">Keep the expected files together</h2>
  <ul>
    <li>
      <code>shimpz.assistant.toml</code> declares identity, exact allowed hosts, Powers, public Secret metadata,
      and OAuth Account intent.
    </li>
    <li><code>GENESIS.md</code> defines behavior, style, safety, and how declared Powers compose.</li>
    <li><code>help/HELP-&lt;locale&gt;.md</code> teaches the installed user in every Admin language.</li>
    <li><code>CHANGELOG.md</code> explains every published update in concise user-visible language.</li>
    <li>Each Power has conventional closed input and output schemas under <code>schemas/</code>.</li>
    <li>The executable source exposes only the fixed health, Help, and declared Power adapters.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="build-checklist-title">
  <span class="section-label">Release checklist</span>
  <h2 id="build-checklist-title">Publish only tested bytes</h2>
  <ol>
    <li>Update the required root <code>CHANGELOG.md</code> for this release.</li>
    <li>Validate the complete source tree against the reviewed Assistant contract.</li>
    <li>Run focused source and contract tests.</li>
    <li>
      Build and smoke the supported platform images as an unprivileged, read-only runtime, including
      <code>GENESIS.md</code> and <code>shimpz.assistant.toml</code> under <code>/opt/shimpz-assistant/</code>
      with mode <code>0444</code>.
    </li>
    <li>Push one multi-platform image with provenance and an SBOM.</li>
    <li>Bind the returned registry digest in the trusted catalog; never install from a mutable tag.</li>
  </ol>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/changelog/"><span>Back</span><strong>Changelog</strong></a>
  <a href="/developers/assistants/shimpz-cloudflare/"><span>Next</span><strong>Shimpz Cloudflare</strong></a>
</nav>
