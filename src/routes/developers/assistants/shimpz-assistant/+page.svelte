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
    content="Run the canonical Shimpz Assistant and inspect its three typed weather Powers and built-in user help."
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
    Use one small, real Assistant to see how Rules, user Help, typed Powers, async I/O, and restricted
    network access fit together.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-boundary-title">
  <span id="assistant-boundary-title" class="kicker">Easy to inspect</span>
  <p>
    The reference uses public Open-Meteo data and needs no weather credential. In a Team, requests can
    reach only the declared weather hosts through the authenticated egress proxy; the Assistant receives
    no host mount, published port, or general network access.
  </p>
</aside>

<section class="guide-section" aria-labelledby="assistant-install-title">
  <span class="section-label">Fastest path</span>
  <h2 id="assistant-install-title">Install it in a Team</h2>
  <p>
    Install Shimpz, create a Team, then choose <strong>Shimpz Assistant</strong> in the local Store. Open
    the Team chat and select the <strong>?</strong> button next to <strong>Send</strong> to read its
    <code>HELP.md</code> and copy a starter prompt.
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
    <p>The process exposes health, user Help, and exactly three declared Power routes.</p>
    <CodeBlock
      label="Run Shimpz Assistant locally"
      title="Terminal one · Runtime"
      lines={[{ value: "uv run python -m assistant.main" }]}
    />
  </li>

  <li>
    <h2>Compose real Powers</h2>
    <p>
      First call <code>search-location</code> to obtain coordinates. Pass the selected coordinates to
      <code>current-weather</code> or <code>daily-forecast</code>. The Team Brain performs this composition
      from a natural-language request.
    </p>
    <CodeBlock
      label="Call the current weather Power"
      title="Terminal two · Power call"
      lines={[
        {
          value:
            "curl -fsS -H 'content-type: application/json' -d '{\"latitude\":38.72,\"longitude\":-9.14}' http://127.0.0.1:8080/v1/powers/current-weather",
        },
      ]}
    />
    <CodeBlock
      label="Current weather Power response"
      title="Response · JSON"
      variant="code"
      {...data.response}
    />
  </li>
</ol>

<section class="guide-section" aria-labelledby="assistant-proof-title">
  <span class="section-label">What this reference demonstrates</span>
  <h2 id="assistant-proof-title">One complete, reusable pattern</h2>
  <ul>
    <li><code>assistant/RULES.md</code> tells the Brain when and how to combine the declared Powers.</li>
    <li><code>HELP.md</code> gives the installed user short instructions and prompt examples.</li>
    <li>Closed schemas bound every input and output; unknown fields and undeclared routes fail closed.</li>
    <li>A shared async HTTP session keeps external calls efficient without granting ambient authority.</li>
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
