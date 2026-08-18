<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant icon — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/icons/" />
  <meta
    name="description"
    content="Prepare the single canonical icon that identifies a Shimpz Assistant."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Creator overview</a><span aria-hidden="true">/</span>
  <strong>Assistant icon</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Visual identity</span>
  <h1>Publish one icon that stays sharp everywhere</h1>
  <p class="docs-lede">
    Put one high-resolution <code>icon.png</code> at the project root. Shimpz derives every display size
    from this immutable source, so Creators do not maintain web, desktop, or mobile variants.
  </p>
</header>

<section class="guide-section" aria-labelledby="contract-title">
  <span class="section-label">Required contract</span>
  <h2 id="contract-title">Use one predictable file</h2>
  <dl>
    <dt>Filename</dt>
    <dd>Exactly <code>icon.png</code> at the Assistant project root.</dd>
    <dt>Format</dt>
    <dd>A static PNG. Animated PNG, remote URLs, SVG, JPEG, WebP, and alternate filenames are rejected.</dd>
    <dt>Canvas</dt>
    <dd>Exactly 1024 × 1024 pixels, no larger than 1 MiB.</dd>
    <dt>Publication</dt>
    <dd>The icon bytes are covered by the source digest and travel through the standard Developers publication.</dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="composition-title">
  <span class="section-label">Composition</span>
  <h2 id="composition-title">Leave room for every surface</h2>
  <ul>
    <li>Center the identifying mark inside roughly 80% of the canvas.</li>
    <li>Prefer transparency when the mark must work on both dark and light surfaces.</li>
    <li>Do not bake rounded corners, a circle, a cyberpunk frame, or a drop shadow into the image.</li>
    <li>Keep small text out of the artwork; the Assistant name remains accessible text beside the icon.</li>
    <li>Export directly at 1024 × 1024 instead of enlarging a small raster source.</li>
  </ul>
  <p>
    Shimpz owns presentation, cropping, fallback behavior, and density scaling. The Creator owns only the
    lossless identity source.
  </p>
</section>

<section class="guide-section" aria-labelledby="workflow-title">
  <span class="section-label">Creator workflow</span>
  <h2 id="workflow-title">Validate before you publish</h2>
  <CodeBlock label="Assistant icon workflow" title="Project and validation" variant="code" {...data.workflow} />
  <p>
    <code>shimpz assistant check</code> verifies the signature, dimensions, size, PNG chunk integrity, and absence of
    animation before upload. A different icon changes the source digest, so increment the Assistant version
    before you <a href="/developers/assistants/publish/">publish another immutable release</a>. Installed Teams
    receive it only through the reviewed update lifecycle.
  </p>
</section>

<aside class="scope-note" aria-labelledby="rights-title">
  <span id="rights-title" class="kicker">Use artwork you may publish</span>
  <p>
    The Creator is responsible for copyright, trademark, and brand-guideline permission. Use a provider mark
    only when the rights holder permits this exact referential use, preserve required attribution, and never
    imply endorsement.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/"><span>Back</span><strong>Project structure</strong></a>
  <a href="/developers/assistants/spec/actions/"><span>Next</span><strong>Actions</strong></a>
</nav>
