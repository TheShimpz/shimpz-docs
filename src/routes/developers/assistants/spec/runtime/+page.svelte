<svelte:head>
  <title>Assistant Brain runtime boundary — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/runtime/" />
  <meta
    name="description"
    content="How the provider-neutral LangGraph Brain uses one Assistant's Rules and Powers while the Capsule controller retains execution authority."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span
  ><a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span><strong
    >Brain runtime</strong
  >
</nav>

<header class="docs-page-header">
  <span class="section-label">Runtime boundary</span>
  <h1>Inference is not ambient authority.</h1>
  <p class="docs-lede">
    Shimpz uses a provider-neutral LangGraph Brain for one selected Assistant. The Brain receives that
    Assistant's validated Rules and Powers so it can answer or request a bounded action; it is not a coding
    agent inside the Capsule.
  </p>
</header>

<aside class="scope-note" aria-labelledby="chat-deny-title">
  <span id="chat-deny-title" class="kicker">Denied by construction</span>
  <p>
    The Brain exposes no ambient shell, filesystem, general network access, code creation or editing, file
    execution, dependency installation, or provider-native tools. Its only outbound provider call uses the
    configured model client. A prompt cannot widen this boundary.
  </p>
</aside>

<section class="guide-section" aria-labelledby="chat-selection-title">
  <span class="section-label">Selection</span>
  <h2 id="chat-selection-title">Bind every turn to one installed Assistant</h2>
  <ul>
    <li>The user selects a Capsule, an installed Assistant in that Capsule, and an OpenAI or Anthropic model.</li>
    <li>No selected installed Assistant means no Assistant chat turn.</li>
    <li>The controller gives LangGraph only that Assistant's validated Rules and currently granted Powers.</li>
    <li>Changing provider or model changes inference, not authority.</li>
    <li>Changing the Assistant replaces the Rules and Power set; authority never carries across.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="chat-flow-title">
  <span class="section-label">Power broker</span>
  <h2 id="chat-flow-title">Let the controller execute, never the model</h2>
  <ol>
    <li>The controller loads the selected Assistant's validated Rules and Power definitions.</li>
    <li>LangGraph gives that closed context to the configured model provider.</li>
    <li>The model may answer with text or request one declared Power with structured input.</li>
    <li>The controller verifies installation, declaration, grant, approval, and the closed input schema.</li>
    <li>A fixed adapter invokes the Power; the model cannot choose a command, URL, container, or route.</li>
    <li>The controller validates the output, records the invocation, and returns only the bounded result.</li>
  </ol>
  <p>
    A malformed request, undeclared Power, missing grant, unavailable Assistant, schema mismatch, or
    unexpected result fails closed. Rules are instructions—not a fallback authorization mechanism.
  </p>
</section>

<section class="guide-section" aria-labelledby="chat-model-title">
  <span class="section-label">Brain</span>
  <h2 id="chat-model-title">Keep LangGraph provider-neutral and instrumental</h2>
  <ul>
    <li>The Brain cannot create, edit, delete, inspect, or execute Capsule files.</li>
    <li>It cannot run shell commands, package managers, interpreters, build tools, or source-control tools.</li>
    <li>It cannot call a Service, another Assistant, arbitrary internet endpoint, or host route.</li>
    <li>Its LangGraph tools are generated only from the selected Assistant's declared Powers.</li>
    <li>Each tool call suspends the graph; only the controller may authorize and execute the Power.</li>
  </ul>
  <p>
    Assistant developers implement behavior behind declared Powers. Chat never turns a model or graph into
    a general-purpose development environment.
  </p>
</section>

<section class="guide-section" aria-labelledby="provider-keys-title">
  <span class="section-label">Model credentials</span>
  <h2 id="provider-keys-title">Configure OpenAI or Anthropic with an API key</h2>
  <ol>
    <li>The owner saves one provider API key through the authenticated Admin credential form.</li>
    <li>The credential store keeps the secret; status responses expose only whether a key is configured.</li>
    <li>The controller resolves the selected provider's key for the turn and delivers it to the Brain in memory.</li>
    <li>The Brain creates the fixed provider client without placing the key in graph or conversation state.</li>
    <li>The key is never returned to the browser, logged, included in a Power, or exposed to the Assistant.</li>
  </ol>
  <p>
    Brain providers use API-key authentication only. The generic OAuth profiles in Service Spec v1 remain
    available for Service integrations; they are a separate credential boundary and are not model login
    mechanisms.
  </p>
</section>

<section class="guide-section" aria-labelledby="file-storage-title">
  <span class="section-label">Uploaded files</span>
  <h2 id="file-storage-title">Store opaque objects outside every runtime</h2>
  <ul>
    <li>Each Capsule starts with a total upload quota of <strong>100 MiB</strong>.</li>
    <li>The controller stores bytes under opaque server-assigned object IDs, isolated by Capsule.</li>
    <li>Only the Capsule controller can list, write, read, or delete objects in the storage plane.</li>
    <li>Uploaded content is never mounted into the Brain or an Assistant container.</li>
    <li>An upload is data only: it is never treated as a path, program, dependency, prompt, or executable.</li>
  </ul>
  <p>
    The portable v1 boundary is an exact transactional payload quota plus a bounded SQLite page ceiling,
    not a claim of kernel project quotas across Linux and Docker Desktop. The stronger execution boundary
    is that workloads receive no storage mount at all. A trusted per-Capsule quota resolver is already the
    seam for future plan limits; clients cannot choose or increase that value.
  </p>
</section>

<section class="guide-section" aria-labelledby="file-power-title">
  <span class="section-label">File access</span>
  <h2 id="file-power-title">Require an explicit Power for content</h2>
  <p>
    Chat may show safe object metadata, but neither the model nor Assistant receives uploaded bytes by
    default. Content access requires a named Power whose schema explicitly accepts an opaque object ID. The
    controller verifies Capsule ownership, installation, grant, approval, quota policy, and schema before
    brokering a bounded stream to that single invocation.
  </p>
  <p>
    The object never becomes a shared mount or ambient filesystem. The controller does not execute it, and
    one Assistant cannot reuse another Capsule's object ID. A Power result returns through its declared
    output schema; it cannot leak a host path or create persistent file authority.
  </p>
</section>

<section class="guide-section" aria-labelledby="chat-author-title">
  <span class="section-label">Developer rule</span>
  <h2 id="chat-author-title">Design the narrowest useful Power</h2>
  <p>
    Prefer a semantic Power such as <code>invoice.extract</code> over generic capabilities such as
    <code>file.read</code>, <code>http.request</code>, or <code>code.run</code>. Close every input and output
    shape, request only the required Service operations, and make sensitive actions require explicit owner
    approval.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant developer guide">
  <a href="/developers/assistants/spec/routines/"><span>Back</span><strong>Routines</strong></a>
  <a href="/developers/assistants/spec/build-release/"><span>Next</span><strong>Build and release</strong></a>
</nav>
