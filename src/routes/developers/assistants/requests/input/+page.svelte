<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
  import RequestScreenshot from "$lib/components/RequestScreenshot.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Request input from a Power — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/requests/input/" />
  <meta
    name="description"
    content="Collect text, textarea, password, phone, select, checkbox, or radio input from a Shimpz Power."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/requests/">Power requests</a><span aria-hidden="true">/</span>
  <strong>Inputs</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">request_input</span>
  <h1>Collect one closed field at the moment it matters</h1>
  <p class="docs-lede">
    Build an <code>InputRequest</code> for the narrowest presentation. The Admin or Store renders the native control,
    validates its declared bounds, and returns a string or list of strings only after the human submits it.
  </p>
</header>

<section class="guide-section" aria-labelledby="contract-title">
  <span class="section-label">Return contract</span>
  <h2 id="contract-title">Seven presentations, two result shapes</h2>
  <dl>
    <dt><code>text</code>, <code>textarea</code>, <code>password</code>, <code>phone</code></dt>
    <dd>Return one string inside the declared length bounds.</dd>
    <dt><code>select</code>, <code>choice</code></dt>
    <dd>Return one declared option <code>value</code>. Select is a dropdown; choice is a radio group.</dd>
    <dt><code>choices</code></dt>
    <dd>Returns a list of unique declared option values inside <code>min_selections</code>/<code>max_selections</code>.</dd>
  </dl>
  <p>
    Import <code>InputRequest</code> and, for option controls, <code>InputOption</code> from <code>shimpz</code>. Declare
    each exact kind, such as <code>input:text</code>, in the Power's <code>human_requests</code> list.
  </p>
</section>

<section class="guide-section" aria-labelledby="text-title">
  <span class="section-label">Single line</span>
  <h2 id="text-title">text</h2>
  <p>Use for one short identifier, hostname, label, or other bounded value.</p>
  <CodeBlock label="Short text input" title="Inside a declared Power" variant="code" {...data.text} />
  <RequestScreenshot
    src="/developers/power-requests/input-text.png"
    alt="Power input dialog with a single-line text field"
    caption="text renders one standard single-line field with its required or optional state."
  />
</section>

<section class="guide-section" aria-labelledby="textarea-title">
  <span class="section-label">Long form</span>
  <h2 id="textarea-title">textarea</h2>
  <p>Use for a bounded explanation or note where line breaks help the human communicate clearly.</p>
  <CodeBlock label="Multiline input" title="Inside a declared Power" variant="code" {...data.textarea} />
  <RequestScreenshot
    src="/developers/power-requests/input-textarea.png"
    alt="Power input dialog with a multiline textarea"
    caption="textarea provides a larger multiline editor while preserving the same bounded response contract."
  />
</section>

<section class="guide-section" aria-labelledby="password-title">
  <span class="section-label">Third-party secret</span>
  <h2 id="password-title">password</h2>
  <p>
    Use only for an arbitrary third-party secret intentionally delegated to this exact Assistant Power. The value is
    masked and memory-only. It is never a Shimpz Account password or Local Supervisor password.
  </p>
  <CodeBlock label="Third-party secret input" title="Inside a declared Power" variant="code" {...data.password} />
  <RequestScreenshot
    src="/developers/power-requests/input-password.png"
    alt="Power password input dialog warning that the secret is delivered to the named Assistant"
    caption="The warning names the receiving Assistant and distinguishes this value from Shimpz authentication."
  />
  <aside class="scope-note" aria-labelledby="password-rules-title">
    <span id="password-rules-title" class="kicker">Secret-last rules</span>
    <p>
      Password must be the final human request in the entire Team turn, not merely in this Power. After any Power
      receives one, a later request from any Power in the same turn is blocked. Do not log it, include it in copy,
      return it, place it in an exception, or retain it. Use an OAuth
      <a href="/developers/assistants/spec/integrations/">Integration</a> when the provider supports one.
    </p>
  </aside>
</section>

<section class="guide-section" aria-labelledby="phone-title">
  <span class="section-label">Telephone value</span>
  <h2 id="phone-title">phone</h2>
  <p>Use for one phone number. The specialized control helps entry; your Power still owns domain-specific parsing.</p>
  <CodeBlock label="Phone input" title="Inside a declared Power" variant="code" {...data.phone} />
  <RequestScreenshot
    src="/developers/power-requests/input-phone.png"
    alt="Power input dialog with a telephone field"
    caption="phone renders a telephone-aware field without expanding the wire value beyond one bounded string."
  />
</section>

<section class="guide-section" aria-labelledby="select-title">
  <span class="section-label">One-of dropdown</span>
  <h2 id="select-title">select</h2>
  <p>Use when several compact options fit naturally in a dropdown.</p>
  <CodeBlock label="Select input" title="Inside a declared Power" variant="code" {...data.select} />
  <RequestScreenshot
    src="/developers/power-requests/input-select.png"
    alt="Power input dialog with a select dropdown"
    caption="select returns only the chosen option value, never its display label or description."
  />
</section>

<section class="guide-section" aria-labelledby="choice-title">
  <span class="section-label">One-of visible choices</span>
  <h2 id="choice-title">choice</h2>
  <p>Use when the human should compare all mutually exclusive options and their descriptions at once.</p>
  <CodeBlock label="Radio choice input" title="Inside a declared Power" variant="code" {...data.choice} />
  <RequestScreenshot
    src="/developers/power-requests/input-choice.png"
    alt="Power input dialog with a radio group"
    caption="choice has the same one-value result as select, presented as an accessible radio group."
  />
</section>

<section class="guide-section" aria-labelledby="choices-title">
  <span class="section-label">Many-of choices</span>
  <h2 id="choices-title">choices</h2>
  <p>Use for a bounded set of independent selections. Declare both minimum and maximum intentionally.</p>
  <CodeBlock label="Checkbox choices input" title="Inside a declared Power" variant="code" {...data.choices} />
  <RequestScreenshot
    src="/developers/power-requests/input-choices.png"
    alt="Power input dialog with a checkbox group and selection bounds"
    caption="choices shows the allowed selection count and returns the selected option values in display order."
  />
</section>

<section class="guide-section" aria-labelledby="bounds-title">
  <span class="section-label">Closed bounds</span>
  <h2 id="bounds-title">Reference limits for humans and code generators</h2>
  <ul>
    <li>Title 80, description 500, label 80, and placeholder 120 printable characters.</li>
    <li>Maximum value lengths: text 4096, textarea 16000, password 1024, phone 64.</li>
    <li>Option controls require 2–32 unique options.</li>
    <li>Option value 128, label 80, and optional description 160 printable characters.</li>
    <li><code>required=False</code> permits an empty string for select/choice and zero selections when allowed.</li>
  </ul>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue Power requests">
  <a href="/developers/assistants/requests/approval/"><span>Back</span><strong>Approval</strong></a>
  <a href="/developers/assistants/requests/auth/"><span>Next</span><strong>Authentication</strong></a>
</nav>
