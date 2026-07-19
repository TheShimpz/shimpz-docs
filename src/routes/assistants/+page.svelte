<svelte:head>
  <title>Install your first Assistant — Shimpz docs</title>
  <meta
    name="description"
    content="Create a local Team, install Shimpz Assistant, and chat with the Team from the Shimpz Admin."
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
    Create an empty Team and install Shimpz Assistant. The Admin keeps the destination choice and install
    authority local; the Store never receives your Admin token or internal Team identifier.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-evaluation-scope">
  <span id="assistant-evaluation-scope" class="kicker">Evaluation boundary</span>
  <p>
    Shimpz Assistant is the only admitted Assistant in this development build. Its immutable image has no
    credentials, mounts, host ports, or general network access. Weather requests can reach only the two
    declared Open-Meteo hosts through the authenticated egress proxy.
  </p>
</aside>

<ol class="step-list">
  <li>
    <h2>Create the Team</h2>
    <p>
      Open <a href="http://127.0.0.1:7777" target="_blank" rel="noopener noreferrer">your local Admin</a>,
      sign in, choose <strong>Teams</strong>, and select <strong>New Team</strong>. Give it a name and create
      it. New Teams start empty.
    </p>
  </li>

  <li>
    <h2>Choose Shimpz Assistant</h2>
    <p>
      Open <strong>Assistants</strong>. In the Shimpz Assistant card, select
      <strong>Install</strong>. A Store card may open the same local confirmation, but it cannot install on
      its own.
    </p>
  </li>

  <li>
    <h2>Confirm the exact Team</h2>
    <p>
      Select the destination Team in the local dialog and confirm. The controller admits only the published
      Shimpz Assistant digest and waits for readiness. Installation does not invoke a Power or start a chat turn;
      the Store marks the Assistant as installed when it is ready.
    </p>
  </li>

  <li>
    <h2>Remove it cleanly</h2>
    <p>
      Select <strong>Uninstall</strong> when you finish evaluating. This removes the Assistant container from
      that Team without destroying the Team itself.
    </p>
  </li>
</ol>

<section class="guide-section" aria-labelledby="assistant-help-title">
  <span class="section-label">First prompt</span>
  <h2 id="assistant-help-title">Open the built-in help</h2>
  <p>
    Go to the Team chat and select the <strong>?</strong> button beside <strong>Send</strong>. The right sidebar
    displays the installed Assistant's <code>HELP.md</code> with short examples. Try “What is the weather in
    Lisbon right now?” or ask for a five-day forecast in your city.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-chat-title">
  <span class="section-label">Chat</span>
  <h2 id="assistant-chat-title">Talk to your Team</h2>
  <p>
    In <strong>Chat</strong>, choose the Team and its configured OpenAI or Anthropic model. You do not select
    an Assistant as the speaker: replies use the Team's name. The provider-neutral LangGraph Brain receives
    the validated Rules and Powers of every installed, available Assistant in that Team. It can answer
    naturally or request a sequence of Powers, but the controller is the only component allowed to validate
    and execute each request.
  </p>
  <p>
    Configure the selected provider with an API key in the authenticated Admin. The secret is never returned
    by status APIs, stored in browser storage, or exposed to an Assistant. The Brain receives it only in
    memory for the provider request. It has no ambient shell, filesystem, general network access, code tools,
    or package managers.
  </p>
  <p>
    Team uploads use isolated opaque storage with an initial total quota of <strong>100 MiB</strong>.
    Files are not mounted or executed. An Assistant can receive content only through an explicit Power
    granted and brokered by the controller.
  </p>
  <p>
    Power traces are operational evidence, not a public chat feature. The interface returns the Team's
    reply without exposing internal prompts, Rules, Power inputs or outputs, file contents, or secrets.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-failure-title">
  <span class="section-label">If it does not start</span>
  <h2 id="assistant-failure-title">Retry safely</h2>
  <p>
    Use <strong>Install</strong> again. Installation is idempotent: the controller starts a
    stopped runtime and replaces the stateless Shimpz Assistant container only when it remains unresponsive. If
    the Admin reports that the local control plane is unavailable, run the install command again to repair
    the managed services without deleting your data.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the user guide">
  <a href="/admin/"><span>Back</span><strong>Open the Admin</strong></a>
  <a href="/manage/"><span>Next</span><strong>Update or reset</strong></a>
</nav>
