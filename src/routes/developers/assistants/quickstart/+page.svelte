<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Python Assistant quickstart — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/quickstart/" />
  <meta name="description" content="Create and test a Python Shimpz Assistant without Docker." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Developers</a><span aria-hidden="true">/</span>
  <strong>Python quickstart</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Docker-free development</span>
  <h1>Test one Power with two CLI commands</h1>
  <p class="docs-lede">
    Create three small source files, then let the native <code>shimpz</code> CLI manage Python 3.14,
    <code>uv</code>, and the released SDK.
  </p>
</header>

<aside class="scope-note" aria-labelledby="requirements-title">
  <span id="requirements-title" class="kicker">Install the CLI</span>
  <p>
    Download the native binary from
    <a href="https://github.com/TheShimpz/shimpz-cli/releases">GitHub Releases</a>, or run
    <code>cargo install shimpz-cli --locked</code>. Both install the <code>shimpz</code> command.
  </p>
</aside>

<section class="guide-section" aria-labelledby="manifest-title">
  <span class="section-label">1 · Manifest</span>
  <h2 id="manifest-title">Create shimpz.toml</h2>
  <CodeBlock label="Identity and Genesis" title="shimpz.toml" variant="code" {...data.manifest} />
</section>

<section class="guide-section" aria-labelledby="project-title">
  <span class="section-label">2 · Python</span>
  <h2 id="project-title">Create pyproject.toml</h2>
  <CodeBlock label="Released Python SDK" title="pyproject.toml" variant="code" {...data.project} />
</section>

<section class="guide-section" aria-labelledby="power-title">
  <span class="section-label">3 · Power</span>
  <h2 id="power-title">Create powers/echo.py</h2>
  <CodeBlock label="One closed Echo Power" title="powers/echo.py" variant="code" {...data.power} />
</section>

<section class="guide-section" aria-labelledby="verify-title">
  <span class="section-label">4 · Verify</span>
  <h2 id="verify-title">Check the project and invoke echo</h2>
  <CodeBlock label="Native local checks" title="Terminal" variant="code" {...data.verify} />
  <p>The test prints the direct validated result:</p>
  <CodeBlock label="Power result" title="stdout" variant="code" {...data.result} />
</section>

<aside class="scope-note" aria-labelledby="artifact-title">
  <span id="artifact-title" class="kicker">Nothing else to commit</span>
  <p>
    The platform generates the machine contract, lock files, and container/runtime artifacts before
    building the Assistant. Local Power tests do not require Docker.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the developer guide">
  <a href="/developers/assistants/spec/execution/"><span>Back</span><strong>Execution model</strong></a>
  <a href="/developers/assistants/spec/"><span>Next</span><strong>Spec overview</strong></a>
</nav>
