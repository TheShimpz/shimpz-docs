<svelte:head>
  <title>Install Shimpz on macOS — Shimpz docs</title>
  <meta
    name="description"
    content="Install the Shimpz Space development channel on an Apple Silicon Mac."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><span>Installation</span
  ><span aria-hidden="true">/</span><strong>macOS</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Installation guide</span>
  <div class="platform-heading">
    <h1>Install on macOS</h1>
    <span class="platform-status is-supported">Supported · Apple Silicon</span>
  </div>
  <p class="docs-lede">
    Use these steps on an Apple Silicon Mac. From the Apple menu, open <strong>About This Mac</strong>
    and confirm that the Chip name begins with Apple.
  </p>
</header>

<ol class="step-list">
  <li>
    <h2>Install Docker Desktop</h2>
    <p>
      Install <a
        class="external-link"
        href="https://docs.docker.com/desktop/setup/install/mac-install/"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Docker Desktop for Mac installation documentation (opens in a new tab)"
        >Docker Desktop on macOS</a
      >. Open it and wait until Docker reports that it is running.
    </p>
  </li>

  <li>
    <h2>Check Docker</h2>
    <p>Open the Terminal app and confirm Docker Engine and Docker Compose v2 respond:</p>
    <div class="terminal" role="group" aria-label="Check Docker on macOS">
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
    <p>Paste this command into Terminal and press Return:</p>
    <div class="terminal" role="group" aria-label="Install Shimpz on macOS">
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
