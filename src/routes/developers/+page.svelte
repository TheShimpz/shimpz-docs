<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Build a Shimpz Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/" />
  <meta
    name="description"
    content="Build and test a file-backed Python Assistant with the Shimpz SDK and CLI."
  />
</svelte:head>

<header class="docs-page-header">
  <span class="section-label">Creator path</span>
  <h1>Write Actions, not infrastructure</h1>
  <p class="docs-lede">
    Put identity and Genesis in <code>shimpz.toml</code>. Put each Action in its own Python file.
    The Shimpz CLI validates and tests the project locally without Docker.
  </p>
</header>

<section class="guide-section" aria-labelledby="path-title">
  <span class="section-label">Learning path</span>
  <h2 id="path-title">Run one Action, learn the contract, then publish</h2>
  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/developers/assistants/quickstart/">
        <strong>1. Build your first Assistant</strong>
        <span>Generate a valid starter and run one Action locally without Docker.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/">
        <strong>2. Understand the project structure</strong>
        <span>Use the required actions directory and one async run function per file.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/">
        <strong>3. Read Assistant Spec v1</strong>
        <span>See what belongs in source and what Shimpz generates during pre-build.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/publish/">
        <strong>4. Publish one immutable release</strong>
        <span>Choose its visibility, authorize the exact source, and wait for an installable artifact.</span>
      </a>
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="develop-title">
  <span class="section-label">Optional coding agent</span>
  <h2 id="develop-title">Load the current Shimpz guide into Codex or Claude Code</h2>
  <p>
    Install the coding agent you intend to use, then run one command from the Assistant project. You may also pass
    another Assistant project directory as the final argument.
  </p>
  <CodeBlock
    label="Start Codex in the current Assistant project"
    title="Terminal · Assistant project"
    lines={[{ value: "shimpz develop codex" }]}
  />
  <CodeBlock
    label="Start Claude Code in another Assistant project"
    title="Terminal · Assistant project"
    lines={[{ value: "shimpz develop claude /path/to/assistant" }]}
  />
  <p>
    Shimpz loads the current versioned Assistant development guide and starts the selected agent in that directory.
    By default, the agent keeps its own permission protections. Adding <code>--yolo</code> disables those protections
    and lets the agent run commands with your operating-system user's access.
  </p>
</section>

<section class="guide-section" aria-labelledby="boundary-title">
  <span class="section-label">Trust boundary</span>
  <h2 id="boundary-title">The SDK describes; the Controller decides</h2>
  <ol>
    <li>The SDK derives a machine contract from the files in <code>actions/</code>.</li>
    <li>The platform generates locks and runtime/container artifacts during pre-build.</li>
    <li>The Controller validates the manifest and generated contract without importing source.</li>
    <li>Every input and output is validated again when an Action runs.</li>
  </ol>
</section>

<nav class="docs-page-nav" aria-label="Continue the Creator guide">
  <a href="/developers/assistants/quickstart/"><span>Next</span><strong>Build your first Assistant</strong></a>
</nav>
