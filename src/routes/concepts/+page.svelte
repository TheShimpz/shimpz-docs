<svelte:head>
  <title>Shimpz glossary — Shimpz docs</title>
  <meta name="description" content="Understand Space, Team, Brain, Assistant, Power, and Account in plain language." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><strong>Simple glossary</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Six useful names</span>
  <h1>Know what owns what</h1>
  <p class="docs-lede">You do not need to understand the internal containers. These six names are enough.</p>
</header>

<dl>
  <dt><strong>Space</strong></dt>
  <dd>Your complete Shimpz installation on one machine.</dd>

  <dt><strong>Team</strong></dt>
  <dd>An isolated workspace with its own chat, Brain settings, Assistants, Accounts, and files.</dd>

  <dt><strong>Brain</strong></dt>
  <dd>The language model that answers as the Team and chooses which available Power can help.</dd>

  <dt><strong>Assistant</strong></dt>
  <dd>A focused capability installed in one Team.</dd>

  <dt><strong>Power</strong></dt>
  <dd>One named, bounded action an Assistant can perform, such as looking up one record.</dd>

  <dt><strong>Account</strong></dt>
  <dd>An OAuth connection you authorize directly with its provider.</dd>
</dl>

<aside class="scope-note" aria-labelledby="infrastructure-title">
  <span id="infrastructure-title" class="kicker">What about PostgreSQL?</span>
  <p>
    PostgreSQL and the internal controllers are platform infrastructure. They are not Accounts, Assistants,
    or Store items, and you do not connect them through OAuth. Shimpz operates them as part of the Space.
  </p>
</aside>

<section class="guide-section" aria-labelledby="flow-title">
  <span class="section-label">One message</span>
  <h2 id="flow-title">How the pieces work together</h2>
  <ol>
    <li>You send a message to a Team.</li>
    <li>Its Brain decides whether an installed Assistant Power is useful.</li>
    <li>The controller checks the Power, Team, Account, scopes, and input.</li>
    <li>The Assistant runs only that Power and returns a validated result.</li>
    <li>The Brain turns the result into the Team's answer.</li>
  </ol>
</section>

<nav class="docs-page-nav" aria-label="Return to the beginning">
  <a href="/"><span>Back to</span><strong>Quick start</strong></a>
</nav>
