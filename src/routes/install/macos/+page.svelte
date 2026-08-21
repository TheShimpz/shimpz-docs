<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Install Shimpz on macOS — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/install/macos/" />
  <meta name="description" content="Install stable Shimpz on an Apple Silicon Mac with Docker Desktop." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">Use Shimpz</a><span aria-hidden="true">/</span><span>Installation</span
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
    <h2>Protect the Mac with FileVault (recommended)</h2>
    <p>
      In <strong>System Settings → Privacy &amp; Security → FileVault</strong>, turn FileVault on and let encryption
      finish to protect Docker data if the Mac or its disk is stolen. FileVault is an operating-system setting:
      Shimpz does not turn it on or verify it, and installation is not blocked when it is off.
    </p>
  </li>

  <li>
    <h2>Install Docker Desktop</h2>
    <p>
      Install <a
        class="external-link"
        href="https://docs.docker.com/desktop/setup/install/mac-install/"
        target="_blank"
        rel="noopener noreferrer">Docker Desktop for Mac</a
      > with Docker Engine 25.0 or newer and Docker Compose 2.20.2 or newer, open it, and wait until Docker reports
      that it is running.
    </p>
    <p>
      Keep Docker Desktop's <code>desktop-linux</code> context selected. Shimpz uses that managed engine and stops
      safely if another context is active.
    </p>
  </li>

  <li>
    <h2 id="check-docker-title">Check Docker</h2>
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

  <li>
    <h2 id="confirm-admin-title">Confirm that Admin opens</h2>
    <p>
      A successful <code>shimpz install</code> prints the exact local Admin address. Open that address; it is
      <code>http://127.0.0.1:7777</code> when <code>SHIMPZ_PORT</code> was not changed. Continue when you see the
      initial password-and-authenticator setup or sign-in screen.
    </p>
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
  <a href="/admin/"><span>Next</span><strong>Create your first Team</strong></a>
</nav>
