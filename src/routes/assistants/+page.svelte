<svelte:head>
  <title>Add an Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/assistants/" />
  <meta
    name="description"
    content="Install an Assistant and provide an Integration or private input only when an Action requires it."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">Use Shimpz</a><span aria-hidden="true">/</span><strong>Add an Assistant</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">First useful result</span>
  <h1>Add one capability to your Team</h1>
  <p class="docs-lede">
    An Assistant gives the Team one or more focused Actions. Install only the Assistant you need, then ask for
    the result in normal language.
  </p>
</header>

<aside class="scope-note" aria-labelledby="safe-account-title">
  <span id="safe-account-title" class="kicker">No token copy and paste</span>
  <p>
    OAuth authorization happens on the provider's own website. Shimpz never asks you to paste an OAuth client
    secret, authorization code, access token, or refresh token into chat. A custom HTTPS Admin may ask for the
    short-lived Shimpz completion code in its dedicated authorization dialog; that code belongs only in the original
    authenticated Admin tab.
  </p>
</aside>

<ol class="step-list">
  <li>
    <h2>Install the Assistant</h2>
    <p>
      Open <strong>Assistants</strong>, confirm the Team shown under <strong>Installation destination</strong>,
      open the Assistant you want, and choose <strong>Install</strong>. Continue when Admin reports
      <strong>Assistant installed</strong> and the Assistant remains available for that Team.
    </p>
  </li>

  <li>
    <h2>Ask for one useful result</h2>
    <p>
      On the Assistant page, choose one declared Action that matches your goal. Open <strong>Chat</strong> and ask for
      that outcome in normal language. For example, a DNS Assistant might receive:
    </p>
    <blockquote>Use the installed DNS Assistant to list the zones I can access.</blockquote>
    <p>If private access is necessary, the turn pauses and shows the exact requirement.</p>
  </li>

  <li>
    <h2>Provide only what the Action requests</h2>
    <p>
      If an Integration is required, choose <strong>Continue</strong>, review the provider and scopes, and approve on
      the provider's website. If a third-party private value is required, Shimpz shows one bounded request form.
      The same conversation continues after the requirement is satisfied.
    </p>
  </li>

  <li>
    <h2>Confirm the result, then ask a follow-up</h2>
    <p>
      The turn is complete when Chat shows the Team's complete response with no human request still pending. If the
      response contains a list or table, choose one returned value for a follow-up:
    </p>
    <blockquote>Show me more details about the first result.</blockquote>
    <p>
      Private values are submitted from the dedicated form only to the exact selected Action. Shimpz does not add
      them to the Brain context, chat transcript, or chat response.
    </p>
  </li>
</ol>

<section class="guide-section" aria-labelledby="automatic-updates-title">
  <span class="section-label">Automatic maintenance</span>
  <h2 id="automatic-updates-title">Local keeps installed Assistants current</h2>
  <p>
    When a newer reviewed publication is available, Local verifies its exact immutable image and updates every Team
    using the older version. The current Assistant stays available if Shimpz is offline, the Team is busy, or the
    replacement cannot be proved safe; Shimpz retries later.
  </p>
  <p>
    An update can remove permissions automatically, but it cannot silently add a network host, Integration, provider,
    or OAuth scope. Broader access requires your approval. After a successful replacement, Shimpz removes the old
    Assistant container and its unused image and policy state without pruning unrelated Docker data.
  </p>
  <p>
    Blocking a publication prevents new installations but does not remotely stop a copy that is already running in
    your Local Space. If a security notice requires immediate removal, the Local Supervisor must uninstall that
    Assistant instead of waiting for a newer safe version.
  </p>
</section>

<section class="guide-section" aria-labelledby="problems-title">
  <span class="section-label">If something does not work</span>
  <h2 id="problems-title">Check the visible state first</h2>
  <ul>
    <li><strong>No Assistant in chat:</strong> return to Assistants and confirm it is installed in this Team.</li>
    <li><strong>No authorization window:</strong> allow pop-ups for the local Admin and send the message again.</li>
    <li><strong>Wrong Integration:</strong> disconnect it, then authorize the correct provider identity.</li>
    <li><strong>Model keeps thinking:</strong> verify the Team's model API key, then retry the message once.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="disconnect-title">
  <span class="section-label">Remove access</span>
  <h2 id="disconnect-title">Disconnect before uninstalling</h2>
  <p>
    Disconnect any Integration to revoke its provider grant, then uninstall the Assistant. Third-party password
    input is memory-only and is never a configured value to remove. Uninstalling the Assistant does not delete the
    Team or its conversation history.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the user guide">
  <a href="/admin/"><span>Back</span><strong>Create your first Team</strong></a>
  <a href="/manage/"><span>Next</span><strong>Maintain your Space</strong></a>
</nav>
