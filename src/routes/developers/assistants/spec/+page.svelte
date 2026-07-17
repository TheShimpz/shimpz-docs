<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Shimpz Assistant Spec v2 — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/" />
  <meta
    name="description"
    content="Start with the Shimpz Assistant Spec v2 and learn each concept through one short, practical guide."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span><strong>Spec v2</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Current Assistant contract</span>
  <h1>Build one safe capability at a time.</h1>
  <p class="docs-lede">
    Assistant Spec v2 keeps behavior, authority, and execution separate. Start with a tiny project, validate
    it locally, then add only the concepts your Assistant needs.
  </p>
</header>

<section class="guide-section" aria-labelledby="assistant-flow-title">
  <span class="section-label">Mental model</span>
  <h2 id="assistant-flow-title">Rules orient. Powers act.</h2>
  <ol>
    <li>Rules tell the Brain how the Assistant should behave.</li>
    <li>The Brain may request one Power declared by that Assistant.</li>
    <li>The Capsule controller validates the request and decides whether it is granted.</li>
    <li>The Assistant executes the bounded Power and returns a schema-validated result.</li>
  </ol>
  <p>
    The provider-neutral LangGraph Brain receives the selected Assistant's Rules and declared Powers, but
    Rules never grant authority. Only the Capsule controller can validate and execute an authorized Power;
    the Brain never receives an ambient shell, filesystem, general network, or host tools.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-topics-title">
  <span class="section-label">Spec v2 topics</span>
  <h2 id="assistant-topics-title">Learn each concept independently</h2>
  <ul class="docs-entry-list">
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/manifest/">
        <strong>Project manifest</strong>
        <span>Map one minimal Assistant project in a single file.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/rules/">
        <strong>Rules</strong>
        <span>Guide behavior without creating authority.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/powers/">
        <strong>Powers</strong>
        <span>Declare one safe action with closed input and output.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/permissions/">
        <strong>Permissions</strong>
        <span>Request the narrowest Service or Assistant access.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/routines/">
        <strong>Routines</strong>
        <span>Schedule a declared Power with safe defaults.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/runtime/">
        <strong>Brain runtime</strong>
        <span>Use LangGraph inference without giving the model ambient authority.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/build-release/">
        <strong>Build and release</strong>
        <span>Validate locally and release one immutable artifact.</span>
      </a>
    </li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="assistant-first-project-title">
  <span class="section-label">Fastest path</span>
  <h2 id="assistant-first-project-title">Scaffold and validate Hello Pulse</h2>
  <p>From a checked-out <code>shimpz-sdk</code> repository with Python 3.14:</p>
  <CodeBlock
    label="Create and validate the Hello Pulse Assistant"
    title="Terminal · two commands"
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
  <p>
    Continue with the <a href="/developers/assistants/hello-pulse/">Hello Pulse walkthrough</a> to call its
    first Power.
  </p>
</section>

<aside class="scope-note" aria-labelledby="assistant-spec-status-title">
  <span id="assistant-spec-status-title" class="kicker">Available today</span>
  <p>
    Spec v2 source validation and the reviewed Hello Pulse runtime contract are implemented. Generic
    third-party manifest ingestion, cross-component bindings, and routine scheduling are not released yet;
    the guides describe the closed contract they must satisfy.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant developer guide">
  <a href="/developers/assistants/"><span>Back</span><strong>Assistants overview</strong></a>
  <a href="/developers/assistants/spec/manifest/"><span>Next</span><strong>Project manifest</strong></a>
</nav>
