<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>First access — Shimpz docs</title>
  <meta name="description" content="Open Shimpz, create your first Team, and configure its Brain." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><strong>First access</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">After installation</span>
  <h1>Create your first Team</h1>
  <p class="docs-lede">
    A Team is your private workspace. It keeps its own conversation, Assistants, Accounts, model settings,
    and files separate from every other Team.
  </p>
</header>

<ol class="step-list">
  <li>
    <h2>Open the local Admin</h2>
    <CodeBlock
      label="Local Shimpz Admin address"
      title="Browser · local Admin"
      lines={[{ value: "http://127.0.0.1:7777", prompt: "›" }]}
    />
    <p>Create the initial Admin password when asked. Use at least 12 characters and do not reuse it elsewhere.</p>
  </li>

  <li>
    <h2>Name the Team</h2>
    <p>
      On a clean installation, Shimpz opens <strong>Create a Team</strong> automatically. Enter a simple name,
      such as <code>Marketing</code>, then choose <strong>Create Team</strong>. You cannot enter chat without a Team.
    </p>
  </li>

  <li>
    <h2>Configure the Brain</h2>
    <p>
      Open the Team's model settings, choose OpenAI or Anthropic and a supported model, then use the key button
      beside the chat composer to save the matching API key. The key is write-only: Shimpz never shows it again.
    </p>
    <p>
      The Brain writes the Team's replies and decides when a Power can help. Do not paste API keys, passwords,
      or OAuth tokens into the message box.
    </p>
  </li>
</ol>

<aside class="scope-note" aria-labelledby="local-safety-title">
  <span id="local-safety-title" class="kicker">Keep it private</span>
  <p>
    Port <code>7777</code> is intentionally available only on this computer. Anyone who controls your operating
    system account or Docker daemon is inside the same trust boundary. Do not expose this port directly to the internet.
  </p>
</aside>

<section class="guide-section" aria-labelledby="remote-access-title">
  <span class="section-label">Optional</span>
  <h2 id="remote-access-title">Open a remote Linux installation safely</h2>
  <p>Forward its private port through SSH, leave the terminal open, and use the same local address in your browser.</p>
  <CodeBlock
    label="Forward a remote Admin through SSH"
    title="Terminal · your computer"
    lines={[{ value: "ssh -L 7777:127.0.0.1:7777 user@your-server" }]}
  />
</section>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/assistants/"><span>Next</span><strong>Install an Assistant</strong></a>
</nav>
