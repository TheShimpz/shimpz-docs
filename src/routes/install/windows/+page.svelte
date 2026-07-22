<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Install Shimpz on Windows — Shimpz docs</title>
  <meta name="description" content="Install stable Shimpz inside Ubuntu on WSL2 with Docker Desktop." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><span>Installation</span
  ><span aria-hidden="true">/</span><strong>Windows</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Installation guide</span>
  <div class="platform-heading">
    <h1>Install on Windows</h1>
    <span class="platform-status is-supported">WSL2 · x64</span>
  </div>
  <p class="docs-lede">
    Shimpz runs inside Ubuntu on WSL2. PowerShell installs WSL; the Ubuntu terminal runs Docker and Shimpz.
  </p>
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
    <p>Do not install a second Docker Engine inside Ubuntu.</p>
  </li>

  <li>
    <h2>Check Docker inside Ubuntu</h2>
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
    <p>When it finishes, open <code>http://127.0.0.1:7777</code> in your normal Windows browser.</p>
  </li>
</ol>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/admin/"><span>Next</span><strong>First access</strong></a>
</nav>
