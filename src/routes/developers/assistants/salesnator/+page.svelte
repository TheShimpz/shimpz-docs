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
    content="Validate the deterministic, read-only Salesnator campaign-health Assistant reference without live provider credentials."
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
  <span id="salesnator-status-title" class="kicker">No live account</span>
  <p>
    This reference does not connect to Meta Ads, Telegram, Cloudflare, or a customer account. It validates
    the Assistant source contract and local Power behavior. Service binding, persistent notification
    deduplication, scheduling, and delivery are future controller work.
  </p>
</aside>

<section class="guide-section" aria-labelledby="salesnator-boundary-title">
  <span class="section-label">Authority</span>
  <h2 id="salesnator-boundary-title">Ask Services for two narrow operations</h2>
  <ul>
    <li><code>meta-ads.read</code> represents a mediated, read-only campaign snapshot.</li>
    <li><code>notifications.send</code> represents one owner notification request.</li>
    <li><code>customer-ad-account</code> and <code>owner-channel</code> are opaque binding names, not keys.</li>
    <li>The Assistant declares <code>allowed_hosts = []</code> and never receives a provider credential.</li>
    <li>No update, publish, budget, ad, ad-set, or campaign mutation Service operation or Power is declared.</li>
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
    <code>false</code>. The example proves that behavior in one process; a future controller and Notifications
    Service must persist the idempotency key across restarts.
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
    real loopback HTTP server, prove the closed route, and verify notification deduplication.
  </p>
</section>

<section class="guide-section" aria-labelledby="salesnator-routine-title">
  <span class="section-label">Routine</span>
  <h2 id="salesnator-routine-title">Keep campaign-watch owner-disabled</h2>
  <p>
    The manifest requests <code>campaign-watch</code> every 3,600 seconds with timeout, jitter,
    single-flight, and a scheduled-time idempotency key. It starts disabled. The SDK validates those fields;
    it does not schedule the Power or grant either Service capability.
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
