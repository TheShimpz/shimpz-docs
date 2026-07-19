<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant manifest — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/manifest/" />
  <meta
    name="description"
    content="Create a small, valid shimpz.assistant.toml manifest for an Assistant Spec v2 project."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Manifest</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Spec v2 · start here</span>
  <h1>Describe one Assistant.</h1>
  <p class="docs-lede">
    <code>shimpz.assistant.toml</code> contains only the identity and behavior choices that belong to the
    creator. Shimpz owns runtime, network, build, and file-layout decisions.
  </p>
</header>

<aside class="scope-note" aria-labelledby="manifest-request-title">
  <span id="manifest-request-title" class="kicker">A request, not a grant</span>
  <p>
    A Power declaration describes an intent. Installation, owner consent, and Team controller policy still
    decide whether it can run.
  </p>
</aside>

<section class="guide-section" aria-labelledby="manifest-example-title">
  <span class="section-label">Smallest useful example</span>
  <h2 id="manifest-example-title">Keep the first manifest boring</h2>
  <p>
    This complete example names its creators and three Powers. Omitting <code>approval</code> uses the safe
    <code>never</code> default, so the first Power shows the shortest valid form.
  </p>
  <CodeBlock
    label="Minimal Assistant Spec v2 manifest"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.manifest}
  />
</section>

<section class="guide-section" aria-labelledby="manifest-fields-title">
  <span class="section-label">Mental model</span>
  <h2 id="manifest-fields-title">Read it from top to bottom</h2>
  <ul>
    <li><code>schema_version</code> selects the closed v2 parser.</li>
    <li><code>name</code> is the display identity; Shimpz derives the stable kebab-case ID once.</li>
    <li><code>summary</code> gives people and the Brain one concise purpose.</li>
    <li><code>creators</code> contains one or more real GitHub users, including the leading <code>@</code>.</li>
    <li><code>github</code> is an optional public repository URL.</li>
    <li><code>powers</code> defines the only Assistant capabilities the Brain may request.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="manifest-validation-title">
  <span class="section-label">Fail closed</span>
  <h2 id="manifest-validation-title">Let validation catch drift early</h2>
  <p>
    Unknown fields, invalid creator names, duplicate Power IDs, unsafe conventional files, open schemas,
    and secret-like values are rejected. The <a
      class="external-link"
      href="/specs/assistant/v2/manifest.schema.json"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Assistant Manifest v2 JSON Schema (opens in a new tab)">JSON Schema</a
    > documents the data shape. The SDK also validates the conventional <code>assistant/RULES.md</code>,
    <code>HELP.md</code>, and <code>schemas/&lt;power&gt;.(input|output).schema.json</code> files.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/"><span>Back</span><strong>Spec v2 overview</strong></a>
  <a href="/developers/assistants/spec/rules/"><span>Next</span><strong>Rules</strong></a>
</nav>
