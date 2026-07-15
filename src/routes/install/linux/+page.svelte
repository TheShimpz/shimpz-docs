<svelte:head>
  <title>Install Shimpz on Linux — Shimpz docs</title>
  <meta
    name="description"
    content="Install the Shimpz Space development channel on a Linux amd64 computer or server."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><span>Installation</span
  ><span aria-hidden="true">/</span><strong>Linux</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Installation guide</span>
  <div class="platform-heading">
    <h1>Install on Linux</h1>
    <span class="platform-status is-supported">Supported · amd64</span>
  </div>
  <p class="docs-lede">
    Follow these steps on a Linux amd64 computer or server. Your user must be allowed to run Docker.
  </p>
</header>

<ol class="step-list">
  <li>
    <h2>Check your processor</h2>
    <p>Open a terminal and run:</p>
    <div class="terminal" role="group" aria-label="Check the Linux processor architecture">
      <div class="terminal-bar">
        <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
        <span>Terminal · Linux</span>
      </div>
      <div class="terminal-command"><span aria-hidden="true">$</span><code>uname -m</code></div>
      <div class="terminal-output"><span aria-hidden="true">›</span><code>x86_64</code></div>
    </div>
    <p>Continue when the result is <code>x86_64</code>.</p>
  </li>

  <li>
    <h2>Install Docker</h2>
    <p>
      Install <a
        class="external-link"
        href="https://docs.docker.com/engine/install/"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Docker Engine installation documentation (opens in a new tab)">Docker Engine</a
      > with Docker Compose v2, then confirm both commands work:
    </p>
    <div class="terminal" role="group" aria-label="Check Docker on Linux">
      <div class="terminal-bar">
        <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
        <span>Terminal · Docker check</span>
      </div>
      <div class="terminal-command"><span aria-hidden="true">$</span><code>docker version</code></div>
      <div class="terminal-command"><span aria-hidden="true">$</span><code>docker compose version</code></div>
    </div>
  </li>

  <li>
    <h2>Install Shimpz</h2>
    <p>Run the installer from the same terminal:</p>
    <div class="terminal" role="group" aria-label="Install Shimpz on Linux">
      <div class="terminal-bar">
        <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
        <span>Terminal · Shimpz install</span>
      </div>
      <div class="terminal-command">
        <span aria-hidden="true">$</span><code>curl -fsSL https://install.shimpz.com | sh</code>
      </div>
    </div>
  </li>
</ol>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/admin/"><span>Next</span><strong>Open the Admin</strong></a>
</nav>
