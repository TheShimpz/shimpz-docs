<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant project layout — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/" />
  <meta name="description" content="Structure a file-backed Python Shimpz Assistant." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v1</a><span aria-hidden="true">/</span>
  <strong>Project layout</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Minimal source</span>
  <h1>Give every Power one obvious home</h1>
  <p class="docs-lede">
    The required <code>powers/</code> directory is the public behavior surface. Each direct Python file
    declares exactly one decorated <code>async def run</code>.
  </p>
</header>

<section class="guide-section" aria-labelledby="shape-title">
  <span class="section-label">Repository shape</span>
  <h2 id="shape-title">Keep authored source separate from build output</h2>
  <CodeBlock label="Minimal Assistant project" title="Project files" variant="code" {...data.projectFiles} />
  <p>
    <code>shimpz.toml</code>, <code>pyproject.toml</code>, and <code>powers/</code> are required.
    <code>lib/</code> and <code>tests/</code> are optional. Dockerfiles, locks, generated contracts,
    changelogs, and Docker ignore files are platform build output rather than Assistant source.
  </p>
</section>

<section class="guide-section" aria-labelledby="power-title">
  <span class="section-label">Smallest Power</span>
  <h2 id="power-title">One file, one async run function</h2>
  <CodeBlock label="Minimal Echo Power" title="powers/echo.py" variant="code" {...data.power} />
  <p>
    The filename becomes the Power id: underscores are replaced with hyphens. Type annotations become
    closed input and output schemas; helper code stays in <code>lib/</code>.
  </p>
</section>

<aside class="scope-note" aria-labelledby="generated-title">
  <span id="generated-title" class="kicker">Generated during pre-build</span>
  <p>
    Shimpz Genesis creates <code>shimpz.contract.json</code>. The platform resolves dependencies and
    builds the immutable runtime. Do not hand-edit or commit those artifacts.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/manifest/"><span>Back</span><strong>shimpz.toml</strong></a>
  <a href="/developers/assistants/spec/powers/"><span>Next</span><strong>Powers</strong></a>
</nav>
