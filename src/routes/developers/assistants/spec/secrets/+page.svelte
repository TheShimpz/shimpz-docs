<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant secrets — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/secrets/" />
  <meta
    name="description"
    content="Declare Assistant secret metadata and deliver Team-scoped values to one Power just in time."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Secrets</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Concept · private input</span>
  <h1>Declare metadata. Deliver values just in time.</h1>
  <p class="docs-lede">
    An Assistant may name the private values its Powers need, but source contains only public labels. The
    authenticated Admin collects each value for one Assistant installation in one Team, and the controller
    delivers only the exact subset required by one invocation.
  </p>
</header>

<aside class="scope-note" aria-labelledby="secret-boundary-title">
  <span id="secret-boundary-title" class="kicker">Write-only custody</span>
  <p>
    A secret value never enters the manifest, Brain context, Genesis, Help, schema, environment, command
    line, log, output, error, or browser status response. Declaring an ID does not grant its value.
  </p>
</aside>

<section class="guide-section" aria-labelledby="secret-declaration-title">
  <span class="section-label">Public contract</span>
  <h2 id="secret-declaration-title">Keep declarations small and explicit</h2>
  <CodeBlock
    label="One secret declaration and its Power reference"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.declaration}
  />
  <ul>
    <li>The table key is a stable lowercase kebab-case secret ID of at most 64 characters.</li>
    <li>Each <code>[secrets.&lt;id&gt;]</code> table accepts exactly <code>name</code> and <code>summary</code>.</li>
    <li>There is no value, environment-variable name, default, or <code>required</code> flag in the manifest.</li>
    <li>A Power lists only unique IDs declared by the same Assistant; undefined references fail validation.</li>
    <li>A Power without a <code>secrets</code> list receives an empty secret object.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="secret-scope-title">
  <span class="section-label">Isolation</span>
  <h2 id="secret-scope-title">Scope every value to Team and Assistant</h2>
  <p>
    One stored value belongs to one Assistant installation inside one Team. It is not Space-global, cannot be
    reused by another Assistant, and cannot cross into another Team. Powers in that same installation may
    reuse it only when their admitted declarations reference the same ID.
  </p>
  <p>
    Each value is an independently authenticated AES-256-GCM envelope whose state and encryption key have
    separate controller custody. Encryption at rest does not turn a compromised controller or host root into a
    trusted boundary; Team isolation, exact per-Power declarations, reviewed code, and exact
    <code>allowed_hosts</code> enforcement remain necessary.
  </p>
  <p>
    The Admin inventory groups entries by <strong>Team → Assistant</strong>. It shows each declared name,
    summary, and only a configured or missing status. Configured values use a bounded, length-aware identifier:
    short values reveal no characters, while longer values show at most four characters at each edge, such as
    <code>abcd…wxyz</code>. The inventory never returns plaintext, a hash, an encryption envelope, or enough
    metadata to reconstruct a value.
  </p>
</section>

<section class="guide-section" aria-labelledby="secret-rotation-title">
  <span class="section-label">Declared lifecycle</span>
  <h2 id="secret-rotation-title">Keep the ID stable when a value rotates</h2>
  <p>
    Rotation is a complete replacement of the value behind the same declared secret ID. Do not add a version,
    timestamp, or provider generation to the manifest key. A rotation flow must use the same authenticated,
    write-only boundary, create a new encrypted generation, and make the previous generation unusable; partial
    merges and plaintext reads are never valid rotation mechanisms.
  </p>
  <p>
    One atomic rotation may replace one or several declared IDs for the same Assistant, but every supplied value
    is a complete replacement. All entries must validate before any generation changes, and a successful write
    returns refreshed status and masks only—never an old or new plaintext value.
  </p>
</section>

<section class="guide-section" aria-labelledby="secret-jit-title">
  <span class="section-label">Admin flow</span>
  <h2 id="secret-jit-title">Ask only when a selected Power needs it</h2>
  <ol>
    <li>The Brain requests one declared Power; it never receives or asks for the secret value in chat.</li>
    <li>The controller resolves the exact admitted secret IDs for that Power.</li>
    <li>
      If any are missing, the entire Power batch remains unexecuted and the Admin opens one contextual modal
      containing every missing value, grouped by Assistant with each declaration's name and summary.
    </li>
    <li>The owner submits the missing values over the authenticated write-only channel.</li>
    <li>The controller validates and stores them under the current Team and Assistant, then resolves them for the invocation.</li>
  </ol>
  <p>
    The controller issues an opaque, one-use, Team-bound challenge that expires after five minutes. The paused
    continuation stays only in controller memory, so a restart or expiry discards it and the owner retries the
    turn. Already encrypted stored values persist independently of that continuation.
  </p>
  <p>
    Closing the modal leaves the Power unexecuted. Saving a value never approves a Power: an
    <code>approval = "once"</code> or <code>approval = "always"</code> decision remains a separate, explicit
    user action.
  </p>
  <p>
    The right-side secret inventory lists every installed Assistant and its configured or missing declarations.
    It is status-only: reopening the inventory can never retrieve a stored value.
  </p>
</section>

<section class="guide-section" aria-labelledby="secret-envelope-title">
  <span class="section-label">Private RPC</span>
  <h2 id="secret-envelope-title">Use one closed stdin envelope</h2>
  <p>
    Immediately before execution, either controller writes one bounded JSON object to the private RPC adapter's
    standard input. The object has exactly the root keys <code>input</code> and <code>secrets</code>; the secret
    object has exactly the IDs declared by that Power. Missing or additional roots, missing or additional
    secret IDs, duplicate JSON keys, invalid UTF-8, or an invalid Power input fail closed.
  </p>
  <CodeBlock
    label="Illustrative private invocation envelope; never paste a real value into source or a shell"
    title="Controller to Assistant · stdin JSON"
    variant="code"
    {...data.envelope}
  />
  <p>
    Values exist only in the bounded invocation payload and request memory. They are never placed in
    environment variables or process arguments, and the Assistant must never copy them into its response or
    provider error. The output remains the Power's declared schema-validated object.
  </p>
</section>

<section class="guide-section" aria-labelledby="secret-x-title">
  <span class="section-label">X.com reference</span>
  <h2 id="secret-x-title">Give each Power only the X credentials it uses</h2>
  <ul>
    <li>
      <code>public-user-lookup</code> receives only <code>x-bearer-token</code> and uses
      <code>approval = "never"</code> for a public read.
    </li>
    <li>
      <code>identity-me</code> receives <code>x-api-key</code>, <code>x-api-key-secret</code>,
      <code>x-access-token</code>, and <code>x-access-token-secret</code> for an OAuth 1.0a account read.
    </li>
    <li>
      <code>create-post</code> and <code>delete-post</code> receive the same four OAuth 1.0a values and each use
      <code>approval = "always"</code> because they create an external effect.
    </li>
  </ul>
  <p>
    All four Powers may contact only the separately declared <code>api.x.com</code> host. A secret does not
    grant egress, and <code>allowed_hosts</code> does not grant a secret. The controller must satisfy both
    independent policies before any provider call.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/powers/"><span>Back</span><strong>Powers</strong></a>
  <a href="/developers/assistants/spec/permissions/"><span>Next</span><strong>Permissions</strong></a>
</nav>
