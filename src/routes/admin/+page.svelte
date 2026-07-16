<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Open the Shimpz Admin — Shimpz docs</title>
  <meta name="description" content="Open the local Shimpz Admin after installing your Space." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><span>Your Space</span
  ><span aria-hidden="true">/</span><strong>Open the Admin</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">After installation</span>
  <h1>Open the Admin</h1>
  <p class="docs-lede">
    The installer keeps private state in <code>$HOME/.shimpz</code>, publishes the Admin only on host
    loopback, and waits for its health check before reporting success.
  </p>
</header>

<aside class="scope-note" aria-labelledby="local-trust-boundary">
  <span id="local-trust-boundary" class="kicker">Single-owner local profile</span>
  <p>
    Use this development build only on a personal or otherwise trusted host. Anyone who controls your
    operating-system account or Docker daemon is inside the same trust boundary. Keep port
    <code>7777</code> on loopback and create the Admin password immediately after installation.
  </p>
</aside>

<CodeBlock
  label="Local Shimpz Admin address"
  title="Browser · local Admin"
  lines={[{ value: "http://127.0.0.1:7777", prompt: "›" }]}
/>
<p>Create the initial Admin password with at least 12 characters.</p>

<section class="guide-section" aria-labelledby="remote-linux-title">
  <span class="section-label">Remote access</span>
  <h2 id="remote-linux-title">Remote Linux host</h2>
  <p>Keep the Admin private and forward its loopback port over SSH:</p>
  <CodeBlock
    label="Forward a remote Linux Admin over SSH"
    title="Terminal · SSH tunnel"
    lines={[{ value: "ssh -L 7777:127.0.0.1:7777 user@your-server" }]}
  />
  <p>Leave that session open, then visit <code>http://127.0.0.1:7777</code> on your own computer.</p>
</section>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/assistants/"><span>Next</span><strong>Install your first Assistant</strong></a>
</nav>
