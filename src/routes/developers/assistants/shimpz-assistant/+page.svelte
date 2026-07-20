<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Shimpz Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/shimpz-assistant/" />
  <meta
    name="description"
    content="Build from Shimpz Assistant 0.6.0, the executable reference for OAuth Accounts, BYOK Secrets, approvals, and exact-host egress."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span><strong
    >Shimpz Assistant</strong
  >
</nav>

<header class="docs-page-header">
  <span class="section-label">Executable source reference</span>
  <h1>Explore Shimpz Assistant.</h1>
  <p class="docs-lede">
    Inspect one executable Assistant that demonstrates X OAuth Accounts, Mux BYOK Secrets, localized Help,
    typed Powers, explicit approval, and exact-host network access.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-boundary-title">
  <span id="assistant-boundary-title" class="kicker">Reference release · 0.6.0</span>
  <p>
    Install it from the Assistant Store. An X Power opens the Account flow and sends the user to X consent. A
    Mux Power opens the write-only Secret modal for only the missing Mux values. Neither mechanism runs during
    installation, and private values never enter chat.
  </p>
</aside>

<section class="guide-section" aria-labelledby="assistant-install-title">
  <span class="section-label">Install and authorize</span>
  <h2 id="assistant-install-title">Provide private access only when a Power needs it</h2>
  <p>
    Installing the immutable Assistant does not connect an Account, collect a Secret, or run a Power. Private
    access is requested just in time, isolated to one Team and Assistant, and remains separate from approval.
  </p>
  <p>
    Read <a href="/developers/assistants/spec/accounts/">Accounts</a> for OAuth and
    <a href="/developers/assistants/spec/secrets/">Secrets</a> for manual BYOK.
  </p>
</section>

<ol class="step-list">
  <li>
    <h2>Read the complete source</h2>
    <p>Clone the same repository used to build the immutable Store release.</p>
    <CodeBlock
      label="Clone Shimpz Assistant"
      title="Terminal · Source"
      lines={[
        { value: "git clone https://github.com/TheShimpz/shimpz-assistant.git" },
        { value: "cd shimpz-assistant" },
      ]}
    />
  </li>

  <li>
    <h2>Run the focused checks</h2>
    <p>The locked Python 3.14 environment validates the source contract and the bounded async runtime.</p>
    <CodeBlock
      label="Validate Shimpz Assistant"
      title="Terminal · Tests"
      lines={[
        { value: "uv sync --frozen" },
        { value: "uv run python -m unittest discover -s tests -v" },
      ]}
    />
  </li>

  <li>
    <h2>Inspect the fail-closed process</h2>
    <p>
      The runtime rejects a call unless the controller supplies exactly the Account and Secret IDs declared by
      that Power. It rejects missing, extra, malformed, or wrong-purpose private values.
    </p>
    <CodeBlock
      label="Run Shimpz Assistant locally"
      title="Terminal one · Runtime"
      lines={[{ value: "uv run python -m assistant.main" }]}
    />
  </li>

  <li>
    <h2>Review all least-privilege Powers</h2>
    <p>
      The <code>public-user-lookup</code>, <code>identity-me</code>, <code>create-post</code>, and
      <code>delete-post</code> Powers reference one scoped X Account. Only a bounded access token may enter the
      private Power envelope; both writes independently require explicit approval.
    </p>
    <p>
      <code>list-direct-uploads</code>, <code>create-test-direct-upload</code>, and
      <code>cancel-direct-upload</code> reference the Mux Token ID and Token Secret. The create and cancel
      Powers always require approval. The test create fixes a 60-second timeout, <code>test = true</code>, and
      basic video quality, uploads no media, and omits the signed URL from chat. <code>verify-mux-webhook</code>
      receives only the signing Secret, verifies HMAC-SHA256 with constant-time comparison and a five-minute
      freshness window, and performs no network request.
    </p>
    <CodeBlock
      label="Inspect the X manifest without exposing a credential"
      title="Terminal · Manifest"
      lines={[
        {
          value: "sed -n '1,240p' shimpz.assistant.toml",
        },
      ]}
    />
    <CodeBlock
      label="Illustrative schema-validated public profile response"
      title="public-user-lookup · JSON"
      variant="code"
      {...data.response}
    />
  </li>
</ol>

<section class="guide-section" aria-labelledby="assistant-proof-title">
  <span class="section-label">What this reference demonstrates</span>
  <h2 id="assistant-proof-title">One complete, reusable pattern</h2>
  <ul>
    <li>
      <code>GENESIS.md</code> defines behavior, response style, safety boundaries, and intended Power composition.
    </li>
    <li>
      <code>help/HELP-&lt;locale&gt;.md</code> gives the installed user short instructions and prompt examples in
      every Admin language.
    </li>
    <li>
      <code>allowed_hosts</code> exposes exactly <code>api.x.com</code> and <code>api.mux.com</code>. The
      controller admits only the matching packaged manifest, and the proxy blocks every other host.
    </li>
    <li>
      The reviewed <code>accounts.x</code> declaration requests provider consent without accepting X developer
      credentials in Assistant source or forms.
    </li>
    <li>
      Three public Mux Secret declarations exercise a multi-value API credential and a separate webhook
      signing key. Per-Power references prevent one purpose from receiving another purpose's values.
    </li>
    <li>Closed schemas bound every input and output; unknown fields and undeclared routes fail closed.</li>
    <li>The controller, not Assistant code, owns PKCE state, refresh, revocation, and durable private-value custody.</li>
  </ul>
  <p>
    Read the <a
      class="external-link"
      href="https://github.com/TheShimpz/shimpz-assistant"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Shimpz Assistant source on GitHub (opens in a new tab)">complete source on GitHub</a
    >.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant developer guide">
  <a href="/developers/assistants/spec/build-release/"><span>Back to</span><strong>Build and release</strong></a>
  <a href="/developers/assistants/"><span>Overview</span><strong>Assistants</strong></a>
</nav>
