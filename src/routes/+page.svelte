<svelte:head>
  <title>Install your Shimpz Space — Shimpz docs</title>
  <meta
    name="description"
    content="Choose the Shimpz Space installation guide for Linux amd64, Apple Silicon macOS, or Windows x64 via WSL2."
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
    Choose your computer below. The development installer pulls the prebuilt Admin and local Team
    controller, pins both registry digests, and opens the Admin. It does not clone repositories or build
    Shimpz on your machine.
  </p>
</section>

<aside class="scope-note" aria-labelledby="validated-scope-title">
  <span id="validated-scope-title" class="kicker">Validated scope</span>
  <p>
    This development delivery can create an empty local Team and run provider-backed Team chat with a
    separately configured model API key. Shimpz Assistant connects to X just in time through the official
    X consent page; end users never enter X developer credentials. Commerce remains outside this delivery.
  </p>
</aside>

<section class="guide-section" aria-labelledby="choose-system-title">
  <span class="section-label">Installation guides</span>
  <h2 id="choose-system-title">Choose your computer</h2>
  <p>Open the guide that matches the computer where you want to run Shimpz.</p>

  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/install/linux/">
        <strong>Linux</strong>
        <span>Linux amd64 · Supported</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/install/macos/">
        <strong>macOS</strong>
        <span>Apple Silicon Mac · Supported</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/install/windows/">
        <strong>Windows</strong>
        <span>Windows x64 via WSL2 · Supported</span>
      </a>
    </li>
  </ul>
</section>
