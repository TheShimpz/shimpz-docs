<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Validate and release an Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/build-release/" />
  <meta name="description" content="Validate an Assistant and publish one immutable stable release." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Developers</a><span aria-hidden="true">/</span><strong>Validate and release</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Stable only</span>
  <h1>Publish tested bytes once</h1>
  <p class="docs-lede">
    Shimpz currently has one delivery channel: stable. The Store installs a reviewed immutable digest, never a
    mutable source branch or development tag.
  </p>
</header>

<section class="guide-section" aria-labelledby="local-title">
  <span class="section-label">Before pushing</span>
  <h2 id="local-title">Run the fast source gate</h2>
  <CodeBlock
    label="Validate the Assistant source"
    title="Terminal · local checks"
    lines={[
      { value: "uv sync --frozen" },
      { value: "uv run python -m unittest discover -s tests -v" },
      { value: "uvx --from ruff==0.15.4 ruff format --check ." },
      { value: "uvx --from ruff==0.15.4 ruff check ." },
    ]}
  />
</section>

<section class="guide-section" aria-labelledby="release-title">
  <span class="section-label">Release checklist</span>
  <h2 id="release-title">Require evidence in this order</h2>
  <ol>
    <li>Keep the change small and update <code>CHANGELOG.md</code> in user language.</li>
    <li>Pass focused unit, schema, transport, timeout, redaction, and negative security tests.</li>
    <li>Build both supported architectures from the same committed source.</li>
    <li>Run each image unprivileged, read-only, capability-free, and behind its exact egress policy.</li>
    <li>Publish provenance and an SBOM with the multi-platform image.</li>
    <li>Verify the registry digest and runnable platforms.</li>
    <li>Bind that digest in the trusted catalog and complete one real stable smoke test.</li>
  </ol>
</section>

<aside class="scope-note" aria-labelledby="publisher-title">
  <span id="publisher-title" class="kicker">Platform-owned publishing</span>
  <p>
    Creators do not choose runtime ports, health routes, host mounts, image tags, or catalog digests in
    <code>shimpz.assistant.toml</code>. The reviewed Shimpz publisher owns packaging and admission.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/assistants/spec/accounts/providers/"><span>Back</span><strong>Add an OAuth provider</strong></a>
  <a href="/developers/assistants/shimpz-cloudflare/"><span>Example</span><strong>Shimpz Cloudflare</strong></a>
</nav>
