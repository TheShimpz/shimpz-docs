<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Shimpz Cloudflare example — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/shimpz-cloudflare/" />
  <meta name="description" content="Follow the complete production Cloudflare Assistant from OAuth intent to DNS output." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Developers</a><span aria-hidden="true">/</span><strong>Cloudflare example</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Production reference · 0.1.5</span>
  <h1>Follow one complete Assistant</h1>
  <p class="docs-lede">
    Shimpz Cloudflare lists zones and DNS records through one controller-owned OAuth Account. Its source is
    intentionally small enough to read before creating the next provider integration.
  </p>
</header>

<ol class="step-list">
  <li>
    <h2>Clone and validate it</h2>
    <CodeBlock
      label="Validate Shimpz Cloudflare"
      title="Terminal · reference source"
      lines={[
        { value: "git clone https://github.com/TheShimpz/shimpz-cloudflare.git" },
        { value: "cd shimpz-cloudflare" },
        { value: "uv sync --frozen" },
        { value: "uv run python -m unittest discover -s tests -v" },
      ]}
    />
  </li>

  <li>
    <h2>Start with the manifest</h2>
    <p>
      <code>allowed_hosts</code> contains only <code>api.cloudflare.com</code>. The <code>cloudflare</code> Account
      requests <code>zone.read</code>, <code>dns.read</code>, and <code>offline_access</code>. Both Powers reference
      that Account and are read-only.
    </p>
    <CodeBlock
      label="Open the Assistant manifest"
      title="Terminal · contract"
      lines={[{ value: "sed -n '1,220p' shimpz.assistant.toml" }]}
    />
  </li>

  <li>
    <h2>Trace the runtime</h2>
    <ul>
      <li><code>assistant/main.py</code> exposes health and the fixed RPC loop.</li>
      <li><code>assistant/rpc.py</code> validates the private invocation and dispatches only known Powers.</li>
      <li><code>assistant/cloudflare_api.py</code> builds fixed Cloudflare requests and rejects redirects.</li>
      <li><code>schemas/</code> closes every input and output object.</li>
      <li><code>tests/</code> proves transport limits, failures, contract shape, and token redaction.</li>
    </ul>
  </li>
</ol>

<section class="guide-section" aria-labelledby="new-power-title">
  <span class="section-label">Adding one Power</span>
  <h2 id="new-power-title">Change every layer deliberately</h2>
  <ol>
    <li>Describe one user outcome in Help and Genesis.</li>
    <li>Add the Power and only its necessary Account scopes to the manifest.</li>
    <li>Add closed input and output schemas with bounded arrays and strings.</li>
    <li>Implement one fixed provider operation; do not expose arbitrary URLs or methods.</li>
    <li>Test success, provider errors, malformed data, limits, timeouts, redirects, and redaction.</li>
    <li>Update the version and changelog, then use the stable release gate.</li>
  </ol>
</section>

<p>
  Read the <a
    class="external-link"
    href="https://github.com/TheShimpz/shimpz-cloudflare"
    target="_blank"
    rel="noopener noreferrer">complete source on GitHub</a
  >.
</p>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/assistants/spec/"><span>Back</span><strong>Current contract</strong></a>
  <a href="/developers/assistants/spec/accounts/providers/"><span>Next</span><strong>Add an OAuth provider</strong></a>
</nav>
