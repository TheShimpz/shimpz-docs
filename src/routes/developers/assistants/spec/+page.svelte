<script lang="ts">
  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

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
    Assistant Spec v1 has one small manifest and one Python file per Action. Contracts, locks,
    Dockerfiles, health endpoints, and runtime adapters are generated during platform pre-build.
  </p>
</header>

<section class="guide-section" aria-labelledby="source-title">
  <span class="section-label">Authored source</span>
  <h2 id="source-title">Every decision has one home</h2>
  <dl>
    <dt><code>icon.png</code></dt>
    <dd>One static, high-resolution identity image covered by the immutable source digest.</dd>
    <dt><code>shimpz.toml</code></dt>
    <dd>Version, identity, Genesis, exact outbound hosts, and optional OAuth Integration scopes.</dd>
    <dt><code>actions/*.py</code></dt>
    <dd>Exactly one decorated <code>async def run</code> per direct file.</dd>
    <dt><code>pyproject.toml</code></dt>
    <dd>Python version and direct dependencies, including the released <code>shimpz</code> SDK.</dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="build-title">
  <span class="section-label">Platform pre-build</span>
  <h2 id="build-title">Generated artifacts never pollute source</h2>
  <ol>
    <li>The SDK validates the project and imports each Action in isolation.</li>
    <li>It derives the canonical <code>shimpz.contract.json</code>.</li>
    <li>The platform resolves and locks dependencies and creates the runtime/container files.</li>
    <li>The Controller admits only the reviewed immutable build.</li>
  </ol>
</section>

<section class="guide-section" aria-labelledby="runtime-title">
  <span class="section-label">Runtime</span>
  <h2 id="runtime-title">Invocation contains only input and Integrations</h2>
  <p>
    The Controller validates Action input, resolves only declared OAuth bearer tokens, and invokes
    <code>/usr/local/bin/shimpz-action &lt;action-id&gt;</code> over bounded stdin. An Action returns one
    validated JSON object over stdout.
  </p>
</section>

<section class="guide-section" aria-labelledby="package-contract-title">
  <span class="section-label">Published contract</span>
  <h2 id="package-contract-title">Source packages have one byte-level authority</h2>
  <p>
    <code>shimpz publish</code> creates an uncompressed canonical POSIX ustar archive. Its exact
    allowlist, limits, normalized metadata, golden vectors, and verifier are published together:
  </p>
  <p>
    Choose visibility explicitly with <code>shimpz publish --visibility public</code> or
    <code>shimpz publish --visibility private</code>. The CLI shows the Assistant, version, source
    digest, and attributed Creator handles before recording your consent. Every Creator listed in
    <code>shimpz.toml</code> must authenticate and consent to that same immutable publication tuple.
  </p>
  <ul>
    <li><a href="/specs/source-package/v1/README.md">Source package v1 overview</a></li>
    <li><a href="/specs/source-package/v1/contract.json">Machine-readable contract</a></li>
    <li><a href="/specs/source-package/v1/vectors.json">Golden vectors</a></li>
    <li><a href="/specs/source-package/v1/verify.py">Reference verifier</a></li>
    <li><a href="/specs/source-package/v1/contract-files.sha256">File checksums</a></li>
  </ul>
  <dl>
    <dt>Developers authority commit</dt>
    <dd><code>{data.sourcePackageUpstream.commit}</code></dd>
    <dt>Contract tree</dt>
    <dd><code>{data.sourcePackageUpstream.tree}</code></dd>
  </dl>
</section>

<aside class="scope-note" aria-labelledby="closed-title">
  <span id="closed-title" class="kicker">Version 1 is the only version</span>
  <p>
    The parser accepts only Assistant Spec v1. Secrets, answer logs, author-declared suspension frames,
    dynamic approvals, author-written HTTP servers, runtime commands, and health endpoints are rejected.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/"><span>Back</span><strong>Developer start</strong></a>
  <a href="/developers/assistants/spec/manifest/"><span>Next</span><strong>shimpz.toml</strong></a>
</nav>
