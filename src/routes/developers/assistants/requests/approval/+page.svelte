<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
  import RequestScreenshot from "$lib/components/RequestScreenshot.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Request approval from an Action — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/requests/approval/" />
  <meta name="description" content="Ask an authenticated human to approve one fully described Action action." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/requests/">Action requests</a><span aria-hidden="true">/</span>
  <strong>Approval</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">request_approval</span>
  <h1>Ask before one externally visible action</h1>
  <p class="docs-lede">
    Use approval when the Action already has every value it needs, but the human must explicitly authorize the
    described action. Approval is attributable, one-use, and bound to this exact Assistant, Action, and request.
  </p>
</header>

<section class="guide-section" aria-labelledby="example-title">
  <span class="section-label">Practical example</span>
  <h2 id="example-title">Describe the action, then perform it</h2>
  <CodeBlock label="Approval before a DNS write" title="actions/publish_dns.py" variant="code" {...data.approval} />
  <p>
    <code>request_approval</code> returns <code>None</code> only after approval. Do not branch on a Boolean result:
    denial, dismissal, cancellation, or expiry terminates the Action and never reaches the next line.
  </p>
  <RequestScreenshot
    src="/developers/action-requests/approval.png"
    alt="Approval dialog identifying Shimpz Cloudflare and its List reviewed Cloudflare zones Action"
    caption="Rendered Admin experience. The human sees the exact Assistant, Action, action, and expiry before choosing."
  />
</section>

<section class="guide-section" aria-labelledby="copy-title">
  <span class="section-label">Request copy</span>
  <h2 id="copy-title">Make the consequence obvious without hidden context</h2>
  <ul>
    <li><code>title</code>: an imperative summary of the action, at most 80 printable characters.</li>
    <li><code>description</code>: the target, scope, and consequence, at most 500 printable characters.</li>
    <li>Do not place secrets, tokens, internal prompts, or raw payloads in either field.</li>
    <li>Do not describe several unrelated effects behind one approval.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="approval-boundary-title">
  <span id="approval-boundary-title" class="kicker">Approval is not authentication</span>
  <p>
    Approval records intent; it does not prove that the human recently used a platform factor. For a sensitive
    action that needs fresh assurance, request <a href="/developers/assistants/requests/auth/">authentication</a>
    after collecting non-secret inputs and before the action.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue Action requests">
  <a href="/developers/assistants/requests/"><span>Back</span><strong>Overview</strong></a>
  <a href="/developers/assistants/requests/input/"><span>Next</span><strong>Inputs</strong></a>
</nav>
