<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Install Shimpz on Linux — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/install/linux/" />
  <meta
    name="description"
    content="Install the stable Shimpz Space release on a Linux amd64 computer or server."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">Use Shimpz</a><span aria-hidden="true">/</span><span>Installation</span
  ><span aria-hidden="true">/</span><strong>Linux</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Installation guide</span>
  <div class="platform-heading">
    <h1>Install on Linux</h1>
    <span class="platform-status is-supported">Supported · amd64</span>
  </div>
  <p class="docs-lede">
    Follow these steps on a Linux amd64 computer or server. Shimpz encrypts its Local volumes without requiring an
    encrypted host disk.
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
    <h2>Install the storage tools</h2>
    <p>
      Shimpz requires <code>cryptsetup</code> 2.4 or newer to create and verify the LUKS2 volume. On Ubuntu or
      Debian, install the storage tools:
    </p>
    <CodeBlock
      label="Install encrypted storage tools"
      title="Terminal · Ubuntu or Debian"
      lines={[{ value: "sudo apt-get update && sudo apt-get install -y cryptsetup e2fsprogs util-linux" }]}
    />
    <CodeBlock
      label="Check the cryptsetup version"
      title="Terminal · cryptsetup check"
      lines={[
        { value: "cryptsetup --version" },
        { value: "cryptsetup 2.4.3", kind: "output" },
      ]}
    />
    <p>Continue when the version number is 2.4 or newer.</p>
  </li>

  <li>
    <h2 id="check-docker-title">Install Docker</h2>
    <p>
      Install <a
        class="external-link"
        href="https://docs.docker.com/engine/install/"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Docker Engine installation documentation (opens in a new tab)">Docker Engine</a
      > 25.0 or newer with Docker Compose 2.20.2 or newer, then confirm both commands work:
    </p>
    <CodeBlock
      label="Check Docker on Linux"
      title="Terminal · Docker check"
      lines={[{ value: "docker version" }, { value: "docker compose version" }]}
    />
  </li>

  <li>
    <h2>Install Shimpz</h2>
    <p>
      Run the installer from the same terminal. It asks for administrator authorization and then asks you to create
      the passphrase for the encrypted Local volume. Keep that passphrase in your password manager.
    </p>
    <CodeBlock
      label="Install Shimpz on Linux"
      title="Terminal · Shimpz install"
      lines={[{ value: "curl -fsSL https://install.shimpz.com | sh" }]}
    />
  </li>

  <li>
    <h2>Unlock after a restart</h2>
    <p>
      Shimpz never stores the volume passphrase and remains stopped after the host restarts. Run the same install
      command again, enter the existing passphrase, and wait for the success message. Automatic update checks do not
      prompt, use <code>sudo</code>, or start a locked Space.
    </p>
  </li>

  <li>
    <h2 id="confirm-admin-title">Confirm that Admin opens</h2>
    <p>
      A successful installer prints the exact local Admin address. Open that address on the same computer; it is
      <code>http://127.0.0.1:7777</code> when <code>SHIMPZ_PORT</code> was not changed. Continue when you see the
      initial password setup or sign-in screen. For a remote server, use the SSH forwarding instructions on the next
      page.
    </p>
  </li>
</ol>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/admin/"><span>Next</span><strong>Create your first Team</strong></a>
</nav>
