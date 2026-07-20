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
    content="Run the canonical Shimpz Assistant and inspect its four typed X.com Powers, five secret declarations, and built-in Help."
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
    Use one small, real Assistant to see how Genesis, localized Help, typed Powers, per-Power secrets, async
    I/O, explicit approval, and restricted network access fit together.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-boundary-title">
  <span id="assistant-boundary-title" class="kicker">Easy to inspect</span>
  <p>
    The reference declares five X credentials but contains no values. In a Team, requests can reach only
    <code>api.x.com</code> through the authenticated egress proxy; the Assistant receives no host mount,
    published port, general network access, or secret outside the Power currently being invoked.
  </p>
</aside>

<section class="guide-section" aria-labelledby="assistant-install-title">
  <span class="section-label">Fastest path</span>
  <h2 id="assistant-install-title">Install it in a Team</h2>
  <p>
    Install Shimpz, create a Team, then choose <strong>Shimpz Assistant</strong> in the local Store. Open
    the Team chat and select the <strong>?</strong> button next to <strong>Send</strong> to read its
    localized Help and copy a starter prompt.
  </p>
  <p><a href="/assistants/">Follow the first Assistant guide</a>.</p>
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
    <h2>Start the local process</h2>
    <p>The process exposes health, user Help, and exactly four declared Power routes.</p>
    <CodeBlock
      label="Run Shimpz Assistant locally"
      title="Terminal one · Runtime"
      lines={[{ value: "uv run python -m assistant.main" }]}
    />
  </li>

  <li>
    <h2>Compose least-privilege Powers</h2>
    <p>
      <code>public-user-lookup</code> receives only a Bearer Token. <code>identity-me</code>,
      <code>create-post</code>, and <code>delete-post</code> receive the four OAuth 1.0a values, while both write
      Powers independently require explicit approval. The Team Brain can compose them from natural language,
      but the controller validates and invokes every step.
    </p>
    <CodeBlock
      label="Inspect the declarative X contract without exposing a credential"
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
      <code>GENESIS.md</code> defines behavior, response style, safety boundaries, and when and how to combine
      the four X Powers.
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
      Five public secret declarations drive the write-only Admin forms; each Power receives only its declared
      values through the closed private RPC envelope.
    </li>
    <li>Closed schemas bound every input and output; unknown fields and undeclared routes fail closed.</li>
    <li>A mature OAuth 1.0a signer and shared async HTTP session keep provider calls correct and efficient.</li>
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
