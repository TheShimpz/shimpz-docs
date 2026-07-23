<svelte:head>
  <title>Assistant Spec v3 — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/" />
  <meta
    name="description"
    content="Understand the two-file, SDK-authored contract for Shimpz Assistants."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Developers</a><span aria-hidden="true">/</span><strong>Assistant Spec v3</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">One reviewed contract</span>
  <h1>Declare intent; author behavior</h1>
  <p class="docs-lede">
    Assistant Spec v3 has two authored files. <code>shimpz.toml</code> states the smallest security
    boundary. <code>app.py</code> declares typed Powers and implements their behavior with the Python SDK.
  </p>
</header>

<section class="guide-section" aria-labelledby="files-title">
  <span class="section-label">Two sources</span>
  <h2 id="files-title">Each decision has one home</h2>
  <dl>
    <dt><code>shimpz.toml</code></dt>
    <dd>
      Identity, exact outbound hosts, and OAuth providers with their requested scopes. It contains no
      Power schemas, approval policy, or secret values.
    </dd>
    <dt><code>app.py</code></dt>
    <dd>
      Async <code>@power</code> functions, typed <code>field</code> inputs, account use, and dynamic
      human requests or approvals.
    </dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="contract-title">
  <span class="section-label">Generated artifact</span>
  <h2 id="contract-title">The SDK emits the machine contract</h2>
  <ol>
    <li>The SDK imports <code>app.py</code> and collects its decorated Powers.</li>
    <li>It writes a canonical <code>shimpz.contract.json</code> into the image.</li>
    <li>The Controller validates its closed shape and cross-checks its accounts with <code>shimpz.toml</code>.</li>
    <li>Only the reviewed, image-bound contract may execute.</li>
  </ol>
</section>

<section class="guide-section" aria-labelledby="runtime-title">
  <span class="section-label">Runtime</span>
  <h2 id="runtime-title">A Power runs in a fresh isolated process</h2>
  <p>
    The Controller injects only the declared account tokens, validates the input, and invokes the SDK
    runner. Human interaction suspends the Power and resumes it through deterministic replay. The final
    result must satisfy the declared output schema before the Brain can use it.
  </p>
</section>

<aside class="scope-note" aria-labelledby="closed-title">
  <span id="closed-title" class="kicker">Fail closed</span>
  <p>
    Unknown fields, undeclared accounts, malformed schemas, unlisted hosts, invalid inputs, invalid
    outputs, and leaked private values are rejected rather than guessed.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/"><span>Back</span><strong>Developer start</strong></a>
  <a href="/developers/assistants/spec/manifest/"><span>Next</span><strong>shimpz.toml</strong></a>
</nav>
