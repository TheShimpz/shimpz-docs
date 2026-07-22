<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Assistant Power approvals — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/approvals/" />
  <meta name="description" content="Choose never, once, or always approval for each Assistant Power." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant SPEC</a><span aria-hidden="true">/</span><strong>Approvals</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Baby step 5</span>
  <h1>Choose when a person must confirm</h1>
  <p class="docs-lede">
    Approval belongs to each Power, not to the whole Assistant. Pick the strictest policy that still makes the
    intended workflow understandable.
  </p>
</header>

<section class="guide-section" aria-labelledby="values-title">
  <span class="section-label">Three supported values</span>
  <h2 id="values-title">Ask the right number of times</h2>
  <dl>
    <dt><code>never</code></dt>
    <dd>No execution prompt. Use only for reviewed operations with no meaningful side effect.</dd>
    <dt><code>once</code></dt>
    <dd>Ask once for this Power and Assistant release. A new release or revoked grant requires approval again.</dd>
    <dt><code>always</code></dt>
    <dd>Ask before every execution. This is the safe starting point for writes, deletes, sends, and purchases.</dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="example-title">
  <span class="section-label">Example</span>
  <h2 id="example-title">Separate reading from changing</h2>
  <CodeBlock
    label="Different approval policies"
    title="shimpz.assistant.toml"
    lines={[
      { value: "[powers.inspect-record]" },
      { value: 'summary = "Inspect one record."' },
      { value: 'approval = "never"' },
      { value: "" },
      { value: "[powers.update-record]" },
      { value: 'summary = "Change one record after confirmation."' },
      { value: 'approval = "always"' },
    ]}
  />
</section>

<section class="guide-section" aria-labelledby="steps-title">
  <span class="section-label">Decision steps</span>
  <h2 id="steps-title">Classify the real effect, not the HTTP method</h2>
  <ol>
    <li>Can the operation change external or stored state?</li>
    <li>Can it send a message, spend money, publish, revoke, or delete?</li>
    <li>Could repeating it produce a second effect?</li>
    <li>Would a reasonable person expect to review the exact input first?</li>
  </ol>
  <p>If any answer is yes, start with <code>always</code>. Reduce prompts only after a dedicated safety review.</p>
</section>

<aside class="scope-note" aria-labelledby="default-title">
  <span id="default-title" class="kicker">Omitted means never</span>
  <p>
    The manifest schema defaults an omitted <code>approval</code> to <code>never</code>. Write the field explicitly
    anyway: reviewers should not have to remember a security-sensitive default.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant SPEC">
  <a href="/developers/assistants/spec/powers/"><span>Back</span><strong>Powers and schemas</strong></a>
  <a href="/developers/assistants/spec/accounts/"><span>Next</span><strong>Accounts</strong></a>
</nav>
