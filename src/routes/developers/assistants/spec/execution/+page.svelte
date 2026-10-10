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
    <li>It statically extracts the English message catalog without importing Assistant code.</li>
    <li>It generates the canonical machine contract, including that catalog.</li>
    <li>The platform resolves and locks dependencies and creates the runtime/container files.</li>
    <li>
      The platform adds the language pack for the catalog; for a Local snapshot, <code>shimpz assistant stage</code>
      makes it on your machine.
    </li>
    <li>The immutable artifact is admitted against the reviewed manifest, contract, and language pack.</li>
  </ol>
  <p>
    The catalog and language-pack steps require SDK 0.7.1 and CLI 0.9.0 or newer.
  </p>
</section>

<section class="guide-section" aria-labelledby="invoke-title">
  <span class="section-label">One-shot invocation</span>
  <h2 id="invoke-title">Validate before and after execution</h2>
  <ol>
    <li>The Brain selects a reviewed Action and supplies JSON arguments.</li>
    <li>The Controller validates those arguments against the generated input schema.</li>
    <li>
      It writes <code>{`{input, stored_inputs, files, operation_id}`}</code> to bounded stdin.
      <code>stored_inputs</code> is always present: it lists the ids of the Stored Inputs the Action declares whose
      value that Team already keeps, up to eight, and is empty otherwise. No credential is ever part of an invocation:
      Team keeps every Integration token and Stored Input value and adds it to the Action's provider calls itself.
      <code>files</code> is empty unless the Action takes a file, and <code>operation_id</code> names one logical
      operation and stays the same across its replays. A replay also carries the bounded <code>responses</code>
      transcript.
    </li>
    <li>It executes <code>/usr/local/bin/shimpz-action &lt;action-id&gt;</code> in the Assistant runtime.</li>
    <li>The SDK loads the reviewed project, selects the named Action, and runs its async body once.</li>
    <li>The Controller bounds and validates the direct JSON result before the Brain can use it.</li>
  </ol>
  <p>
    Each invocation has an 8-second execution deadline. The encoded request is limited to 512 KiB, or 12 MiB when it
    carries delivered file content, and the direct response to 512 KiB, before schema and private-value validation.
  </p>
</section>

<section class="guide-section" aria-labelledby="routes-call-title">
  <span class="section-label">Provider calls</span>
  <h2 id="routes-call-title">Team checks each credential's routes before it sends a call</h2>
  <p>
    An Action reaches a provider only through <code>await ctx.fetch(...)</code>. Before Team places any Stored Input
    on a call, it matches the call against the
    <a href="/developers/assistants/spec/manifest/#routes-title"><code>routes</code></a> of every Stored Input the
    Action declares for that host.
  </p>
  <ol>
    <li>
      Team reads the path exactly as sent, before the query, and never normalizes it. A path with percent-encoding, an
      empty or <code>.</code> or <code>..</code> segment, a character outside the unreserved set, or a trailing
      <code>/</code> matches no route.
    </li>
    <li>
      A segment that names a credential endpoint, such as <code>api-keys</code> or <code>access_token</code>, is
      refused even where a <code>*</code> would match it.
    </li>
    <li>
      A route matches when its method is the call's method, it has as many segments as the path, and each literal
      equals the call's segment, while each <code>*</code> takes exactly one.
    </li>
    <li>
      On a route with <code>query</code> selectors, the call must carry each selector exactly once, under the exact
      name, with one of the listed raw values. Such a call is also refused when its query contains <code>;</code> or
      a parameter name outside the unreserved set.
    </li>
    <li>
      Every Stored Input declared for the host must admit the call. If one does not, Team sends nothing, places no
      credential, and <code>ctx.fetch</code> raises <code>FetchError</code> with code <code>refused</code>.
    </li>
  </ol>
  <p>
    Widen a route only to an endpoint your Actions actually call, and keep the routes of Stored Inputs that share a
    host identical.
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
  <a href="/developers/assistants/spec/manifest/"><span>Back</span><strong>shimpz.toml</strong></a>
  <a href="/developers/"><span>Overview</span><strong>Creator overview</strong></a>
</nav>
