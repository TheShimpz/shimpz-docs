<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Update or remove Shimpz — Shimpz docs</title>
  <meta name="description" content="Update a stable Shimpz installation or remove its local data." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><strong>Update or remove</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Maintenance</span>
  <h1>Use the same installer</h1>
  <p class="docs-lede">
    Running the installation command again updates Shimpz to the current stable images. Existing Teams,
    Accounts, settings, and conversations remain in place.
  </p>
</header>

<CodeBlock
  label="Update Shimpz"
  title="Terminal · stable update"
  lines={[{ value: "curl -fsSL https://install.shimpz.com | sh" }]}
/>

<p>
  The installer checks the replacement before switching to it. If the new version does not become healthy,
  it keeps or restores the previous working version.
</p>

<section class="guide-section" aria-labelledby="reset-title">
  <span class="section-label">Permanent removal</span>
  <h2 id="reset-title">Reset only when you want to delete everything</h2>
  <p>
    Reset removes the managed Assistants, Teams, Accounts, Admin state, and local Shimpz data. It cannot be
    undone. Disconnect provider Accounts first when possible.
  </p>
  <CodeBlock
    label="Permanently reset Shimpz"
    title="Terminal · destructive reset"
    lines={[{ value: "curl -fsSL https://install.shimpz.com | sh -s -- --reset" }]}
  />
</section>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/concepts/"><span>Next</span><strong>Simple glossary</strong></a>
</nav>
