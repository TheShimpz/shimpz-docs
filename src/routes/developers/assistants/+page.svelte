<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Build a Shimpz Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/" />
  <meta name="description" content="Build a focused Shimpz Assistant by following the production Cloudflare project." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Developers</a><span aria-hidden="true">/</span><strong>Assistant project</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Practical project guide</span>
  <h1>Build one useful Power first</h1>
  <p class="docs-lede">
    A good Assistant does one provider job clearly. Begin with a single read-only user outcome, request the
    minimum access it needs, and make every input and output explicit.
  </p>
</header>

<ol class="step-list">
  <li>
    <h2>Read the working reference</h2>
    <CodeBlock
      label="Clone Shimpz Cloudflare"
      title="Terminal · source"
      lines={[
        { value: "git clone https://github.com/TheShimpz/shimpz-cloudflare.git" },
        { value: "cd shimpz-cloudflare" },
      ]}
    />
  </li>

  <li>
    <h2>Understand the small project shape</h2>
    <CodeBlock
      label="Assistant project files"
      title="Project · important files"
      lines={[
        { value: "shimpz.assistant.toml     # identity, hosts, Accounts, and Powers", kind: "output" },
        { value: "GENESIS.md                # behavior and Power composition", kind: "output" },
        { value: "help/HELP-en.md           # examples shown to the person using it", kind: "output" },
        { value: "schemas/*.schema.json     # closed Power inputs and outputs", kind: "output" },
        { value: "assistant/                # bounded runtime code", kind: "output" },
        { value: "tests/                    # success, failure, and redaction proofs", kind: "output" },
        { value: "CHANGELOG.md              # user-visible release changes", kind: "output" },
      ]}
    />
  </li>

  <li>
    <h2>Define the outcome before the API call</h2>
    <p>Write one sentence a non-developer can understand. For example:</p>
    <blockquote>List the DNS records for a domain I already connected.</blockquote>
    <p>
      From that sentence, derive one Power, its smallest provider scope, one exact API host, bounded pagination,
      and closed JSON schemas. Do not start with a generic HTTP client.
    </p>
  </li>

  <li>
    <h2>Run the same checks on every change</h2>
    <CodeBlock
      label="Validate an Assistant"
      title="Terminal · Python 3.14"
      lines={[
        { value: "uv sync --frozen" },
        { value: "uv run python -m unittest discover -s tests -v" },
        { value: "uvx --from ruff==0.15.4 ruff format --check ." },
        { value: "uvx --from ruff==0.15.4 ruff check ." },
      ]}
    />
  </li>
</ol>

<section class="guide-section" aria-labelledby="review-title">
  <span class="section-label">Review questions</span>
  <h2 id="review-title">Make every test earn its CPU</h2>
  <ul>
    <li>Does this Power solve a real user request, or merely expose a provider endpoint?</li>
    <li>Can its input choose a host, URL, method, path, or arbitrary payload? If so, narrow it.</li>
    <li>Do tests cover timeouts, redirects, invalid JSON, oversized responses, redaction, and unknown fields?</li>
    <li>Can a reader understand the Help example without knowing the provider API?</li>
    <li>Would removing a test leave a meaningful security or behavior contract unprotected?</li>
  </ul>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/"><span>Back</span><strong>Developer quick start</strong></a>
  <a href="/developers/assistants/spec/"><span>Next</span><strong>Current contract</strong></a>
</nav>
