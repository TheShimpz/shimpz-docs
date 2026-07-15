<svelte:head>
  <title>Shimpz core concepts — Shimpz docs</title>
  <meta name="description" content="Understand the current Space, Driver, Capsule, and App boundaries." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">User guide</a><span aria-hidden="true">/</span><span>Reference</span
  ><span aria-hidden="true">/</span><strong>Core concepts</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Reference</span>
  <h1>Know the boundaries</h1>
</header>

<ul>
  <li><strong>Space</strong> is the Shimpz installation owned by this machine.</li>
  <li><strong>Driver</strong> is a Space-wide service available to authorized Apps across its Capsules.</li>
  <li><strong>Capsule</strong> is an isolated environment inside the Space.</li>
  <li>
    <strong>App</strong> belongs to exactly one Capsule. Apps can communicate only inside that same Capsule
    and can use Drivers exposed by their Space.
  </li>
</ul>

<nav class="docs-page-nav" aria-label="Return to the beginning">
  <a href="/"><span>Back to</span><strong>Overview</strong></a>
</nav>
