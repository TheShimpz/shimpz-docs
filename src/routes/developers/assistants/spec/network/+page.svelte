<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant network access — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/network/" />
  <meta name="description" content="Declare exact public hosts with the Assistant allowed_hosts field." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v3</a><span aria-hidden="true">/</span>
  <strong>Network access</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Outbound access</span>
  <h1>Allow exact destinations, not “the internet”</h1>
  <p class="docs-lede">
    <code>allowed_hosts</code> makes outbound network intent visible and reviewable. It is required even
    when empty, denies everything not listed, and never grants access by itself.
  </p>
</header>

<section class="guide-section" aria-labelledby="none-title">
  <span class="section-label">No external API</span>
  <h2 id="none-title">Prefer an empty list</h2>
  <CodeBlock
    label="No requested network access"
    title="shimpz.toml"
    variant="code"
    {...data.none}
  />
  <p>
    If every Power works from its inputs and Controller-injected context, the Assistant does not need an
    external host.
  </p>
</section>

<section class="guide-section" aria-labelledby="host-title">
  <span class="section-label">One external API</span>
  <h2 id="host-title">Write only the public DNS hostname</h2>
  <CodeBlock
    label="One requested API host"
    title="shimpz.toml"
    variant="code"
    {...data.oneHost}
  />
  <p>
    Do not include <code>https://</code>, a port, path, query, fragment, wildcard, or trailing slash.
    HTTPS and WSS are the only admitted protocols; a second API hostname is a second explicit list item.
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
    <li>An Account-backed API host, such as <code>api.cloudflare.com</code>, must still appear in this list.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="intent-title">
  <span id="intent-title" class="kicker">Intent is not authority</span>
  <p>
    The list states the maximum network intent of the package. Shimpz still applies reviewed policy, DNS and
    address checks, and an authenticated egress boundary. A listed host may be denied; an absent host must
    never be reached.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/accounts/"><span>Back</span><strong>Accounts</strong></a>
  <a href="/developers/assistants/spec/help/"><span>Next</span><strong>Runtime documents</strong></a>
</nav>
