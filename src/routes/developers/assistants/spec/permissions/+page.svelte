<svelte:head>
  <title>Assistant permissions — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/permissions/" />
  <meta
    name="description"
    content="Declare transparent Assistant network intent while Shimpz keeps every runtime grant controller-owned."
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
    credentials, Services, files, or another Assistant. Its required <code>allowed_hosts</code> list makes
    network intent transparent; it does not grant that access.
  </p>
</header>

<aside class="scope-note" aria-labelledby="permissions-current-title">
  <span id="permissions-current-title" class="kicker">Available today</span>
  <p>
    The reviewed Shimpz Assistant release declares only <code>api.open-meteo.com</code> and
    <code>geocoding-api.open-meteo.com</code>. The Team's authenticated egress proxy blocks every other
    destination. General third-party permission requests are not released in this MVP.
  </p>
</aside>

<section class="guide-section" aria-labelledby="permissions-hosts-title">
  <span class="section-label">Transparent egress</span>
  <h2 id="permissions-hosts-title">List every external host</h2>
  <p>
    <code>allowed_hosts</code> is required at the top level of <code>shimpz.assistant.toml</code>. Use an empty
    array when the Assistant needs no internet. Otherwise, declare at most 32 unique, lowercase, exact public
    DNS hostnames. Do not enter a URL, scheme, port, path, wildcard, IP address, localhost, or internal name.
  </p>
  <p>
    This list gives users and reviewers one clear view of the Assistant's external destinations. It cannot
    expand authority by itself.
  </p>
</section>

<section class="guide-section" aria-labelledby="permissions-flow-title">
  <span class="section-label">Admission flow</span>
  <h2 id="permissions-flow-title">Treat every external capability as a separate decision</h2>
  <ol>
    <li>The creator publishes narrow semantic Powers, closed schemas, and an explicit host allowlist.</li>
    <li>The trusted catalog reviews those exact external destinations.</li>
    <li>The Team owner installs the exact Assistant release.</li>
    <li>
      The controller compares the packaged manifest with the reviewed allowlist and rejects missing,
      malformed, or different values.
    </li>
    <li>An authenticated HTTPS CONNECT proxy allows only the admitted exact hosts and blocks everything else.</li>
    <li>The controller checks target, policy, approval, and schemas again for every Power invocation.</li>
    <li>The Brain receives only the declared Power interface, never the underlying credential or network.</li>
  </ol>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/powers/"><span>Back</span><strong>Powers</strong></a>
  <a href="/developers/assistants/spec/routines/"><span>Next</span><strong>Routines</strong></a>
</nav>
