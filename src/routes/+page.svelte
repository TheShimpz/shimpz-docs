<svelte:head>
  <title>Start with Shimpz — Shimpz docs</title>
  <meta
    name="description"
    content="Install Shimpz, create your first Team, and add an Assistant with a guided local setup."
  />
</svelte:head>

<section id="start" class="docs-hero" aria-labelledby="page-title">
  <div class="terminal-prompt" aria-label="Shimpz quick start">
    <span aria-hidden="true">$</span>
    <span>shimpz start</span>
    <span class="terminal-cursor" aria-hidden="true"></span>
  </div>

  <div class="docs-hero-title">
    <img
      class="docs-hero-mark"
      src="/brand/shimpz-cyberchimp-friendly-v2-144.png"
      srcset="
        /brand/shimpz-cyberchimp-friendly-v2-144.png 1x,
        /brand/shimpz-cyberchimp-friendly-v2-288.png 2x
      "
      alt=""
      width="144"
      height="144"
    />
    <h1 id="page-title">Run your own <span class="gradient-text">Shimpz Space</span>.</h1>
  </div>

  <p class="docs-lede">
    Shimpz runs on your computer with Docker. The installer downloads tested stable images, opens a private
    Admin at <code>127.0.0.1:7777</code>, and guides you through the rest. You do not need to clone code or
    build anything.
  </p>
</section>

<aside class="scope-note" aria-labelledby="before-start-title">
  <span id="before-start-title" class="kicker">Before you start</span>
  <p>
    You need Docker, an OpenAI or Anthropic API key for the Team's Brain, and about ten minutes. If an Assistant
    needs an Account or Secret, Shimpz asks for it only when a Power actually needs it.
  </p>
</aside>

<section class="guide-section" aria-labelledby="choose-system-title">
  <span class="section-label">Step 1</span>
  <h2 id="choose-system-title">Choose your computer</h2>
  <p>Open the guide that matches the computer where Docker will run.</p>

  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/install/linux/">
        <strong>Linux</strong>
        <span>64-bit Intel or AMD · <code>x86_64</code></span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/install/macos/">
        <strong>macOS</strong>
        <span>Apple Silicon · M1 or newer</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/install/windows/">
        <strong>Windows</strong>
        <span>64-bit Windows through Ubuntu on WSL2</span>
      </a>
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="after-install-title">
  <span class="section-label">What happens next</span>
  <h2 id="after-install-title">Three short guided steps</h2>
  <ol>
    <li><strong>Create a Team.</strong> A clean installation will not continue until at least one Team exists.</li>
    <li><strong>Configure its Brain.</strong> Choose a supported model and save your model provider API key.</li>
    <li><strong>Install an Assistant.</strong> Choose one useful capability from the Store and add it to the Team.</li>
  </ol>
</section>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/admin/"><span>Next</span><strong>First access</strong></a>
</nav>
