<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant permissions — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/permissions/" />
  <meta
    name="description"
    content="Request minimal Service operations, Assistant Powers, and egress in an Assistant manifest."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Permissions</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Concept · requested access</span>
  <h1>Start with no external access.</h1>
  <p class="docs-lede">
    Permissions declare the smallest external capability the Assistant may need. Every entry remains a
    request until the Capsule controller grants it.
  </p>
</header>

<section class="guide-section" aria-labelledby="permissions-empty-title">
  <span class="section-label">Safe default</span>
  <h2 id="permissions-empty-title">Use empty lists first</h2>
  <CodeBlock
    label="Assistant with no external permission requests"
    title="shimpz.assistant.toml · permissions"
    variant="code"
    {...data.emptyPermissions}
  />
</section>

<section class="guide-section" aria-labelledby="permissions-example-title">
  <span class="section-label">Explicit requests</span>
  <h2 id="permissions-example-title">Add one interface at a time</h2>
  <CodeBlock
    label="Service and Assistant permission requests"
    title="shimpz.assistant.toml · permissions"
    variant="code"
    {...data.permissionRequests}
  />
  <ul>
    <li>A shared <strong>Service</strong> exposes named <code>operations</code>.</li>
    <li>Another installed <strong>Assistant</strong> exposes named <code>powers</code>.</li>
    <li><code>interface</code> pins the contract version independently from an artifact version.</li>
    <li><code>credential_refs</code> are logical Capsule binding names, never provider key IDs or values.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="permissions-grant-title">
  <span id="permissions-grant-title" class="kicker">Requests never self-grant</span>
  <p>
    Installation, owner consent, target availability, interface compatibility, and controller policy must
    all succeed. An Assistant cannot call itself, reach a sibling directly, or inherit that sibling's files,
    secrets, runtime, or network.
  </p>
</aside>

<section class="guide-section" aria-labelledby="permissions-egress-title">
  <span class="section-label">Direct egress</span>
  <h2 id="permissions-egress-title">Prefer a Service when one owns the integration</h2>
  <p>
    If an Assistant truly needs direct network access, <code>egress</code> accepts exact lowercase public DNS
    hostnames—not URLs, wildcards, IP addresses, or private names. A hostname is still only a request; the
    controller must resolve it and apply runtime policy. Keep provider credentials in the responsible Service.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/powers/"><span>Back</span><strong>Powers</strong></a>
  <a href="/developers/assistants/spec/routines/"><span>Next</span><strong>Routines</strong></a>
</nav>
