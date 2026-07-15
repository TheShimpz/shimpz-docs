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
    Run the install command again to pull the current development image. The installer keeps the
    previous digest and restores it when the replacement does not become healthy.
  </p>
</header>

<p>Reset stops the managed Space and permanently removes its local Admin data:</p>
<div class="terminal" role="group" aria-label="Reset the Shimpz installation">
  <div class="terminal-bar">
    <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
    <span>Terminal · Shimpz reset</span>
  </div>
  <div class="terminal-command">
    <span aria-hidden="true">$</span><code>curl -fsSL https://install.shimpz.com | sh -s -- --reset</code>
  </div>
</div>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/concepts/"><span>Next</span><strong>Core concepts</strong></a>
</nav>
