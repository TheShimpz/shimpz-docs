<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Shimpz Assistant Spec v2 — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/" />
  <meta
    name="description"
    content="The closed Rules and Powers contract for Shimpz Assistants, controller grants, routines, and immutable artifacts."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span><strong>Spec v2</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Source contract · current</span>
  <h1>Assistant Spec v2</h1>
  <p class="docs-lede">
    Rules describe behavior. Powers declare the only capabilities an Assistant may request. The Capsule
    controller—not the manifest, model, or Assistant—decides what is installed, granted, and invoked.
  </p>
</header>

<aside class="scope-note" aria-labelledby="assistant-spec-status-title">
  <span id="assistant-spec-status-title" class="kicker">Version boundary</span>
  <p>
    New projects use v2. The parser still accepts the frozen
    <a href="/developers/assistants/spec/v1/">Assistant Spec v1</a> contract and normalizes it internally,
    but never guesses a version or accepts mixed v1/v2 vocabulary.
  </p>
</aside>

<section class="guide-section" aria-labelledby="assistant-manifest-title">
  <span class="section-label">Manifest</span>
  <h2 id="assistant-manifest-title">Request the smallest useful authority</h2>
  <p>
    Every project starts with <code>shimpz.assistant.toml</code>. Unknown fields, duplicate Power IDs,
    undeclared routine Powers, mutable release tags, unsafe paths, embedded credentials, and unsupported
    values fail validation.
  </p>
  <CodeBlock
    label="Hello Pulse Assistant Spec v2 manifest"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.manifest}
  />
  <p>
    The machine-readable shape is the <a
      class="external-link"
      href="/specs/assistant/v2/manifest.schema.json"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Assistant Manifest v2 JSON Schema (opens in a new tab)">Assistant Manifest v2 JSON Schema</a
    >. The SDK parser remains authoritative for cross-field, filesystem, UTF-8, and secret-safety checks
    that JSON Schema alone cannot express.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-rules-title">
  <span class="section-label">Rules</span>
  <h2 id="assistant-rules-title">Orient behavior without granting authority</h2>
  <p>
    <code>rules</code> points to one bounded Markdown file inside the project, normally
    <code>assistant/RULES.md</code>. It tells the inference model how this Assistant should reason, when a
    Power is appropriate, and how to present results. Rules cannot add a Power, bypass approval, expose a
    credential, or authorize a tool.
  </p>
  <p>
    The file must be non-empty, valid UTF-8, free of unsafe control characters and credential material,
    and remain inside the Assistant project.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-powers-title">
  <span class="section-label">Powers</span>
  <h2 id="assistant-powers-title">Expose names and closed data shapes</h2>
  <p>
    A Power has one stable identifier, input schema, output schema, summary, and requested approval policy.
    Its local JSON schemas are bounded and closed, so a harmless-looking payload cannot become a generic
    credential, command, file, or network channel.
  </p>
  <CodeBlock
    label="Closed input schema for the Hello Power"
    title="schemas/hello.input.schema.json"
    variant="code"
    {...data.inputSchema}
  />
  <p>
    The fixed HTTP adapter remains <code>/v1/operations/&lt;power-id&gt;</code> for wire compatibility. A
    manifest or model cannot choose that path. The trusted controller maps a declared Power ID to the fixed
    adapter and validates both schemas before and after invocation.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-grants-title">
  <span class="section-label">Grants</span>
  <h2 id="assistant-grants-title">Treat every declaration as a request</h2>
  <ul>
    <li>The Assistant must be installed in the target Capsule.</li>
    <li>The owner and controller policy must grant the requested authority.</li>
    <li>Chat may select only one installed Assistant and request only that Assistant's declared Powers.</li>
    <li>Input, output, approval, caller identity, expiry, and replay policy are controller decisions.</li>
    <li>The manifest has no self-grant, shell, generic URL, arbitrary command, or dependency-install field.</li>
  </ul>
  <p>
    Read the <a href="/developers/assistants/runtime/">chat and file boundary</a> for the runtime rules that
    keep Claude Code and Codex purely instrumental.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-services-title">
  <span class="section-label">Service access</span>
  <h2 id="assistant-services-title">Keep Service operations explicit</h2>
  <p>
    Services retain the established term <code>operations</code>. A Service permission names its versioned
    interface, exact operations, and opaque Capsule credential bindings. Provider values stay in the
    responsible Service store and never enter Rules, the manifest, model context, or Assistant environment.
  </p>
  <CodeBlock
    label="Assistant request for one Meta Ads Service operation"
    title="shimpz.assistant.toml · permission fragment"
    variant="code"
    {...data.servicePermission}
  />
  <p>
    Assistant-to-Assistant permissions use <code>powers</code>, not Service operations. They expose only a
    declared interface and named Powers—never the sibling's container, files, database, secrets, or network.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-routine-title">
  <span class="section-label">Routines</span>
  <h2 id="assistant-routine-title">Schedule a declared Power, not arbitrary code</h2>
  <ul>
    <li>A routine points to a Power already declared by the same Assistant.</li>
    <li>Intervals start at 60 seconds; timeout and jitter must fit inside the interval.</li>
    <li>Every routine starts disabled and requires an explicit owner decision.</li>
    <li><code>single_flight = true</code> prevents overlapping executions.</li>
    <li>The idempotency template includes <code>scheduled_at</code> for deterministic retries.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="assistant-artifact-title">
  <span class="section-label">Artifact</span>
  <h2 id="assistant-artifact-title">Develop from source; release by digest</h2>
  <ul>
    <li><code>development</code> accepts only <code>source = "."</code> inside the project.</li>
    <li><code>release</code> accepts only an immutable OCI <code>image@sha256</code> reference.</li>
    <li>The internal port, health path, and Linux architectures are explicit and bounded.</li>
    <li>Runtime admission still applies resource, identity, network, mount, and grant policy.</li>
  </ul>
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
  <a href="/developers/assistants/runtime/"><span>Next</span><strong>Chat and files</strong></a>
</nav>
