<svelte:head>
  <title>Install Shimpz on Linux or macOS — Shimpz docs</title>
  <meta
    name="description"
    content="A beginner-friendly guide to installing the Shimpz Space development channel on Linux amd64 or Apple Silicon macOS."
  />
</svelte:head>

<section id="start" class="docs-hero" aria-labelledby="page-title">
  <div class="terminal-prompt" aria-label="Shimpz User installation guide">
    <span aria-hidden="true">$</span>
    <span>shimpz docs --user</span>
    <span class="terminal-cursor" aria-hidden="true"></span>
  </div>

  <div class="docs-hero-title">
    <img
      class="docs-hero-mark"
      src="/brand/shimpz-cyberchimp-friendly-v2.png"
      alt=""
      width="1254"
      height="1254"
    />
    <h1 id="page-title">Install your <span class="gradient-text">Shimpz Space</span>.</h1>
  </div>

  <p class="docs-lede">
    Choose your computer below. The development installer pulls one prebuilt image, pins its registry
    digest, and opens the local Admin. It does not clone repositories or build Shimpz on your machine.
  </p>
</section>

<aside class="scope-note" aria-labelledby="validated-scope-title">
  <span id="validated-scope-title" class="kicker">Validated scope</span>
  <p>
    This initial delivery boots only the Admin. It does not install or advertise a Driver, Capsule, or
    App package.
  </p>
</aside>

<section id="linux" class="platform-section" aria-labelledby="linux-title">
  <header class="platform-heading">
    <div class="platform-title">
      <span class="platform-index" aria-hidden="true">01</span>
      <h2 id="linux-title">Linux</h2>
    </div>
    <span class="platform-status is-supported">Supported · amd64</span>
  </header>

  <p class="section-intro">
    Follow these steps on a Linux amd64 computer or server. Your user must be allowed to run Docker.
  </p>

  <ol class="step-list">
    <li>
      <h3>Check your processor</h3>
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
      <h3>Install Docker</h3>
      <p>
        Install <a href="https://docs.docker.com/engine/install/">Docker Engine</a> with Docker Compose
        v2, then confirm both commands work:
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
      <h3>Install Shimpz</h3>
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
</section>

<section id="macos" class="platform-section" aria-labelledby="macos-title">
  <header class="platform-heading">
    <div class="platform-title">
      <span class="platform-index" aria-hidden="true">02</span>
      <h2 id="macos-title">macOS</h2>
    </div>
    <span class="platform-status is-supported">Supported · Apple Silicon</span>
  </header>

  <p class="section-intro">
    Use these steps on an Apple Silicon Mac. From the Apple menu, open <strong>About This Mac</strong>
    and confirm that the Chip name begins with Apple.
  </p>

  <ol class="step-list">
    <li>
      <h3>Install Docker Desktop</h3>
      <p>
        Install <a href="https://docs.docker.com/desktop/setup/install/mac-install/">Docker Desktop on macOS</a>.
        Open it and wait until Docker reports that it is running.
      </p>
    </li>

    <li>
      <h3>Check Docker</h3>
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
      <h3>Install Shimpz</h3>
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
</section>

<section id="windows" class="platform-section" aria-labelledby="windows-title">
  <header class="platform-heading">
    <div class="platform-title">
      <span class="platform-index" aria-hidden="true">03</span>
      <h2 id="windows-title">Windows</h2>
    </div>
    <span class="platform-status is-unsupported">Unsupported</span>
  </header>

  <div class="unsupported-note">
    <span class="kicker">Choose a supported computer</span>
    <p>
      The development installer does not support Windows or WSL. Do not paste the shell command into
      PowerShell or Command Prompt. Use a Linux amd64 computer or an Apple Silicon Mac.
    </p>
  </div>
</section>

<section id="admin" class="guide-section" aria-labelledby="admin-title">
  <span class="section-label">After installation</span>
  <h2 id="admin-title">Open the Admin</h2>
  <p>
    The installer keeps private state in <code>$HOME/.shimpz</code>, publishes the Admin only on host
    loopback, and waits for its health check before reporting success.
  </p>
  <div class="terminal" role="group" aria-label="Local Shimpz Admin address">
    <div class="terminal-bar">
      <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
      <span>Browser · local Admin</span>
    </div>
    <div class="terminal-command"><span aria-hidden="true">›</span><code>http://127.0.0.1:7777</code></div>
  </div>
  <p>Create the initial Admin password with at least 12 characters.</p>

  <h3>Remote Linux host</h3>
  <p>Keep the Admin private and forward its loopback port over SSH:</p>
  <div class="terminal" role="group" aria-label="Forward a remote Linux Admin over SSH">
    <div class="terminal-bar">
      <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
      <span>Terminal · SSH tunnel</span>
    </div>
    <div class="terminal-command">
      <span aria-hidden="true">$</span><code>ssh -L 7777:127.0.0.1:7777 user@your-server</code>
    </div>
  </div>
  <p>Leave that session open, then visit <code>http://127.0.0.1:7777</code> on your own computer.</p>
</section>

<section id="manage" class="guide-section" aria-labelledby="manage-title">
  <span class="section-label">Keep it current</span>
  <h2 id="manage-title">Update or reset</h2>
  <p>
    Run the install command again to pull the current development image. The installer keeps the
    previous digest and restores it when the replacement does not become healthy.
  </p>
  <p>Reset stops the managed Space and permanently removes its local Admin data:</p>
  <div class="terminal" role="group" aria-label="Reset the Shimpz installation">
    <div class="terminal-bar">
      <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
      <span>Terminal · Shimpz reset</span>
    </div>
    <div class="terminal-command">
      <span aria-hidden="true">$</span><code>curl -fsSL https://install.shimpz.com | sh -s -- --reset</code>
    </div>
  </div>
</section>

<section id="boundaries" class="guide-section" aria-labelledby="boundaries-title">
  <span class="section-label">Reference</span>
  <h2 id="boundaries-title">Know the boundaries</h2>
  <ul>
    <li><strong>Space</strong> is the Shimpz installation owned by this machine.</li>
    <li><strong>Driver</strong> is a Space-wide service available to authorized Apps across its Capsules.</li>
    <li><strong>Capsule</strong> is an isolated environment inside the Space.</li>
    <li>
      <strong>App</strong> belongs to exactly one Capsule. Apps can communicate only inside that same Capsule
      and can use Drivers exposed by their Space.
    </li>
  </ul>
</section>
