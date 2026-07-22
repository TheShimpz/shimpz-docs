<svelte:head>
  <title>Assistant SPEC — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/" />
  <meta name="description" content="Learn every supported part of the Shimpz Assistant SPEC in baby steps." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Developers</a><span aria-hidden="true">/</span><strong>Assistant SPEC</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">One public contract</span>
  <h1>Declare exactly what the Assistant needs</h1>
  <p class="docs-lede">
    The Assistant SPEC is a small set of files and fields. It describes identity, behavior, callable Powers,
    private dependencies, network destinations, approval rules, and user Help. A declaration requests access;
    it never grants access by itself.
  </p>
</header>

<section class="guide-section" aria-labelledby="path-title">
  <span class="section-label">Learning path</span>
  <h2 id="path-title">Follow one concept at a time</h2>
  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/developers/assistants/">
        <strong>1. Project files</strong>
        <span>Create the smallest folder and understand the role of every file.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/manifest/">
        <strong>2. Manifest and identity</strong>
        <span>Name the Assistant, credit its creators, and close the document.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/genesis/">
        <strong>3. Genesis</strong>
        <span>Teach purpose, behavior, boundaries, and Power composition.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/powers/">
        <strong>4. Powers and schemas</strong>
        <span>Define the only operations the Brain may request.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/approvals/">
        <strong>5. Approvals</strong>
        <span>Choose whether a person confirms never, once, or every time.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/accounts/">
        <strong>6. Accounts</strong>
        <span>Declare OAuth provider and scope intent without handling tokens.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/secrets/">
        <strong>7. Secrets</strong>
        <span>Describe opaque private values without placing values in source.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/network/">
        <strong>8. Network access</strong>
        <span>Request exact public hosts and nothing broader.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/help/">
        <strong>9. Help</strong>
        <span>Show non-technical people what the Assistant can do.</span>
      </a>
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="flow-title">
  <span class="section-label">Mental model</span>
  <h2 id="flow-title">Genesis guides; Powers act</h2>
  <ol>
    <li>The Brain reads the enabled Assistant's Genesis and declared Powers.</li>
    <li>The Brain may request a declared Power with schema-shaped input.</li>
    <li>Shimpz validates the Power, approval, dependencies, and input.</li>
    <li>The selected Power receives only its declared private dependencies.</li>
    <li>Its output must match the closed output schema before the Brain can use it.</li>
  </ol>
</section>

<aside class="scope-note" aria-labelledby="closed-title">
  <span id="closed-title" class="kicker">Closed means predictable</span>
  <p>
    Unknown manifest fields, undeclared Power names, extra JSON properties, undefined dependency references,
    and unlisted hosts are rejected. Shimpz does not guess what a creator intended.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant SPEC">
  <a href="/developers/"><span>Back</span><strong>Developer start</strong></a>
  <a href="/developers/assistants/"><span>Next</span><strong>Project files</strong></a>
</nav>
