<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Python Assistant quickstart — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/quickstart/" />
  <meta name="description" content="Run, test, and containerize a minimal Python Shimpz Assistant." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Developers</a><span aria-hidden="true">/</span>
  <strong>Python quickstart</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Runnable starter</span>
  <h1>Build one Power end to end</h1>
  <p class="docs-lede">
    Start from the SDK's tested template, edit the two authored files, generate the machine contract,
    and invoke the same one-shot runner used by the Controller.
  </p>
</header>

<aside class="scope-note" aria-labelledby="requirements-title">
  <span id="requirements-title" class="kicker">Requirements</span>
  <p>
    Install Git, Python 3.14, <code>uv</code>, Docker, and <code>curl</code>. The starter locks its
    Python dependencies and pins the image bases used by its Dockerfile.
  </p>
</aside>

<section class="guide-section" aria-labelledby="copy-title">
  <span class="section-label">1 · Copy</span>
  <h2 id="copy-title">Create a working project beside the starter</h2>
  <CodeBlock label="Copy the SDK starter" title="Terminal" variant="code" {...data.copy} />
</section>

<section class="guide-section" aria-labelledby="manifest-title">
  <span class="section-label">2 · Declare</span>
  <h2 id="manifest-title">Edit shimpz.toml</h2>
  <CodeBlock label="No network and no Accounts" title="shimpz.toml" variant="code" {...data.manifest} />
</section>

<section class="guide-section" aria-labelledby="app-title">
  <span class="section-label">3 · Author</span>
  <h2 id="app-title">Edit app.py</h2>
  <CodeBlock label="One closed Echo Power" title="app.py" variant="code" {...data.app} />
</section>

<section class="guide-section" aria-labelledby="verify-title">
  <span class="section-label">4 · Verify</span>
  <h2 id="verify-title">Run the test and inspect the generated contract</h2>
  <CodeBlock label="Reproducible local checks" title="Terminal" variant="code" {...data.verify} />
  <p>
    <code>shimpz.contract.json</code> is generated output. Review it, but do not add fields by hand.
  </p>
</section>

<section class="guide-section" aria-labelledby="container-title">
  <span class="section-label">5 · Execute</span>
  <h2 id="container-title">Build the image and call its RPC runner</h2>
  <CodeBlock label="Container smoke test" title="Terminal" variant="code" {...data.container} />
  <p>The final RPC call prints:</p>
  <CodeBlock label="Validated Power response" title="stdout" variant="code" {...data.result} />
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/assistants/spec/execution/"><span>Back</span><strong>Execution model</strong></a>
  <a href="/developers/assistants/spec/"><span>Next</span><strong>Spec overview</strong></a>
</nav>
