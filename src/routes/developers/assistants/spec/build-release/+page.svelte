<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Build and release an Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/build-release/" />
  <meta
    name="description"
    content="Move an Assistant from local source to an immutable OCI digest without changing its contract."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Build and release</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Concept · artifact</span>
  <h1>Develop from source. Release by digest.</h1>
  <p class="docs-lede">
    The same manifest contract describes a local project during development and an immutable OCI image for
    a release.
  </p>
</header>

<section class="guide-section" aria-labelledby="build-development-title">
  <span class="section-label">Development</span>
  <h2 id="build-development-title">Keep source inside the project</h2>
  <CodeBlock
    label="Development Assistant artifact"
    title="shimpz.assistant.toml · artifact"
    variant="code"
    {...data.developmentArtifact}
  />
  <p>
    Development mode accepts only <code>source = "."</code> and forbids an image reference. Validate the
    full project—including Rules and schemas—before building its container.
  </p>
</section>

<section class="guide-section" aria-labelledby="build-release-title">
  <span class="section-label">Release</span>
  <h2 id="build-release-title">Replace source with one immutable image</h2>
  <CodeBlock
    label="Release Assistant artifact"
    title="shimpz.assistant.toml · artifact"
    variant="code"
    {...data.releaseArtifact}
  />
  <p>
    Replace the illustrative repository and digest above with the digest returned by your registry. Tags are
    mutable and are not valid release identities; release mode requires <code>image@sha256</code> and forbids
    <code>source</code>.
  </p>
</section>

<aside class="scope-note" aria-labelledby="build-admission-title">
  <span id="build-admission-title" class="kicker">The digest is identity, not authority</span>
  <p>
    A valid image reference does not install or grant the Assistant. Registry trust, declared architecture,
    runtime identity, resources, mounts, network, health, permissions, and owner decisions remain Team
    admission concerns.
  </p>
</aside>

<section class="guide-section" aria-labelledby="build-checklist-title">
  <span class="section-label">Release checklist</span>
  <h2 id="build-checklist-title">Change only what the release needs</h2>
  <ol>
    <li>Validate the complete source tree with the Assistant SDK.</li>
    <li>Build and test every architecture listed in the manifest.</li>
    <li>Push the OCI image and obtain its immutable registry digest.</li>
    <li>Switch <code>artifact.mode</code> to <code>release</code> and record that digest.</li>
    <li>Validate the release manifest again before publishing it.</li>
  </ol>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/runtime/"><span>Back</span><strong>Brain runtime</strong></a>
  <a href="/developers/assistants/hello-pulse/"><span>Next</span><strong>Hello Pulse</strong></a>
</nav>
