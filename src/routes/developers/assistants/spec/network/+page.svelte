<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Assistant network access — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/network/" />
  <meta name="description" content="Declare exact public hosts with the Assistant allowed_hosts field." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant SPEC</a><span aria-hidden="true">/</span>
  <strong>Network access</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Baby step 8</span>
  <h1>List exact destinations, not “the internet”</h1>
  <p class="docs-lede">
    <code>allowed_hosts</code> makes external network intent visible and reviewable. It is required even when
    empty, and it never grants access by itself.
  </p>
</header>

<section class="guide-section" aria-labelledby="none-title">
  <span class="section-label">No external API</span>
  <h2 id="none-title">Prefer an empty list</h2>
  <CodeBlock
    label="No requested network access"
    title="shimpz.assistant.toml"
    lines={[{ value: "allowed_hosts = []" }]}
  />
  <p>If all Powers work from their inputs and private envelopes, the Assistant does not need an external host.</p>
</section>

<section class="guide-section" aria-labelledby="host-title">
  <span class="section-label">One external API</span>
  <h2 id="host-title">Write only the public DNS hostname</h2>
  <CodeBlock
    label="One requested API host"
    title="shimpz.assistant.toml"
    lines={[{ value: 'allowed_hosts = ["api.open-meteo.com"]' }]}
  />
  <p>
    Do not include <code>https://</code>, a port, path, query, fragment, wildcard, or trailing slash. A second
    API hostname is a second explicit list item.
  </p>
</section>

<section class="guide-section" aria-labelledby="rules-title">
  <span class="section-label">Host rules</span>
  <h2 id="rules-title">Every entry must be exact and public</h2>
  <ul>
    <li>Lowercase DNS hostname only, at most 253 characters.</li>
    <li>At most 32 unique hosts per Assistant.</li>
    <li>No IP addresses, single-label names, wildcards, URLs, or localhost.</li>
    <li>No reserved internal or test suffixes such as <code>.local</code>, <code>.internal</code>, or <code>.test</code>.</li>
    <li>Redirects do not silently expand the list; the final host must also be declared and admitted.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="intent-title">
  <span id="intent-title" class="kicker">Intent is not authority</span>
  <p>
    The list states the maximum network intent of the package. Shimpz still applies reviewed policy and an
    authenticated egress boundary. A host in the manifest may be denied; an absent host must never be reached.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant SPEC">
  <a href="/developers/assistants/spec/secrets/"><span>Back</span><strong>Secrets</strong></a>
  <a href="/developers/assistants/spec/help/"><span>Next</span><strong>Help</strong></a>
</nav>
