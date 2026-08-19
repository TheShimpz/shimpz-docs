<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Install Shimpz on Windows — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/install/windows/" />
  <meta
    name="description"
    content="Install stable Shimpz inside Ubuntu on WSL2 with Docker Desktop and systemd."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">Use Shimpz</a><span aria-hidden="true">/</span><span>Installation</span
  ><span aria-hidden="true">/</span><strong>Windows</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Installation guide</span>
  <div class="platform-heading">
    <h1>Install on Windows</h1>
    <span class="platform-status is-supported">WSL2 · x64</span>
  </div>
  <p class="docs-lede">Shimpz runs inside Ubuntu on WSL2 and uses Docker Desktop for its containers and volumes.</p>
</header>

<aside class="scope-note" aria-labelledby="terminal-title">
  <span id="terminal-title" class="kicker">Use the Ubuntu terminal</span>
  <p>Never paste the Shimpz installation command into PowerShell or Command Prompt.</p>
</aside>

<ol class="step-list">
  <li>
    <h2>Install Ubuntu on WSL2</h2>
    <p>Open PowerShell as Administrator:</p>
    <CodeBlock
      label="Install WSL2 and Ubuntu"
      title="PowerShell · Administrator"
      lines={[{ value: "wsl --install -d Ubuntu", prompt: ">" }]}
    />
    <p>Restart if asked, open Ubuntu from the Start menu, and create your Linux username and password.</p>
  </li>

  <li>
    <h2>Require systemd inside WSL2</h2>
    <p>In the Ubuntu terminal, enable systemd:</p>
    <CodeBlock
      label="Enable systemd in Ubuntu on WSL2"
      title="Ubuntu · systemd"
      lines={[{ value: "printf '[boot]\\nsystemd=true\\n' | sudo tee /etc/wsl.conf >/dev/null" }]}
    />
    <p>
      Close Ubuntu, run <code>wsl --shutdown</code> in PowerShell, then reopen Ubuntu. The installer refuses a WSL2
      distribution that does not run systemd as PID 1.
    </p>
  </li>

  <li>
    <h2>Protect Docker data with BitLocker (recommended)</h2>
    <p>
      Enable BitLocker on the Windows volume that contains Docker Desktop's disk image. If you move that disk image,
      protect its new volume too. BitLocker is an operating-system setting: Shimpz does not turn it on or verify it,
      and installation is not blocked when it is off.
    </p>
  </li>

  <li>
    <h2>Connect Docker Desktop</h2>
    <p>
      Install <a
        class="external-link"
        href="https://docs.docker.com/desktop/setup/install/windows-install/"
        target="_blank"
        rel="noopener noreferrer">Docker Desktop for Windows</a
      >. Enable <strong>Use the WSL 2 based engine</strong>, then enable Ubuntu under
      <strong>Settings → Resources → WSL Integration</strong>.
    </p>
    <p>Use a Docker Desktop release that provides Docker Engine 25.0 or newer and Docker Compose 2.20.2 or newer.</p>
    <p>Do not install a second Docker Engine inside Ubuntu.</p>
  </li>

  <li>
    <h2 id="check-docker-title">Check Docker inside Ubuntu</h2>
    <CodeBlock
      label="Check Docker inside Ubuntu"
      title="Ubuntu · Docker check"
      lines={[
        { value: "uname -m" },
        { value: "x86_64", kind: "output" },
        { value: "docker version" },
        { value: "docker compose version" },
      ]}
    />
  </li>

  <li>
    <h2>Install Shimpz inside Ubuntu</h2>
    <CodeBlock
      label="Install Shimpz inside Ubuntu"
      title="Ubuntu · Shimpz install"
      lines={[{ value: "curl -fsSL https://install.shimpz.com | sh" }]}
    />
  </li>

  <li>
    <h2 id="confirm-admin-title">Confirm that Admin opens</h2>
    <p>
      When the installer succeeds, open the exact address it prints in your normal Windows browser. The default is
      <code>http://127.0.0.1:7777</code>; a configured <code>SHIMPZ_PORT</code> changes it. Continue when you see the
      initial password setup or sign-in screen.
    </p>
  </li>
</ol>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/admin/"><span>Next</span><strong>Create your first Team</strong></a>
</nav>
