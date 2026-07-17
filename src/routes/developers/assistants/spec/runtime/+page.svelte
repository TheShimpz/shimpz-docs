<svelte:head>
  <title>Assistant chat and file boundary — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/runtime/" />
  <meta
    name="description"
    content="How Shimpz confines Claude Code and Codex to one installed Assistant's Rules and controller-validated Powers."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span
  ><a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span><strong
    >Chat and files</strong
  >
</nav>

<header class="docs-page-header">
  <span class="section-label">Runtime boundary</span>
  <h1>Inference is not ambient authority.</h1>
  <p class="docs-lede">
    Claude Code and Codex are interchangeable inference instruments for one selected Assistant. They can
    interpret its Rules and propose its Powers; they are not coding agents inside the Capsule.
  </p>
</header>

<aside class="scope-note" aria-labelledby="chat-deny-title">
  <span id="chat-deny-title" class="kicker">Denied by construction</span>
  <p>
    The Brain exposes no shell, direct network, filesystem, code creation or editing, file execution,
    dependency installation, or provider-native tools. A prompt cannot widen this boundary.
  </p>
</aside>

<section class="guide-section" aria-labelledby="chat-selection-title">
  <span class="section-label">Selection</span>
  <h2 id="chat-selection-title">Bind every turn to one installed Assistant</h2>
  <ul>
    <li>The user selects a Capsule, an installed Assistant in that Capsule, and an inference provider.</li>
    <li>No selected installed Assistant means no Assistant chat turn.</li>
    <li>The controller loads only that Assistant's validated Rules and currently granted Powers.</li>
    <li>Changing Claude Code to Codex changes inference, not authority.</li>
    <li>Changing the Assistant replaces the Rules and Power set; authority never carries across.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="chat-flow-title">
  <span class="section-label">Power broker</span>
  <h2 id="chat-flow-title">Let the controller execute, never the model</h2>
  <ol>
    <li>The selected Assistant's Rules orient the model's response.</li>
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
  <h2 id="chat-model-title">Keep Claude Code and Codex purely instrumental</h2>
  <ul>
    <li>They cannot create, edit, delete, inspect, or execute Capsule files.</li>
    <li>They cannot run shell commands, package managers, interpreters, build tools, or source-control tools.</li>
    <li>They cannot call the internet, a Service, another Assistant, or a provider API directly.</li>
    <li>They receive no general-purpose tools supplied by Claude Code, Codex, or the host runtime.</li>
    <li>Provider login/session metadata authenticates inference only; it grants no Capsule capability.</li>
  </ul>
  <p>
    Assistant developers implement behavior behind declared Powers. Chat never turns a model into a
    general-purpose development environment, even when the inference provider's product name includes
    “Code”.
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
