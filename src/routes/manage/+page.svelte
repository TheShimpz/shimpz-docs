<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Maintain your Shimpz Space — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/manage/" />
  <meta name="description" content="Update a stable Shimpz installation or remove its local data." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">Use Shimpz</a><span aria-hidden="true">/</span><strong>Maintain your Space</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Maintenance</span>
  <h1>Manage the Space with the CLI</h1>
  <p class="docs-lede">
    Running <code>shimpz install</code> again reconciles Shimpz to the current atomic release. Existing Teams,
    Integrations, settings, and conversations remain in place.
  </p>
</header>

<CodeBlock
  label="Update Shimpz"
  title="Terminal · stable update"
  lines={[{ value: "shimpz install" }]}
/>

<p>
  The release-bound CLI checks the replacement before switching to it. If the new version does not become healthy,
  it keeps or restores the previous working version. A successful run ends with
  <strong>Shimpz Space is up to date</strong>.
</p>

<p>
  If the CLI-owned Local Space exists but its current Docker runtime fails validation, the CLI names
  the failure, lists the exact owned scope, and asks whether to remove that corrupt Local state and install a fresh
  Space. <strong>Yes</strong> permanently removes every listed resource and the installed Local state before
  continuing in the same terminal. Any listed Team, Assistant, credential, setting, conversation, or Docker data is
  lost. <strong>No</strong>, Enter, or a non-interactive run leaves it unchanged. This recovery choice is available
  only for a corrupt CLI-owned Space; resetting a healthy Space still requires the Supervisor password.
</p>

<section class="guide-section" aria-labelledby="reset-title">
  <span class="section-label">Permanent removal</span>
  <h2 id="reset-title">Reset only when you want to delete everything</h2>
  <p>
    Reset removes the managed Assistants, Teams, Integrations, Admin state, and local Shimpz data. It cannot be
    undone. Disconnect provider Integrations first when possible. Run reset in an interactive terminal: it requires
    the current Supervisor password before deleting anything.
  </p>
  <CodeBlock
    label="Permanently reset Shimpz"
    title="Terminal · destructive reset"
    lines={[{ value: "shimpz reset" }]}
  />
  <p>Reset is complete only when the CLI prints <strong>Shimpz Space was reset successfully</strong>.</p>
</section>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/concepts/"><span>Next</span><strong>Core concepts</strong></a>
</nav>
