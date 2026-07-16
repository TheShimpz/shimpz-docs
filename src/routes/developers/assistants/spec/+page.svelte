<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Shimpz Assistant Spec v1 — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/" />
  <meta
    name="description"
    content="The closed source contract for Shimpz Assistant identity, operations, permissions, routines, and immutable artifacts."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span><strong>Spec v1</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Source contract · preview</span>
  <h1>Assistant Spec v1</h1>
  <p class="docs-lede">
    One closed manifest describes what an Assistant is and the exact authority it may request inside one
    Capsule. The manifest never grants that authority by itself.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-spec-status-title">
  <span id="assistant-spec-status-title" class="kicker">Released boundary</span>
  <p>
    The parser, schema, scaffolder, validator, and Hello Pulse development server are available in the SDK.
    The local evaluation controller additionally admits the published Hello Pulse digest into exactly one
    Capsule and mediates only its bounded <code>hello</code> operation. General artifact admission, Service
    capabilities, approvals, persistent scheduling, Assistant-to-Assistant transport, and provider
    credential binding are not released runtimes.
  </p>
</aside>

<section class="guide-section" aria-labelledby="assistant-manifest-title">
  <span class="section-label">Manifest</span>
  <h2 id="assistant-manifest-title">Request the smallest useful authority</h2>
  <p>
    Every project starts with <code>shimpz.assistant.toml</code>. Unknown fields, duplicate identifiers,
    mutable release tags, unsafe paths, embedded credentials, and unsupported values fail validation.
  </p>
  <CodeBlock
    label="Hello Pulse Assistant Spec v1 manifest"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.manifest}
  />
  <p>
    The machine-readable shape is the <a
      class="external-link"
      href="/specs/assistant/v1/manifest.schema.json"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Assistant Manifest v1 JSON Schema (opens in a new tab)">Assistant Manifest v1 JSON Schema</a
    >. The SDK parser remains authoritative for cross-field, filesystem, and secret-safety checks that JSON
    Schema alone does not express.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-artifact-title">
  <span class="section-label">Artifact</span>
  <h2 id="assistant-artifact-title">Develop from source; release by digest</h2>
  <ul>
    <li><code>development</code> accepts only <code>source = "."</code> inside the project.</li>
    <li><code>release</code> accepts only an immutable OCI <code>image@sha256</code> reference.</li>
    <li>The internal port, health path, and Linux architectures are explicit and bounded.</li>
    <li>There is no manifest field for shell commands, arbitrary URLs, or dependency installation.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="assistant-operation-title">
  <span class="section-label">Operations</span>
  <h2 id="assistant-operation-title">Expose names and closed data shapes</h2>
  <p>
    An operation has one stable identifier, input schema, output schema, summary, and approval policy. Its
    JSON schemas are local, bounded, and closed so an apparently harmless payload cannot become a generic
    credential or command channel.
  </p>
  <CodeBlock
    label="Closed input schema for the Hello operation"
    title="schemas/hello.input.schema.json"
    variant="code"
    {...data.inputSchema}
  />
  <p>
    <code>approval = "none"</code> means the operation itself asks for no user confirmation. It does not
    bypass a future controller grant. <code>once</code> and <code>each-run</code> describe requested approval
    behavior; their enforcement runtime is still pending.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-services-title">
  <span class="section-label">Service access</span>
  <h2 id="assistant-services-title">Bind capabilities, never provider keys</h2>
  <p>
    A Service permission names the Service interface and exact operations. A credential reference is only a
    logical Capsule binding chosen by the owner. Meta, Cloudflare, Telegram, or other provider values stay in
    the responsible Service credential store and never enter this file, an Assistant environment, or logs.
  </p>
  <CodeBlock
    label="Assistant request for one Meta Ads read operation"
    title="shimpz.assistant.toml · permission fragment"
    variant="code"
    {...data.servicePermission}
  />
  <p>
    This fragment defines the target contract; it is not proof that the <code>meta-ads</code> Service or
    credential binding is released. The current SDK validates the request but cannot grant or execute it.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-routine-title">
  <span class="section-label">Routines</span>
  <h2 id="assistant-routine-title">Schedule a declared operation, not arbitrary code</h2>
  <ul>
    <li>A routine points to an operation already declared by the same Assistant.</li>
    <li>Intervals start at 60 seconds; timeout and jitter must fit inside the interval.</li>
    <li>Every routine starts disabled and requires an explicit owner decision.</li>
    <li><code>single_flight = true</code> prevents overlapping executions.</li>
    <li>The idempotency template includes <code>scheduled_at</code> to make retries deterministic.</li>
  </ul>
  <p>
    Spec v1 validates this contract. A persistent scheduler, pause/resume state, missed-run policy, and
    execution ledger are controller work still to be released.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-calls-title">
  <span class="section-label">Collaboration</span>
  <h2 id="assistant-calls-title">Declare another Assistant's operation</h2>
  <p>
    <code>permissions.assistants</code> uses the same interface-and-operation allowlist. It never grants
    another Assistant's workspace, container, database, secrets, or generic network address. The mediated
    call transport and replay-safe capabilities are architecture only today; Redpanda does not replace
    caller identity or authorization.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-cli-title">
  <span class="section-label">Developer tooling</span>
  <h2 id="assistant-cli-title">Create and validate locally</h2>
  <p>From the root of a checked-out <code>shimpz-sdk</code> repository with Python 3.14:</p>
  <CodeBlock
    label="Create and validate an Assistant project"
    title="Terminal · Assistant SDK"
    lines={[
      {
        value:
          "SHIMPZ_LIB=$PWD/rootfs/opt/shimpz-lib python3 rootfs/usr/local/bin/shimpz-assistant new hello-pulse /tmp/hello-pulse",
      },
      {
        value:
          "SHIMPZ_LIB=$PWD/rootfs/opt/shimpz-lib python3 rootfs/usr/local/bin/shimpz-assistant validate /tmp/hello-pulse",
      },
    ]}
  />
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant developer guide">
  <a href="/developers/assistants/"><span>Back</span><strong>Assistants overview</strong></a>
  <a href="/developers/assistants/hello-pulse/"><span>Next</span><strong>Hello Pulse</strong></a>
</nav>
