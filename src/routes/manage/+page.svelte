<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Update or reset Shimpz — Shimpz docs</title>
  <meta name="description" content="Update or reset a local Shimpz Space installation safely." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><span>Your Space</span
  ><span aria-hidden="true">/</span><strong>Update or reset</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Keep it current</span>
  <h1>Update or reset</h1>
  <p class="docs-lede">
    Run the install command again to pull the current stable images. The installer keeps the
    previous digests and restores them when a replacement does not become healthy.
  </p>
</header>

<p>
  Reset first asks the local controller to remove its owned Assistants and Teams, then stops the managed
  Space and permanently removes its Admin and controller data:
</p>
<CodeBlock
  label="Reset the Shimpz installation"
  title="Terminal · Shimpz reset"
  lines={[{ value: "curl -fsSL https://install.shimpz.com | sh -s -- --reset" }]}
/>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/concepts/"><span>Next</span><strong>Core concepts</strong></a>
</nav>
