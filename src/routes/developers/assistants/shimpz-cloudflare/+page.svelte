<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Shimpz Cloudflare — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/shimpz-cloudflare/" />
  <meta
    name="description"
    content="Build from Shimpz Cloudflare, the executable OAuth Account and read-only Power reference."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span><strong
    >Shimpz Cloudflare</strong
  >
</nav>

<header class="docs-page-header">
  <span class="section-label">Executable source reference</span>
  <h1>Explore Shimpz Cloudflare.</h1>
  <p class="docs-lede">
    Inspect one small production Assistant that demonstrates a controller-owned OAuth Account, two typed
    read-only Powers, localized Help, closed schemas, and exact-host egress.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-boundary-title">
  <span id="assistant-boundary-title" class="kicker">Current first-party reference</span>
  <p>
    Installation never connects Cloudflare or runs a Power. The first Power that needs the Account pauses the
    turn, opens Cloudflare consent, and resumes only after the controller validates the callback.
  </p>
</aside>

<ol class="step-list">
  <li>
    <h2>Read the complete source</h2>
    <p>Clone the same public repository used to build the immutable Store release.</p>
    <CodeBlock
      label="Clone Shimpz Cloudflare"
      title="Terminal · Source"
      lines={[
        { value: "git clone https://github.com/TheShimpz/shimpz-cloudflare.git" },
        { value: "cd shimpz-cloudflare" },
      ]}
    />
  </li>

  <li>
    <h2>Run the focused checks</h2>
    <p>The frozen Python environment validates the OAuth envelope, schemas, API transport, and redaction.</p>
    <CodeBlock
      label="Validate Shimpz Cloudflare"
      title="Terminal · Tests"
      lines={[
        { value: "uv sync --frozen" },
        { value: "uv run python -m unittest discover -s tests -v" },
      ]}
    />
  </li>

  <li>
    <h2>Review the least-privilege contract</h2>
    <p>
      <code>list-zones</code> returns one bounded page of zones. <code>list-dns-records</code> receives one exact
      zone ID and returns one bounded page of records. Both reference only <code>accounts.cloudflare</code>, are
      read-only, and require no execution approval.
    </p>
    <CodeBlock
      label="Inspect the Cloudflare manifest"
      title="Terminal · Manifest"
      lines={[{ value: "sed -n '1,220p' shimpz.assistant.toml" }]}
    />
    <CodeBlock
      label="Schema-validated zone response"
      title="list-zones · JSON"
      variant="code"
      {...data.response}
    />
  </li>
</ol>

<section class="guide-section" aria-labelledby="assistant-proof-title">
  <span class="section-label">Reusable pattern</span>
  <h2 id="assistant-proof-title">What this reference proves</h2>
  <ul>
    <li><code>allowed_hosts</code> exposes only <code>api.cloudflare.com</code>.</li>
    <li>The Account requests only <code>zone.read</code>, <code>dns.read</code>, and <code>offline_access</code>.</li>
    <li>The controller owns PKCE state, token exchange, refresh, revocation, and durable encrypted custody.</li>
    <li>The token enters only the private invocation envelope of a Power that declares the Account.</li>
    <li>Closed schemas bound every input and output; unknown fields and undeclared routes fail closed.</li>
    <li>Provider responses are treated as untrusted data and cannot expose Account tokens in chat or logs.</li>
  </ul>
  <p>
    Read the <a
      class="external-link"
      href="https://github.com/TheShimpz/shimpz-cloudflare"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Shimpz Cloudflare source on GitHub (opens in a new tab)">complete source on GitHub</a
    >.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant developer guide">
  <a href="/developers/assistants/spec/build-release/"><span>Back to</span><strong>Build and release</strong></a>
  <a href="/developers/assistants/"><span>Overview</span><strong>Assistants</strong></a>
</nav>
