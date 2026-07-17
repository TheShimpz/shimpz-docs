<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant Powers — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/powers/" />
  <meta
    name="description"
    content="Declare narrow Assistant Powers with closed input and output schemas."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Powers</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Concept · capability</span>
  <h1>Give every action a narrow Power.</h1>
  <p class="docs-lede">
    A Power is a named Assistant capability with exact input, exact output, and a requested approval policy.
  </p>
</header>

<aside class="scope-note" aria-labelledby="powers-semantic-title">
  <span id="powers-semantic-title" class="kicker">Prefer intent over machinery</span>
  <p>
    Use <code>invoice-extract</code>, not <code>file-read</code>; use <code>campaign-health</code>, not
    <code>http-request</code>. A semantic Power is easier to grant, audit, and keep safe.
  </p>
</aside>

<section class="guide-section" aria-labelledby="powers-declaration-title">
  <span class="section-label">Declaration</span>
  <h2 id="powers-declaration-title">Name one useful outcome</h2>
  <CodeBlock
    label="Hello Power declaration"
    title="shimpz.assistant.toml · Power"
    variant="code"
    {...data.power}
  />
  <p>
    Power IDs are stable lowercase kebab-case identifiers. The approval value requests <code>none</code>,
    <code>once</code>, or <code>each-run</code>; it never overrides an owner or controller decision.
  </p>
</section>

<section class="guide-section" aria-labelledby="powers-schema-title">
  <span class="section-label">Closed data</span>
  <h2 id="powers-schema-title">Accept only the fields you designed</h2>
  <CodeBlock
    label="Closed Hello Power input"
    title="schemas/hello.input.schema.json"
    variant="code"
    {...data.inputSchema}
  />
  <p>
    Define the output with the same closed JSON Schema pattern. The SDK rejects open objects, remote schema
    references, credential-bearing fields, and unsupported schema features.
  </p>
</section>

<section class="guide-section" aria-labelledby="powers-runtime-title">
  <span class="section-label">Invocation</span>
  <h2 id="powers-runtime-title">Let the controller broker the call</h2>
  <p>
    The controller must validate the request, map the declared Power ID to the fixed
    <code>/v1/operations/&lt;power-id&gt;</code> adapter, validate the result, and audit the invocation. That
    compatibility path is not a URL the model or manifest can choose. Shared Services continue to call their
    capabilities <strong>operations</strong>; Assistants expose <strong>Powers</strong>.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/rules/"><span>Back</span><strong>Rules</strong></a>
  <a href="/developers/assistants/spec/permissions/"><span>Next</span><strong>Permissions</strong></a>
</nav>
