<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Build your first Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/quickstart/" />
  <meta name="description" content="Generate, validate, and run your first Python Shimpz Assistant without Docker." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Build Assistants</a><span aria-hidden="true">/</span>
  <strong>Build your first Assistant</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">About 5 minutes · No Docker</span>
  <h1>Build and run your first Assistant</h1>
  <p class="docs-lede">
    Generate a working Python Assistant, validate its complete source package, and invoke one Action locally.
  </p>
</header>

<aside class="scope-note" aria-labelledby="requirements-title">
  <span id="requirements-title" class="kicker">Before you start</span>
  <p>
    You need the native <code>shimpz</code> CLI. Download it from
    <a href="https://github.com/TheShimpz/shimpz-cli/releases">GitHub Releases</a>. If you already have Rust 1.97.1
    or newer, you can instead run <code>cargo install shimpz-cli --locked</code>. Confirm the installation with
    <code>shimpz --version</code>.
  </p>
</aside>

<section class="guide-section" aria-labelledby="create-title">
  <span class="section-label">1 · Create</span>
  <h2 id="create-title">Generate a valid starter</h2>
  <CodeBlock label="Create a Python Assistant" title="Terminal" variant="code" {...data.create} />
  <p>
    The generator pins the current released SDK and creates every required source file, including the Assistant
    icon. It does not need Docker or a running Shimpz Space.
  </p>
</section>

<section class="guide-section" aria-labelledby="files-title">
  <span class="section-label">2 · Inspect</span>
  <h2 id="files-title">Know the files you own</h2>
  <CodeBlock label="Generated starter" title="Project tree" variant="code" {...data.files} />
  <ul>
    <li><code>shimpz.toml</code> declares identity, Genesis, network intent, and optional Integrations.</li>
    <li><code>actions/hello_world.py</code> declares the typed <code>hello-world</code> Action.</li>
    <li><code>pyproject.toml</code> pins Python 3.14 and the released Shimpz SDK.</li>
    <li><code>icon.png</code> is the Assistant identity image included in the immutable source package.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="verify-title">
  <span class="section-label">3 · Verify</span>
  <h2 id="verify-title">Validate the package and invoke the Action</h2>
  <CodeBlock label="Native local checks" title="Terminal" variant="code" {...data.verify} />
  <p><code>shimpz check</code> must report <strong>Assistant is valid</strong>. The test then prints:</p>
  <CodeBlock label="Action result" title="stdout" variant="code" {...data.result} />
</section>

<aside class="scope-note" aria-labelledby="proof-title">
  <span id="proof-title" class="kicker">What you proved</span>
  <p>
    The manifest, icon, Action contract, dependency set, and direct result satisfy the current local contract.
    Publication performs its own checks again before accepting the immutable package.
  </p>
</aside>

<section class="guide-section" aria-labelledby="troubleshooting-title">
  <span class="section-label">If it fails</span>
  <h2 id="troubleshooting-title">Fix the first visible error</h2>
  <dl>
    <dt><code>shimpz: command not found</code></dt>
    <dd>Install the CLI, open a new terminal, and run <code>shimpz --version</code> before retrying.</dd>
    <dt>SDK or Python download fails</dt>
    <dd>Check network access and retry once. The CLI manages its own Python 3.14 and <code>uv</code>.</dd>
    <dt>Assistant validation fails</dt>
    <dd>Read the first reported file and field, correct it, then run <code>shimpz check</code> again.</dd>
  </dl>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Creator guide">
  <a href="/developers/"><span>Back</span><strong>Creator overview</strong></a>
  <a href="/developers/assistants/"><span>Next</span><strong>Project structure</strong></a>
</nav>
