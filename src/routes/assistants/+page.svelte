<svelte:head>
  <title>Install your first Assistant — Shimpz docs</title>
  <meta
    name="description"
    content="Create a local Capsule and safely evaluate the free Hello Pulse Assistant from the Shimpz Admin."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><span>Your Space</span
  ><span aria-hidden="true">/</span><strong>First Assistant</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">First local evaluation</span>
  <h1>Install your first Assistant</h1>
  <p class="docs-lede">
    Create an empty Capsule, install Hello Pulse, and run one harmless Power. The Admin keeps the
    destination choice and install authority local; the Store never receives your Admin token or Capsule ID.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-evaluation-scope">
  <span id="assistant-evaluation-scope" class="kicker">Evaluation boundary</span>
  <p>
    Hello Pulse is the only admitted Assistant in this development build. Its immutable image has no
    credentials, mounts, host ports, or general network access, and runs with bounded CPU, memory, and
    processes inside one Capsule network.
  </p>
</aside>

<ol class="step-list">
  <li>
    <h2>Create the Capsule</h2>
    <p>
      Open <a href="http://127.0.0.1:7777" target="_blank" rel="noopener noreferrer">your local Admin</a>,
      sign in, choose <strong>Capsules</strong>, and select <strong>New Capsule</strong>. Give it a name and
      create it. New Capsules start empty.
    </p>
  </li>

  <li>
    <h2>Choose Hello Pulse</h2>
    <p>
      Open <strong>Assistants</strong>. In the Hello Pulse evaluation card, select
      <strong>Install and run hello</strong>. A Store card may open the same local confirmation, but it cannot
      install on its own.
    </p>
  </li>

  <li>
    <h2>Confirm the exact Capsule</h2>
    <p>
      Select the destination Capsule in the local dialog and confirm. The controller admits only the
      published Hello Pulse digest, waits for readiness, and then invokes its declared <code>hello</code>
      Power. A successful response appears in the same card.
    </p>
  </li>

  <li>
    <h2>Remove it cleanly</h2>
    <p>
      Select <strong>Uninstall from Capsule</strong> when you finish evaluating. This removes the Assistant
      container from that Capsule without destroying the Capsule itself.
    </p>
  </li>
</ol>

<section class="guide-section" aria-labelledby="assistant-chat-title">
  <span class="section-label">Chat</span>
  <h2 id="assistant-chat-title">Talk to one installed Assistant</h2>
  <p>
    In <strong>Chat</strong>, choose the Capsule, an installed Assistant, and Claude Code or Codex. The Brain
    is only the inference engine: it follows that Assistant's Rules and may request only its declared,
    controller-validated Powers. It cannot use a shell, create or edit code, execute files, or access the
    network directly.
  </p>
  <p>
    Capsule uploads use isolated opaque storage with an initial total quota of <strong>100 MiB</strong>.
    Files are not mounted or executed. An Assistant can receive content only through an explicit Power
    granted and brokered by the controller.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-failure-title">
  <span class="section-label">If it does not start</span>
  <h2 id="assistant-failure-title">Retry safely</h2>
  <p>
    Use <strong>Install and run hello</strong> again. Installation is idempotent: the controller starts a
    stopped runtime and replaces the stateless Hello Pulse container only when it remains unresponsive. If
    the Admin reports that the local control plane is unavailable, run the install command again to repair
    the managed services without deleting your data.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the user guide">
  <a href="/admin/"><span>Back</span><strong>Open the Admin</strong></a>
  <a href="/manage/"><span>Next</span><strong>Update or reset</strong></a>
</nav>
