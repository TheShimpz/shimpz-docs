<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Maintain your Shimpz Space — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/manage/" />
  <meta name="description" content="Update, stop, resume, or reset a Local Shimpz Space." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">Use Shimpz</a><span aria-hidden="true">/</span><strong>Maintain your Space</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Maintenance</span>
  <h1>Manage the Space with the CLI</h1>
  <p class="docs-lede">
    Use the lifecycle command that matches your intent: reconcile the release, stop workloads without deleting
    data, resume them, or permanently reset the complete Local Space.
  </p>
</header>

<CodeBlock
  label="Update Shimpz"
  title="Terminal · stable update"
  lines={[{ value: "shimpz install" }]}
/>

<p>
  The release-bound CLI checks the replacement before switching to it. If the new version does not become healthy,
  it keeps or restores the previous working version. A successful run reports
  <strong>Shimpz Space is ready</strong> with the local Admin address and the active release.
</p>

<p>
  If the CLI-owned Local Space exists but its current Docker runtime fails validation, the CLI names
  the failure, lists the exact owned scope, and asks whether to remove that corrupt Local state and install a fresh
  Space. <strong>Yes</strong> permanently removes every listed resource and the installed Local state before
  continuing in the same terminal. Any listed Team, Assistant, credential, setting, conversation, or Docker data is
  lost. <strong>No</strong>, Enter, or a non-interactive run leaves it unchanged. This recovery choice is available
  only for a corrupt CLI-owned Space. A running, attested Space requires the Supervisor password after that password
  has been created; before initial setup, Team independently verifies that no Supervisor identity exists and reset
  continues without a password prompt.
</p>

<section class="guide-section" aria-labelledby="stop-title">
  <span class="section-label">Reversible stop</span>
  <h2 id="stop-title">Stop workloads without deleting the Space</h2>
  <p>
    <code>shimpz stop</code> stops the owned Space services and installed Assistant workloads. It keeps every Team,
    Assistant, Integration, setting, conversation, container, network, volume, and release binding. Stopping changes
    only availability, so it does not require the Supervisor password. Automatic maintenance leaves an intentionally
    stopped Space stopped.
  </p>
  <CodeBlock
    label="Stop the Local Space"
    title="Terminal · reversible stop"
    lines={[{ value: "shimpz stop" }, { value: "shimpz status" }]}
  />
  <p>
    The stop is complete when status prints <strong>Shimpz Space is stopped</strong>. Run <code>shimpz start</code>
    to resume the same Space. Start reconciles the current atomic release and restores each valid installed
    Assistant; if local configuration changed while stopped, it is reconciled before workloads start.
  </p>
</section>

<section class="guide-section" aria-labelledby="reset-title">
  <span class="section-label">Permanent removal</span>
  <h2 id="reset-title">Reset only when you want to delete everything</h2>
  <p>
    Reset removes the managed Assistants, Teams, Integrations, Admin state, and local Shimpz data. It cannot be
    undone. Disconnect provider Integrations first when possible. When the owned Admin is running, reset attests its
    loopback listener. If a Supervisor password has been created, reset requires that current password before asking
    Admin to delete domain state. Before initial password setup, Admin and Team verify that no Supervisor identity
    exists and reset continues without asking for one. If no managed runtime remains, the CLI can finish removing
    only the validated scheduler and files, plus any owned Linux encrypted-storage residue, without a password.
    Ambiguous or foreign state inside a Shimpz-owned resource stops reset with an error.
    Unrecognized content outside the owned scope is preserved and listed in the successful
    result. Stopping first does not bypass reset authorization.
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
