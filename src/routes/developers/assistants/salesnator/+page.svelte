<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Salesnator Assistant reference — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/salesnator/" />
  <meta
    name="description"
    content="Understand a deterministic Salesnator Power that uses no Account, Secret, network host, or live provider data."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span><strong>Salesnator</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Read-only source reference</span>
  <h1>Prove Salesnator safely.</h1>
  <p class="docs-lede">
    Evaluate one synthetic Meta Ads campaign snapshot, produce a deterministic recommendation, and request
    at most one owner notification for the same run—without a provider token or campaign mutation.
  </p>
</header>

<aside class="scope-note" aria-labelledby="salesnator-status-title">
  <span id="salesnator-status-title" class="kicker">Current v2 fixture</span>
  <p>
    This reference declares one <code>campaign-health</code> Power and no Account, Secret, or allowed host.
    It evaluates synthetic input locally. It does not connect to Meta Ads, send a notification, or mutate a
    campaign.
  </p>
</aside>

<section class="guide-section" aria-labelledby="salesnator-boundary-title">
  <span class="section-label">Manifest</span>
  <h2 id="salesnator-boundary-title">Read its authority literally</h2>
  <ul>
    <li><code>[powers.campaign-health]</code> admits only the conventional closed input and output schemas.</li>
    <li><code>allowed_hosts = []</code> means the Power receives no internet route.</li>
    <li>No <code>[accounts.*]</code> table means Shimpz starts no OAuth consent or token delivery.</li>
    <li>No <code>[secrets.*]</code> table means the Admin collects and delivers no manual credential.</li>
    <li>The notification object in the result is an intent for inspection, not evidence of delivery.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="salesnator-fixture-title">
  <span class="section-label">Synthetic proof</span>
  <h2 id="salesnator-fixture-title">Make the failure case deterministic</h2>
  <p>
    The campaign and ad set are active, the ad has issues, spend is 12,000 cents, and leads are zero. No
    customer identifier, creative, audience, token, or personal data is present.
  </p>
  <CodeBlock
    label="Synthetic Salesnator campaign-health fixture"
    title="campaign-health.json"
    variant="code"
    {...data.fixture}
  />
  <p>The Power returns the same core verdict every time:</p>
  <CodeBlock
    label="Expected Salesnator campaign-health verdict"
    title="campaign-health verdict · JSON"
    variant="code"
    {...data.verdict}
  />
  <p>
    A repeated <code>run_id</code> keeps the verdict unchanged and sets <code>notification.enqueued</code> to
    <code>false</code>. The example proves only in-process deduplication; durable delivery and deduplication are
    not part of this fixture.
  </p>
</section>

<section class="guide-section" aria-labelledby="salesnator-run-title">
  <span class="section-label">Validation</span>
  <h2 id="salesnator-run-title">Run the complete local proof</h2>
  <p>From a checked-out <code>shimpz-sdk</code> repository:</p>
  <CodeBlock
    label="Validate and test the Salesnator reference"
    title="Terminal · Salesnator"
    lines={[
      {
        value:
          "SHIMPZ_LIB=$PWD/rootfs/opt/shimpz-lib python3 rootfs/usr/local/bin/shimpz-assistant validate examples/salesnator/shimpz.assistant.toml",
      },
      {
        value:
          "PYTHONPATH=examples/salesnator python3 -m unittest discover -s examples/salesnator/tests",
      },
    ]}
  />
  <p>
    The tests use no provider, network mock, monkeypatch, or customer data. They execute the processor and a
    real loopback HTTP server, prove the closed Power route, and verify the deterministic result.
  </p>
</section>

<section class="guide-section" aria-labelledby="salesnator-routine-title">
  <span class="section-label">Future integration</span>
  <h2 id="salesnator-routine-title">Add authority only when it exists</h2>
  <p>
    A later live version may declare a provider <a href="/developers/assistants/spec/accounts/">Account</a>
    for controller-owned OAuth, or named <a href="/developers/assistants/spec/secrets/">Secrets</a> when manual
    BYOK is unavoidable. Each Power must reference only what it needs and list every exact public host it may
    call. Scheduling and notification delivery are not creator-controlled Assistant Spec v2 fields.
  </p>
  <p>
    Read the <a
      class="external-link"
      href="https://github.com/roxygens/shimpz-sdk/tree/main/examples/salesnator"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Salesnator source on GitHub (opens in a new tab)">complete Salesnator source</a
    >.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant developer guide">
  <a href="/developers/assistants/shimpz-assistant/"><span>Back</span><strong>Shimpz Assistant</strong></a>
  <a href="/developers/services/"><span>Related</span><strong>Services</strong></a>
</nav>
