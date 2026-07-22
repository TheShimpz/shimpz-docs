<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Install Shimpz on macOS — Shimpz docs</title>
  <meta name="description" content="Install stable Shimpz on an Apple Silicon Mac with Docker Desktop." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><span>Installation</span
  ><span aria-hidden="true">/</span><strong>macOS</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Installation guide</span>
  <div class="platform-heading">
    <h1>Install on macOS</h1>
    <span class="platform-status is-supported">Apple Silicon</span>
  </div>
  <p class="docs-lede">Use an M1 or newer Mac. Docker Desktop must be running before Shimpz starts.</p>
</header>

<ol class="step-list">
  <li>
    <h2>Install Docker Desktop</h2>
    <p>
      Install <a
        class="external-link"
        href="https://docs.docker.com/desktop/setup/install/mac-install/"
        target="_blank"
        rel="noopener noreferrer">Docker Desktop for Mac</a
      >, open it, and wait until Docker reports that it is running.
    </p>
    <p>
      Open <strong>Docker Desktop → Settings → Advanced</strong> and enable
      <strong>Allow the default Docker socket to be used</strong>. Shimpz stops safely if it cannot reach that socket.
    </p>
  </li>

  <li>
    <h2>Check Docker</h2>
    <p>Open Terminal and run both commands:</p>
    <CodeBlock
      label="Check Docker on macOS"
      title="Terminal · Docker check"
      lines={[{ value: "docker version" }, { value: "docker compose version" }]}
    />
  </li>

  <li>
    <h2>Install Shimpz</h2>
    <CodeBlock
      label="Install Shimpz on macOS"
      title="Terminal · Shimpz install"
      lines={[{ value: "curl -fsSL https://install.shimpz.com | sh" }]}
    />
  </li>
</ol>

<aside class="scope-note" aria-labelledby="managed-mac-title">
  <span id="managed-mac-title" class="kicker">Company-managed Mac</span>
  <p>
    Enhanced Container Isolation may block Docker socket access. Ask your administrator to allow the verified
    Shimpz controller image; do not weaken an organization security policy yourself.
  </p>
</aside>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/admin/"><span>Next</span><strong>First access</strong></a>
</nav>
