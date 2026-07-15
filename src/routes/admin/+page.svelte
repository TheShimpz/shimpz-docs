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

<div class="terminal" role="group" aria-label="Local Shimpz Admin address">
  <div class="terminal-bar">
    <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
    <span>Browser · local Admin</span>
  </div>
  <div class="terminal-command"><span aria-hidden="true">›</span><code>http://127.0.0.1:7777</code></div>
</div>
<p>Create the initial Admin password with at least 12 characters.</p>

<section class="guide-section" aria-labelledby="remote-linux-title">
  <span class="section-label">Remote access</span>
  <h2 id="remote-linux-title">Remote Linux host</h2>
  <p>Keep the Admin private and forward its loopback port over SSH:</p>
  <div class="terminal" role="group" aria-label="Forward a remote Linux Admin over SSH">
    <div class="terminal-bar">
      <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
      <span>Terminal · SSH tunnel</span>
    </div>
    <div class="terminal-command">
      <span aria-hidden="true">$</span><code>ssh -L 7777:127.0.0.1:7777 user@your-server</code>
    </div>
  </div>
  <p>Leave that session open, then visit <code>http://127.0.0.1:7777</code> on your own computer.</p>
</section>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/manage/"><span>Next</span><strong>Update or reset</strong></a>
</nav>
