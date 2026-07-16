<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

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
    <p>
      In Docker Desktop, open <strong>Settings → Advanced</strong> and enable
      <a
        class="external-link"
        href="https://docs.docker.com/desktop/settings-and-maintenance/settings/#advanced"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Docker Desktop advanced settings documentation (opens in a new tab)"
        ><strong>Allow the default Docker socket to be used</strong></a
      >. Shimpz checks for <code>/var/run/docker.sock</code> and stops without changing anything when
      that socket is unavailable.
    </p>
    <p>
      During installation, Shimpz first probes Docker Desktop’s
      <a
        class="external-link"
        href="https://docs.docker.com/extensions/extensions-sdk/guides/use-docker-socket-from-backend/"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Docker Desktop VM socket documentation (opens in a new tab)"
        >VM-local socket</a
      >, then uses the default socket only when the same controller image proves it can reach Docker.
      An update stops before replacing the running version when neither path passes this check.
    </p>
    <p>
      Docker Desktop’s Enhanced Container Isolation blocks Docker socket mounts by default. If your
      organization enables it, ask its administrator to
      <a
        class="external-link"
        href="https://docs.docker.com/enterprise/security/hardened-desktop/enhanced-container-isolation/config/"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Docker socket exceptions for Enhanced Container Isolation (opens in a new tab)"
        >allow the verified Shimpz controller image</a
      >; do not weaken an organization policy just to run this evaluation.
    </p>
  </li>

  <li>
    <h2>Check Docker</h2>
    <p>Open the Terminal app and confirm Docker Engine and Docker Compose v2 respond:</p>
    <CodeBlock
      label="Check Docker on macOS"
      title="Terminal · Docker check"
      lines={[{ value: "docker version" }, { value: "docker compose version" }]}
    />
  </li>

  <li>
    <h2>Install Shimpz</h2>
    <p>Paste this command into Terminal and press Return:</p>
    <CodeBlock
      label="Install Shimpz on macOS"
      title="Terminal · Shimpz install"
      lines={[{ value: "curl -fsSL https://install.shimpz.com | sh" }]}
    />
  </li>
</ol>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/admin/"><span>Next</span><strong>Open the Admin</strong></a>
</nav>
