<svelte:head>
  <title>Connect Cloudflare — Shimpz docs</title>
  <meta
    name="description"
    content="Install Shimpz Cloudflare, authorize its read-only Account, and list zones and DNS records."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><strong>Connect Cloudflare</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">First useful result</span>
  <h1>Read Cloudflare from chat</h1>
  <p class="docs-lede">
    Shimpz Cloudflare can list your zones and their DNS records. It is read-only and requests access only when
    the first message needs it.
  </p>
</header>

<aside class="scope-note" aria-labelledby="safe-account-title">
  <span id="safe-account-title" class="kicker">No token copy and paste</span>
  <p>
    Cloudflare authorization happens on Cloudflare's website. Shimpz never asks you to paste an API token,
    client secret, or password into the Admin or chat.
  </p>
</aside>

<ol class="step-list">
  <li>
    <h2>Install the Assistant</h2>
    <p>
      Open <strong>Assistants</strong>, confirm the Team shown under <strong>Installation destination</strong>,
      open <strong>Shimpz Cloudflare</strong>, and choose <strong>Install</strong>. Wait until it is ready.
    </p>
  </li>

  <li>
    <h2>Ask for your zones</h2>
    <p>Open <strong>Chat</strong> and send this first message:</p>
    <blockquote>List my Cloudflare zones.</blockquote>
    <p>The turn pauses and shows the exact Account and permissions it needs.</p>
  </li>

  <li>
    <h2>Authorize on Cloudflare</h2>
    <p>
      Choose <strong>Continue to Cloudflare</strong>, select the Cloudflare account, review the read scopes,
      and approve. After Cloudflare returns you to Shimpz, the same conversation continues automatically.
    </p>
  </li>

  <li>
    <h2>Inspect DNS</h2>
    <p>Use the name returned in the first answer:</p>
    <blockquote>List the DNS records for example.com.</blockquote>
    <p>
      Results should appear as a readable table. The Assistant receives a bounded access token only while its
      Power runs; the Brain, browser, and chat response never receive that token.
    </p>
  </li>
</ol>

<section class="guide-section" aria-labelledby="problems-title">
  <span class="section-label">If something does not work</span>
  <h2 id="problems-title">Check the visible state first</h2>
  <ul>
    <li><strong>No Assistant in chat:</strong> return to Assistants and confirm it is installed in this Team.</li>
    <li><strong>No authorization window:</strong> allow pop-ups for the local Admin and send the message again.</li>
    <li><strong>Wrong Cloudflare account:</strong> disconnect the Account, then authorize the correct one.</li>
    <li><strong>Model keeps thinking:</strong> verify the Team's model API key, then retry the message once.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="disconnect-title">
  <span class="section-label">Remove access</span>
  <h2 id="disconnect-title">Disconnect before uninstalling</h2>
  <p>
    Disconnect the Cloudflare Account to revoke its grant, then uninstall Shimpz Cloudflare from the Team.
    Uninstalling the Assistant does not delete the Team or its conversation history.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the user guide">
  <a href="/admin/"><span>Back</span><strong>First access</strong></a>
  <a href="/manage/"><span>Next</span><strong>Update or remove</strong></a>
</nav>
