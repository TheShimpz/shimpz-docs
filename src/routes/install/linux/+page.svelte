<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Install Shimpz on Linux — Shimpz docs</title>
  <meta
    name="description"
    content="Install the stable Shimpz Space release on a Linux amd64 computer or server."
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
    <CodeBlock
      label="Check the Linux processor architecture"
      title="Terminal · Linux"
      lines={[{ value: "uname -m" }, { value: "x86_64", kind: "output" }]}
    />
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
    <CodeBlock
      label="Check Docker on Linux"
      title="Terminal · Docker check"
      lines={[{ value: "docker version" }, { value: "docker compose version" }]}
    />
  </li>

  <li>
    <h2>Install Shimpz</h2>
    <p>Run the installer from the same terminal:</p>
    <CodeBlock
      label="Install Shimpz on Linux"
      title="Terminal · Shimpz install"
      lines={[{ value: "curl -fsSL https://install.shimpz.com | sh" }]}
    />
  </li>
</ol>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/admin/"><span>Next</span><strong>Open the Admin</strong></a>
</nav>
