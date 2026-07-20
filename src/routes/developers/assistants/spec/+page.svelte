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
    it locally, then add only the Powers your Assistant needs.
  </p>
</header>

<section class="guide-section" aria-labelledby="assistant-flow-title">
  <span class="section-label">Mental model</span>
  <h2 id="assistant-flow-title">Genesis guides. Powers act.</h2>
  <ol>
    <li>Each enabled Assistant contributes its validated Genesis and declared Powers to its Team.</li>
    <li>The Brain decides which Assistant Power, if any, can help answer the Team's current turn.</li>
    <li>The controller validates the request and decides whether it is granted.</li>
    <li>The Assistant executes the bounded Power and returns a schema-validated result.</li>
  </ol>
  <p>
    The provider-neutral LangGraph Brain can chain Powers from the Team's enabled Assistants before it
    answers naturally as the Team. Genesis defines behavior, response style, safety guidance, and Power
    composition, but never grants authority. Only the controller can validate and execute an authorized
    Power; the Brain never receives an ambient shell, filesystem, general network, or host tools.
  </p>
</section>

<section class="guide-section" aria-labelledby="assistant-files-title">
  <span class="section-label">Contract at a glance</span>
  <h2 id="assistant-files-title">Put each decision in one place</h2>
  <ul>
    <li><strong>What is it?</strong> Identity and summary live in <code>shimpz.assistant.toml</code>.</li>
    <li><strong>How should it reason?</strong> Purpose and Power composition live in <code>GENESIS.md</code>.</li>
    <li><strong>What may it execute?</strong> Named Powers and closed schemas define the callable surface.</li>
    <li><strong>What private access is needed?</strong> Each Power references exact Secret and Account IDs.</li>
    <li><strong>Where may it send data?</strong> <code>allowed_hosts</code> lists exact public DNS destinations.</li>
    <li><strong>What does the user see?</strong> Localized <code>help/HELP-&lt;locale&gt;.md</code> files teach usage.</li>
    <li><strong>What actually grants authority?</strong> Only controller admission, user consent, and runtime policy.</li>
  </ul>
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
      <a class="docs-entry-link" href="/developers/assistants/spec/genesis/">
        <strong>Genesis</strong>
        <span>Define behavior, style, safety, and how declared Powers compose.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/help/">
        <strong>Help</strong>
        <span>Show people what the Assistant can do and what to ask.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/powers/">
        <strong>Powers</strong>
        <span>Declare one safe action with closed input and output.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/secrets/">
        <strong>Secrets</strong>
        <span>Declare public metadata and deliver private values only to the Power that needs them.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/accounts/">
        <strong>Accounts</strong>
        <span>Request reviewed OAuth scopes without collecting provider credentials.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/permissions/">
        <strong>Permissions</strong>
        <span>Understand controller-owned grants and network policy.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/routines/">
        <strong>Routines</strong>
        <span>Understand the boundary for future owner-managed schedules.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/runtime/">
        <strong>Brain runtime</strong>
        <span>Use LangGraph inference without giving the model ambient authority.</span>
      </a>
    </li>
    <li>
      <a class="docs-entry-link" href="/developers/assistants/spec/changelog/">
        <strong>Changelog</strong>
        <span>Explain each published update and notify only the people using it.</span>
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
  <h2 id="assistant-first-project-title">Scaffold and validate one Assistant</h2>
  <p>From a checked-out <code>shimpz-sdk</code> repository with Python 3.14:</p>
  <CodeBlock
    label="Create and validate a minimal Assistant"
    title="Terminal · two commands"
    lines={[
      {
        value:
          "SHIMPZ_LIB=$PWD/rootfs/opt/shimpz-lib python3 rootfs/usr/local/bin/shimpz-assistant new my-assistant /tmp/my-assistant",
      },
      {
        value:
          "SHIMPZ_LIB=$PWD/rootfs/opt/shimpz-lib python3 rootfs/usr/local/bin/shimpz-assistant validate /tmp/my-assistant",
      },
    ]}
  />
  <p>
    Continue with the <a href="/developers/assistants/shimpz-assistant/">Shimpz Assistant walkthrough</a> to call its
    first Power.
  </p>
</section>

<aside class="scope-note" aria-labelledby="assistant-spec-status-title">
  <span id="assistant-spec-status-title" class="kicker">Available today</span>
  <p>
    Spec v2 source validation and the reviewed Shimpz Assistant runtime contract are implemented. Generic
    third-party Store ingestion, generic Service bindings, and routine scheduling are not released yet.
    The manifest exposes requested hosts through <code>allowed_hosts</code>, manual BYOK metadata through
    <code>secrets</code>, and provider OAuth intent through <code>accounts</code>. None grants access by itself;
    network policy, private-value custody, approval, and routines remain controller-owned runtime policy.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant developer guide">
  <a href="/developers/assistants/"><span>Back</span><strong>Assistants overview</strong></a>
  <a href="/developers/assistants/spec/manifest/"><span>Next</span><strong>Project manifest</strong></a>
</nav>
