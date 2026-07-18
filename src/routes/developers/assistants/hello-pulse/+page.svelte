<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Hello Pulse Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/hello-pulse/" />
  <meta
    name="description"
    content="Create, validate, and run the minimal Hello Pulse Assistant locally with the Shimpz SDK."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span><strong>Hello Pulse</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Executable source reference</span>
  <h1>Build Hello Pulse.</h1>
  <p class="docs-lede">
    Generate one dependency-free Assistant, validate its complete source contract, then call its only
    Power on your own machine.
  </p>
</header>

<aside class="scope-note" aria-labelledby="hello-pulse-boundary-title">
  <span id="hello-pulse-boundary-title" class="kicker">Local proof</span>
  <p>
    The source steps below prove the SDK and process directly. The packaged release can also be installed
    into one local Team through the Admin's narrowly allowlisted evaluation flow. Neither path enables
    its routine or proves general capability and scheduling support.
  </p>
</aside>

<section class="guide-section" aria-labelledby="hello-install-title">
  <span class="section-label">Published evaluation</span>
  <h2 id="hello-install-title">Install the immutable release in a Team</h2>
  <p>
    Install Shimpz, create an empty Team, then let the local Admin install the exact Hello Pulse release.
    The Store can suggest this Assistant, but only the local Captain chooses the Team and authorizes the
    install. Installation itself does not invoke the <code>hello</code> Power.
  </p>
  <p><a href="/assistants/">Follow the first Assistant guide</a>.</p>
</section>

<ol class="step-list">
  <li>
    <h2>Check Python</h2>
    <p>From a checked-out <code>shimpz-sdk</code> repository, confirm the standard interpreter:</p>
    <CodeBlock
      label="Check the Assistant SDK Python version"
      title="Terminal · Python"
      lines={[{ value: "python3 --version" }, { value: "Python 3.14.x", kind: "output" }]}
    />
  </li>

  <li>
    <h2>Create the project</h2>
    <p>The scaffolder publishes atomically and refuses to overwrite an existing destination.</p>
    <CodeBlock
      label="Scaffold Hello Pulse"
      title="Terminal · Assistant scaffold"
      lines={[
        {
          value:
            "SHIMPZ_LIB=$PWD/rootfs/opt/shimpz-lib python3 rootfs/usr/local/bin/shimpz-assistant new hello-pulse /tmp/hello-pulse",
        },
      ]}
    />
  </li>

  <li>
    <h2>Validate every reference</h2>
    <p>
      Validation reads the manifest, Rules, and Power schemas without printing permissions or source
      values back to the terminal.
    </p>
    <CodeBlock
      label="Validate the Hello Pulse project"
      title="Terminal · Assistant validation"
      lines={[
        {
          value:
            "SHIMPZ_LIB=$PWD/rootfs/opt/shimpz-lib python3 rootfs/usr/local/bin/shimpz-assistant validate /tmp/hello-pulse",
        },
      ]}
    />
  </li>

  <li>
    <h2>Start the development server</h2>
    <p>The reference server binds to loopback by default and exposes only health and <code>hello</code>.</p>
    <CodeBlock
      label="Run Hello Pulse locally"
      title="Terminal one · Hello Pulse"
      lines={[
        { value: "cd /tmp/hello-pulse" },
        { value: "PORT=8080 python3 assistant/main.py" },
      ]}
    />
  </li>

  <li>
    <h2>Call the declared Power</h2>
    <p>
      In a second terminal. The <code>/v1/powers/hello</code> route is the fixed compatibility adapter
      for the <code>hello</code> Power, not a generic route the manifest or model can choose.
    </p>
    <CodeBlock
      label="Call the Hello Pulse Power"
      title="Terminal two · Power call"
      lines={[
        { value: "curl -fsS http://127.0.0.1:8080/health" },
        {
          value:
            "curl -fsS -H 'content-type: application/json' -d '{\"name\":\"Ada\"}' http://127.0.0.1:8080/v1/powers/hello",
        },
      ]}
    />
    <CodeBlock
      label="Hello Pulse Power response"
      title="Response · JSON"
      variant="code"
      {...data.response}
    />
  </li>
</ol>

<section class="guide-section" aria-labelledby="hello-proof-title">
  <span class="section-label">Result</span>
  <h2 id="hello-proof-title">What you have proved</h2>
  <ul>
    <li>The scaffold is a valid Assistant Spec v2 source tree.</li>
    <li>The process has no dependency, credential, Service permission, Assistant permission, or egress.</li>
    <li>Unknown fields, undeclared Powers, oversized bodies, and malformed JSON fail closed.</li>
    <li>The declared routine remains disabled because no local server silently schedules it.</li>
  </ul>
  <p>
    Read the <a
      class="external-link"
      href="https://github.com/roxygens/shimpz-sdk/tree/main/examples/hello-pulse"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Hello Pulse source on GitHub (opens in a new tab)">complete Hello Pulse source</a
    >.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant developer guide">
  <a href="/developers/assistants/spec/build-release/"><span>Back to</span><strong>Build and release</strong></a>
  <a href="/developers/assistants/salesnator/"><span>Next</span><strong>Salesnator</strong></a>
</nav>
