<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Install Shimpz on Windows with WSL2 — Shimpz docs</title>
  <meta
    name="description"
    content="Install the stable Shimpz Space release on Windows x64 through Ubuntu on WSL2."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><span>Installation</span
  ><span aria-hidden="true">/</span><strong>Windows</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Installation guide</span>
  <div class="platform-heading">
    <h1>Install on Windows</h1>
    <span class="platform-status is-supported">Supported · WSL2 x64</span>
  </div>
  <p class="docs-lede">
    Shimpz runs in Ubuntu on WSL2, not directly in Windows. PowerShell installs and checks WSL;
    every Shimpz and Docker command runs inside the Ubuntu terminal.
  </p>
</header>

<aside class="scope-note" aria-labelledby="windows-shell-title">
  <span id="windows-shell-title" class="kicker">Use the right terminal</span>
  <p>
    Never paste the Shimpz shell installer into PowerShell or Command Prompt. Open <strong>Ubuntu</strong>
    from the Windows Start menu before running it.
  </p>
</aside>

<ol class="step-list">
  <li>
    <h2>Check your computer</h2>
    <p>
      Use Windows on an x64-based processor. Windows 11 is recommended; Windows 10 must meet the current
      <a
        class="external-link"
        href="https://learn.microsoft.com/en-us/windows/wsl/install"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Microsoft WSL installation requirements (opens in a new tab)">Microsoft WSL requirements</a
      > and Docker Desktop requirements.
    </p>
  </li>

  <li>
    <h2>Install WSL2 and Ubuntu</h2>
    <p>Open PowerShell as Administrator and run:</p>
    <CodeBlock
      label="Install WSL2 and Ubuntu from administrator PowerShell"
      title="PowerShell · Administrator"
      lines={[{ value: "wsl --install -d Ubuntu", prompt: ">" }]}
    />
    <p>Restart Windows if asked, open Ubuntu from the Start menu, and create your Linux username and password.</p>
    <p>Back in PowerShell, confirm that Ubuntu uses WSL version 2:</p>
    <CodeBlock
      label="Check the installed WSL version"
      title="PowerShell · WSL check"
      lines={[{ value: "wsl --list --verbose", prompt: ">" }]}
    />
    <p>If Ubuntu shows version 1, convert it before continuing:</p>
    <CodeBlock
      label="Convert Ubuntu to WSL2"
      title="PowerShell · WSL upgrade"
      lines={[{ value: "wsl --set-version Ubuntu 2", prompt: ">" }]}
    />
  </li>

  <li>
    <h2>Connect Docker Desktop to Ubuntu</h2>
    <p>
      Install <a
        class="external-link"
        href="https://docs.docker.com/desktop/setup/install/windows-install/"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Docker Desktop for Windows installation documentation (opens in a new tab)"
        >Docker Desktop for Windows</a
      > and start it. In Docker Desktop, enable <strong>Use the WSL 2 based engine</strong>, then open
      <strong>Settings → Resources → WSL Integration</strong>, enable Ubuntu, and apply the change.
    </p>
    <p>
      Do not install a second Docker Engine inside Ubuntu; use the Docker Desktop WSL integration.
      The detailed flow is documented in Docker's
      <a
        class="external-link"
        href="https://docs.docker.com/desktop/features/wsl/"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Docker Desktop WSL2 backend documentation (opens in a new tab)">WSL2 backend guide</a
      >.
    </p>
  </li>

  <li>
    <h2>Check Ubuntu and Docker</h2>
    <p>Open the Ubuntu terminal. First confirm that WSL reports the supported x64 architecture:</p>
    <CodeBlock
      label="Check the WSL2 Ubuntu processor architecture"
      title="Ubuntu · Processor check"
      lines={[{ value: "uname -m" }, { value: "x86_64", kind: "output" }]}
    />
    <p>Continue only when the result is <code>x86_64</code>, then check the Docker integration:</p>
    <CodeBlock
      label="Check Docker inside WSL2 Ubuntu"
      title="Ubuntu · Docker check"
      lines={[{ value: "docker version" }, { value: "docker compose version" }]}
    />
  </li>

  <li>
    <h2>Install Shimpz inside Ubuntu</h2>
    <p>Keep using the Ubuntu terminal and run:</p>
    <CodeBlock
      label="Install Shimpz inside WSL2 Ubuntu"
      title="Ubuntu · Shimpz install"
      lines={[{ value: "curl -fsSL https://install.shimpz.com | sh" }]}
    />
  </li>

  <li>
    <h2>Open the Admin from Windows</h2>
    <p>After the installer reports success, open this address in your Windows browser:</p>
    <CodeBlock
      label="Open the local Shimpz Admin from Windows"
      title="Browser · local Admin"
      lines={[{ value: "http://127.0.0.1:7777", prompt: "›" }]}
    />
  </li>
</ol>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/admin/"><span>Next</span><strong>Open the Admin</strong></a>
</nav>
