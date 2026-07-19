<svelte:head>
  <title>Assistant permissions — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/permissions/" />
  <meta
    name="description"
    content="Understand how Shimpz keeps network, Service, and Assistant grants outside the creator manifest."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Permissions</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Runtime policy</span>
  <h1>Authority stays outside the manifest.</h1>
  <p class="docs-lede">
    Assistant Spec v2 has no <code>permissions</code> field. A source file cannot grant itself network,
    credentials, Services, files, or another Assistant.
  </p>
</header>

<aside class="scope-note" aria-labelledby="permissions-current-title">
  <span id="permissions-current-title" class="kicker">Available today</span>
  <p>
    The reviewed Shimpz Assistant release is bound to two exact public Open-Meteo hosts through the Team's
    authenticated egress proxy. General third-party permission requests are not released in this MVP.
  </p>
</aside>

<section class="guide-section" aria-labelledby="permissions-flow-title">
  <span class="section-label">Admission flow</span>
  <h2 id="permissions-flow-title">Treat every external capability as a separate decision</h2>
  <ol>
    <li>The creator publishes a narrow semantic Power and closed schemas.</li>
    <li>The trusted catalog reviews and binds any required external interface.</li>
    <li>The Team owner installs the exact Assistant release.</li>
    <li>The controller checks installation, target, policy, approval, and schema for every invocation.</li>
    <li>The Brain receives only the declared Power interface, never the underlying credential or network.</li>
  </ol>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/powers/"><span>Back</span><strong>Powers</strong></a>
  <a href="/developers/assistants/spec/routines/"><span>Next</span><strong>Routines</strong></a>
</nav>
