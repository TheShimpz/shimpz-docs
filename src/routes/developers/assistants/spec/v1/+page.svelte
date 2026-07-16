<svelte:head>
  <title>Shimpz Assistant Spec v1 compatibility — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/v1/" />
  <meta
    name="description"
    content="Frozen Assistant Spec v1 vocabulary and its closed compatibility path to Rules and Powers in v2."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span
  ><a href="/developers/assistants/spec/">Spec</a><span aria-hidden="true">/</span><strong>v1</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Frozen compatibility contract</span>
  <h1>Assistant Spec v1</h1>
  <p class="docs-lede">
    Existing v1 manifests remain valid. New Assistants should use v2 and its clearer Rules and Powers
    vocabulary.
  </p>
</header>

<aside class="scope-note" aria-labelledby="v1-frozen-title">
  <span id="v1-frozen-title" class="kicker">No implicit upgrade</span>
  <p>
    The integer <code>schema_version</code> selects exactly one closed grammar. A manifest that mixes v1 and
    v2 fields is invalid instead of being guessed or silently repaired.
  </p>
</aside>

<section class="guide-section" aria-labelledby="v1-mapping-title">
  <span class="section-label">Normalization</span>
  <h2 id="v1-mapping-title">One legacy vocabulary, one internal model</h2>
  <ul>
    <li><code>skill</code> is normalized to <code>rules</code>.</li>
    <li><code>[[operations]]</code> is normalized to the Assistant's declared <code>powers</code>.</li>
    <li><code>routines.operation</code> is normalized to <code>routines.power</code>.</li>
    <li>
      <code>permissions.assistants.operations</code> is normalized to
      <code>permissions.assistants.powers</code>.
    </li>
  </ul>
  <p>
    Service <code>operations</code> keep the same meaning in both versions. The fixed
    <code>/v1/operations/&lt;power-id&gt;</code> adapter also remains a wire compatibility detail, not model or
    manifest authority.
  </p>
</section>

<section class="guide-section" aria-labelledby="v1-schema-title">
  <span class="section-label">Machine contract</span>
  <h2 id="v1-schema-title">Use the frozen v1 schema</h2>
  <p>
    The <a
      class="external-link"
      href="/specs/assistant/v1/manifest.schema.json"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Assistant Manifest v1 JSON Schema (opens in a new tab)">Assistant Manifest v1 JSON Schema</a
    > remains published unchanged. The versioned SDK parser continues to enforce its cross-field,
    filesystem, and secret-safety checks.
  </p>
</section>

<nav class="docs-page-nav" aria-label="Return to the current Assistant Spec">
  <a href="/developers/assistants/spec/"><span>Current contract</span><strong>Assistant Spec v2</strong></a>
</nav>
