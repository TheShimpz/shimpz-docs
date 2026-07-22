<svelte:head>
  <title>Install an Assistant — Shimpz docs</title>
  <meta
    name="description"
    content="Install an Assistant and provide an Account or Secret only when a Power requires it."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><strong>Install an Assistant</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">First useful result</span>
  <h1>Add one capability to your Team</h1>
  <p class="docs-lede">
    An Assistant gives the Team one or more focused Powers. Install only the Assistant you need, then ask for
    the result in normal language.
  </p>
</header>

<aside class="scope-note" aria-labelledby="safe-account-title">
  <span id="safe-account-title" class="kicker">No token copy and paste</span>
  <p>
    OAuth authorization happens on the provider's own website. Shimpz never asks you to paste an OAuth client
    secret, authorization code, access token, or refresh token into chat.
  </p>
</aside>

<ol class="step-list">
  <li>
    <h2>Install the Assistant</h2>
    <p>
      Open <strong>Assistants</strong>, confirm the Team shown under <strong>Installation destination</strong>,
      open the Assistant you want, and choose <strong>Install</strong>. Wait until it is ready.
    </p>
  </li>

  <li>
    <h2>Ask for one useful result</h2>
    <p>Open <strong>Chat</strong> and send this first message:</p>
    <blockquote>Use the installed Assistant to show me what it can read.</blockquote>
    <p>If private access is necessary, the turn pauses and shows the exact requirement.</p>
  </li>

  <li>
    <h2>Provide only what the Power requests</h2>
    <p>
      If an Account is required, choose <strong>Continue</strong>, review the provider and scopes, and approve on
      the provider's website. If a Secret is required, Shimpz shows its name and purpose in a private form.
      The same conversation continues after the requirement is satisfied.
    </p>
  </li>

  <li>
    <h2>Ask a follow-up</h2>
    <p>Use a value returned in the first answer:</p>
    <blockquote>Show me more details about the first result.</blockquote>
    <p>
      Tabular results should appear as a readable table. Private values reach only the selected Power; the Brain,
      browser, and chat response never receive them.
    </p>
  </li>
</ol>

<section class="guide-section" aria-labelledby="problems-title">
  <span class="section-label">If something does not work</span>
  <h2 id="problems-title">Check the visible state first</h2>
  <ul>
    <li><strong>No Assistant in chat:</strong> return to Assistants and confirm it is installed in this Team.</li>
    <li><strong>No authorization window:</strong> allow pop-ups for the local Admin and send the message again.</li>
    <li><strong>Wrong provider account:</strong> disconnect the Account, then authorize the correct one.</li>
    <li><strong>Model keeps thinking:</strong> verify the Team's model API key, then retry the message once.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="disconnect-title">
  <span class="section-label">Remove access</span>
  <h2 id="disconnect-title">Disconnect before uninstalling</h2>
  <p>
    Disconnect any Account to revoke its grant, remove configured Secrets, then uninstall the Assistant.
    Uninstalling the Assistant does not delete the Team or its conversation history.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the user guide">
  <a href="/admin/"><span>Back</span><strong>First access</strong></a>
  <a href="/manage/"><span>Next</span><strong>Update or remove</strong></a>
</nav>
