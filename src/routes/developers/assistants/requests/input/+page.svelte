<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
  import RequestExample from "$lib/components/RequestExample.svelte";
  import { inputExamples } from "$lib/actionRequestExamples";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Request input from an Action — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/requests/input/" />
  <meta
    name="description"
    content="Collect text, textarea, password, phone, select, choice, or choices input from a Shimpz Action."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/requests/">Human requests</a><span aria-hidden="true">/</span>
  <strong>Inputs</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">request_input</span>
  <h1>Collect one closed field at the moment it matters</h1>
  <p class="docs-lede">
    Build an <code>InputRequest</code> for the narrowest presentation. Local Admin renders the native control,
    validates its declared bounds, and returns a string or list of strings only after the human submits it.
  </p>
</header>

<aside class="scope-note" aria-labelledby="input-fragments-title">
  <span id="input-fragments-title" class="kicker">Illustrative fragments</span>
  <p>
    The snippets below belong inside a declared Action; imports, the decorator, and the surrounding async function
    are omitted.
  </p>
</aside>

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
    Import <code>InputRequest</code>, <code>text</code>, and, for option controls, <code>InputOption</code> from
    <code>shimpz</code>. Every title, description, label, placeholder, and option label or description is
    <a href="/developers/assistants/requests/copy/"><code>shimpz.text</code> request copy</a>; option values stay
    canonical and are never translated. Declare each exact kind, such as <code>input:text</code>, in the Action's
    <code>human_requests</code> list.
  </p>
  <RequestExample id="input" examples={inputExamples} />
</section>

<section class="guide-section" aria-labelledby="text-title">
  <span class="section-label">Single line</span>
  <h2 id="text-title">text</h2>
  <p>Use for one short identifier, hostname, label, or other bounded value.</p>
  <CodeBlock label="Short text input" title="Inside a declared Action" variant="code" {...data.text} />
</section>

<section class="guide-section" aria-labelledby="textarea-title">
  <span class="section-label">Long form</span>
  <h2 id="textarea-title">textarea</h2>
  <p>Use for a bounded explanation or note where line breaks help the human communicate clearly.</p>
  <CodeBlock label="Multiline input" title="Inside a declared Action" variant="code" {...data.textarea} />
</section>

<section class="guide-section" aria-labelledby="password-title">
  <span class="section-label">Third-party secret</span>
  <h2 id="password-title">password</h2>
  <p>
    Use only for a third-party credential intentionally delegated to this Assistant. The value is masked and is never a
    Shimpz Account password or Local Supervisor password. Every password request names a declared Stored Input with
    <code>stored_input="&lt;id&gt;"</code>: Team keeps the value encrypted under that Team as soon as the person enters
    it, never asks for it again, and never gives it to the Action. Instead, Team places it where the Stored Input's
    <a href="/developers/assistants/spec/manifest/#access-title">placement</a> says in every
    <code>ctx.fetch</code> call to that host that its reviewed
    <a href="/developers/assistants/spec/manifest/#routes-title"><code>routes</code></a> admit. An Action may declare
    several Stored Inputs, such as an access token and
    an app secret; request them together with <code>ctx.request_stored_inputs(...)</code>, which asks for each missing
    one in turn and returns once Team holds all of them. Call <code>ctx.reject_stored_input(id)</code> for exactly the value the provider rejected;
    Team deletes only that one and the next run asks for it again. Uninstalling the Assistant or deleting the Team
    removes them. Every Stored Input declares a help-text <code>description</code> and a
    <a href="/developers/assistants/spec/manifest/#access-title"><code>help_url</code></a>: wherever Admin asks for
    the value, and on the Assistant's page, the person reads in their own language what the secret is and how to get
    it, followed by one link to the page where it is made.
  </p>
  <CodeBlock label="Third-party secret input" title="Inside a declared Action" variant="code" {...data.password} />
  <aside class="scope-note" aria-labelledby="password-rules-title">
    <span id="password-rules-title" class="kicker">Request before calls</span>
    <p>
      Request every Stored Input before the Action's first provider call: no human request may follow a call. Never
      put a credential in copy, input, or source. Use an OAuth
      <a href="/developers/assistants/spec/integrations/">Integration</a> when the provider supports one.
    </p>
  </aside>
</section>

<section class="guide-section" aria-labelledby="phone-title">
  <span class="section-label">Telephone value</span>
  <h2 id="phone-title">phone</h2>
  <p>Use for one phone number. The specialized control helps entry; your Action still owns domain-specific parsing.</p>
  <CodeBlock label="Phone input" title="Inside a declared Action" variant="code" {...data.phone} />
</section>

<section class="guide-section" aria-labelledby="select-title">
  <span class="section-label">One-of dropdown</span>
  <h2 id="select-title">select</h2>
  <p>Use when several compact options fit naturally in a dropdown.</p>
  <CodeBlock label="Select input" title="Inside a declared Action" variant="code" {...data.select} />
</section>

<section class="guide-section" aria-labelledby="choice-title">
  <span class="section-label">One-of visible choices</span>
  <h2 id="choice-title">choice</h2>
  <p>Use when the human should compare all mutually exclusive options and their descriptions at once.</p>
  <CodeBlock label="Radio choice input" title="Inside a declared Action" variant="code" {...data.choice} />
</section>

<section class="guide-section" aria-labelledby="choices-title">
  <span class="section-label">Many-of choices</span>
  <h2 id="choices-title">choices</h2>
  <p>Use for a bounded set of independent selections. Declare both minimum and maximum intentionally.</p>
  <CodeBlock label="Checkbox choices input" title="Inside a declared Action" variant="code" {...data.choices} />
</section>

<section class="guide-section" aria-labelledby="bounds-title">
  <span class="section-label">Closed bounds</span>
  <h2 id="bounds-title">Reference limits for humans and code generators</h2>
  <ul>
    <li>
      Title 80, description 500, label 80, and placeholder 120 characters, counting each parameter at its declared
      maximum.
    </li>
    <li>Maximum value lengths: text 4096, textarea 16000, password 1024, phone 64.</li>
    <li>Option controls require 2–32 unique options.</li>
    <li>Option value 128, label 80, and optional description 160 characters.</li>
    <li><code>required=False</code> permits an empty string for select/choice and zero selections when allowed.</li>
  </ul>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue human requests">
  <a href="/developers/assistants/requests/approval/"><span>Back</span><strong>Approval</strong></a>
  <a href="/developers/assistants/requests/auth/"><span>Next</span><strong>Authentication</strong></a>
</nav>
