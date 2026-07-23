<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>ctx.human.approval — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/approvals/" />
  <meta name="description" content="Request dynamic human approval inside a Shimpz Power." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v3</a><span aria-hidden="true">/</span>
  <strong>ctx.human.approval</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Human authorization</span>
  <h1>Confirm the exact action at the point of risk</h1>
  <p class="docs-lede">
    <code>ctx.human.approval(...)</code> is a dynamic suspension inside the Power body. Its summary
    can show the real values collected during execution, immediately before a sensitive side effect.
  </p>
</header>

<section class="guide-section" aria-labelledby="runs-title">
  <span class="section-label">Frequency</span>
  <h2 id="runs-title">Choose always or once</h2>
  <dl>
    <dt><code>runs="always"</code></dt>
    <dd>
      Ask on every execution. Start here for writes, deletes, sends, purchases, permission changes,
      and any action whose exact arguments deserve review.
    </dd>
    <dt><code>runs="once"</code></dt>
    <dd>
      Ask once, then reuse a durable grant bound to the Team, Assistant, Power, image release, and
      approval site. Updating the image or revoking the grant requires approval again.
    </dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="example-title">
  <span class="section-label">Example</span>
  <h2 id="example-title">Gather values, approve, then act</h2>
  <CodeBlock label="In-body approval" title="app.py" variant="code" {...data.approval} />
</section>

<section class="guide-section" aria-labelledby="surfaces-title">
  <span class="section-label">Execution surfaces</span>
  <h2 id="surfaces-title">The same challenge works locally and through the Store</h2>
  <p>
    Local Admin chat and hosted Store chat both relay typed approval challenges and resume the
    encrypted continuation. A rejection returns <code>false</code> to the replayed call; the Power
    must stop before the protected effect.
  </p>
</section>

<aside class="scope-note" aria-labelledby="dynamic-title">
  <span id="dynamic-title" class="kicker">No static approval field</span>
  <p>
    Approval does not belong in <code>shimpz.toml</code> or <code>@power</code>. If a Power needs no
    approval, simply omit the call. This keeps authorization next to the action it protects.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/human/"><span>Back</span><strong>ctx.human.request</strong></a>
  <a href="/developers/assistants/spec/accounts/"><span>Next</span><strong>Accounts</strong></a>
</nav>
