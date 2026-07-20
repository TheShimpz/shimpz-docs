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
    content="Review the blocked X.com Shimpz Assistant reference and the OAuth boundary required before release."
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
    Inspect the source and the release boundary for an X.com Assistant with localized Help, typed Powers,
    explicit approval, and restricted network access.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-boundary-title">
  <span id="assistant-boundary-title" class="kicker">Publication blocked</span>
  <p>
    This reference is not installable until X OAuth 2.0 Authorization Code with S256 PKCE is owned by the
    controller. End users must never be asked for X developer keys, Bearer Tokens, access tokens, refresh
    tokens, or client secrets.
  </p>
</aside>

<section class="guide-section" aria-labelledby="assistant-install-title">
  <span class="section-label">Current path</span>
  <h2 id="assistant-install-title">Inspect it without installing</h2>
  <p>
    Clone the source and run its local checks. The Store must not advertise or install the X reference until
    the reviewed connection release is bound to an immutable image.
  </p>
  <p><a href="/developers/assistants/spec/connections/">Review the OAuth connection boundary</a>.</p>
</section>

<ol class="step-list">
  <li>
    <h2>Read the complete source</h2>
    <p>Clone the same repository used to build the immutable Store release.</p>
    <CodeBlock
      label="Clone Shimpz Assistant"
      title="Terminal · Source"
      lines={[
        { value: "git clone https://github.com/roxygens/shimpz-assistant.git" },
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
    <p>The current source deliberately refuses X provider calls until the OAuth connection exists.</p>
    <CodeBlock
      label="Run Shimpz Assistant locally"
      title="Terminal one · Runtime"
      lines={[{ value: "uv run python -m assistant.main" }]}
    />
  </li>

  <li>
    <h2>Review the intended least-privilege Powers</h2>
    <p>
      The future <code>public-user-lookup</code>, <code>identity-me</code>, <code>create-post</code>, and
      <code>delete-post</code> Powers reference one scoped X connection. Only a short-lived access token may
      enter the private Power envelope; both write Powers independently require explicit approval.
    </p>
    <CodeBlock
      label="Inspect the blocked X source without exposing a credential"
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
      <code>allowed_hosts</code> exposes <code>api.x.com</code> as the only external destination. The controller
      admits only the matching packaged manifest, and the proxy blocks every other host.
    </li>
    <li>
      A reviewed <code>connections.x</code> declaration will request provider consent without accepting X
      developer credentials in Assistant source or forms.
    </li>
    <li>Closed schemas bound every input and output; unknown fields and undeclared routes fail closed.</li>
    <li>The controller, not Assistant code, will own PKCE state, refresh, revocation, and token custody.</li>
  </ul>
  <p>
    Read the <a
      class="external-link"
      href="https://github.com/roxygens/shimpz-assistant"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Shimpz Assistant source on GitHub (opens in a new tab)">complete source on GitHub</a
    >.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant developer guide">
  <a href="/developers/assistants/spec/build-release/"><span>Back to</span><strong>Build and release</strong></a>
  <a href="/developers/assistants/salesnator/"><span>Next</span><strong>Salesnator</strong></a>
</nav>
