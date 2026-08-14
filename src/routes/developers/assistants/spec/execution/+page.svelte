<svelte:head>
  <title>Action execution model — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/execution/" />
  <meta
    name="description"
    content="Understand platform pre-build and isolated one-shot Action execution."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v1</a><span aria-hidden="true">/</span>
  <strong>Execution model</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Runtime boundary</span>
  <h1>Pre-build once; invoke one Action at a time</h1>
  <p class="docs-lede">
    Creators test source with the CLI. The platform turns that source into an immutable runtime before
    use, then the Controller starts a fresh Action process for each invocation.
  </p>
</header>

<section class="guide-section" aria-labelledby="build-title">
  <span class="section-label">Pre-build</span>
  <h2 id="build-title">Delivery details stay out of the repository</h2>
  <ol>
    <li>The SDK validates <code>shimpz.toml</code> and every direct <code>actions/*.py</code> file.</li>
    <li>It generates the canonical machine contract.</li>
    <li>The platform resolves and locks dependencies and creates the runtime/container files.</li>
    <li>The immutable artifact is admitted against the reviewed manifest and contract.</li>
  </ol>
</section>

<section class="guide-section" aria-labelledby="invoke-title">
  <span class="section-label">One-shot invocation</span>
  <h2 id="invoke-title">Validate before and after execution</h2>
  <ol>
    <li>The Brain selects a reviewed Action and supplies JSON arguments.</li>
    <li>The Controller validates those arguments against the generated input schema.</li>
    <li>
      It resolves only declared Integrations and writes <code>{`{input, integrations}`}</code> to bounded stdin. A
      replay also carries the bounded <code>responses</code> transcript.
    </li>
    <li>It executes <code>/usr/local/bin/shimpz-action &lt;action-id&gt;</code> in the Assistant runtime.</li>
    <li>The SDK loads the reviewed project, selects the named Action, and runs its async body once.</li>
    <li>The Controller bounds and validates the direct JSON result before the Brain can use it.</li>
  </ol>
  <p>
    Each invocation has an 8-second execution deadline. The encoded request and direct response are each limited to
    512 KiB before schema and private-value validation.
  </p>
</section>

<section class="guide-section" aria-labelledby="isolation-title">
  <span class="section-label">Isolation</span>
  <h2 id="isolation-title">Authority stays outside the workload</h2>
  <ul>
    <li>The artifact is pinned by digest and its manifest and generated contract must match review.</li>
    <li>Team identity, OAuth custody, validation, and execution journals remain Controller-owned.</li>
    <li>Integration tokens never travel through the Brain, environment, command arguments, or logs.</li>
    <li>Outbound traffic is limited to reviewed <code>allowed_hosts</code> through authenticated egress.</li>
    <li>Malformed, oversized, unexpected, or private-value-bearing results fail closed.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="process-title">
  <span id="process-title" class="kicker">No authored server</span>
  <p>
    An Assistant does not implement health endpoints, HTTP routing, a daemon, or a Docker entrypoint.
    Its source contract is the manifest plus file-backed Actions.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/network/"><span>Back</span><strong>Network access</strong></a>
  <a href="/developers/assistants/quickstart/"><span>Next</span><strong>Build your first Assistant</strong></a>
</nav>
