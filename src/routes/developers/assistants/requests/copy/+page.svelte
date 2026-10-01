<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Write request copy for every interface language — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/requests/copy/" />
  <meta
    name="description"
    content="Write Action request copy with shimpz.text and typed parameters so Shimpz shows it in each person's interface language."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/requests/">Human requests</a><span aria-hidden="true">/</span>
  <strong>Request copy</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">shimpz.text reference</span>
  <h1>Write request copy once, in English, for every interface language</h1>
  <p class="docs-lede">
    Every title, description, label, placeholder, and option a human request shows is an English message written with
    <code>shimpz.text</code>. Shimpz translates each distinct message once and Team shows it in the language the
    person chose for the Admin interface.
  </p>
</header>

<aside class="scope-note" aria-labelledby="availability-title">
  <span id="availability-title" class="kicker">Not released yet</span>
  <p>
    This page describes SDK 0.5.0 and the CLI release that adds <code>shimpz assistant prepare</code>. Neither is
    released yet: the released SDK and CLI do not provide <code>shimpz.text</code>, language packs, or translated
    request copy.
  </p>
</aside>

<section class="guide-section" aria-labelledby="example-title">
  <span class="section-label">Practical example</span>
  <h2 id="example-title">Write the template, then type every value it inserts</h2>
  <CodeBlock label="Illustrative catalog request copy" title="actions/publish_changes.py" variant="code" {...data.copy} />
  <p>
    A plain string is refused wherever request copy is expected. The template is the message: its exact text is
    hashed, translated once, and reused by every Assistant that writes the same English. The final provider helper is
    illustrative Creator code.
  </p>
</section>

<section class="guide-section" aria-labelledby="template-title">
  <span class="section-label">Templates</span>
  <h2 id="template-title">One literal English sentence per meaning</h2>
  <ul>
    <li>
      Write the template as an English, NFC-normalized string literal directly inside the call. Adjacent string
      literals in the call form one literal.
    </li>
    <li>
      A placeholder is a <code>{"{name}"}</code> field whose name matches <code>[a-z][a-z0-9_]{"{0,31}"}</code>. Use
      each placeholder once, supply exactly one keyword parameter for each, and use at most 8.
    </li>
    <li>
      Attribute or index access, conversions, format specifications, nested or positional fields, and literal braces
      are refused, as is a combining mark directly after a placeholder.
    </li>
    <li>
      There is no plural or context syntax. Write count-neutral, self-explanatory copy such as
      <code>Records to delete: {"{count}"}.</code>
    </li>
    <li>Prose that varies, such as a mode or an outcome, needs one separate message per variant.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="params-title">
  <span class="section-label">Typed parameters</span>
  <h2 id="params-title">A parameter is a bounded value, never prose</h2>
  <dl>
    <dt><code>integer(value, digits=N)</code></dt>
    <dd>A non-negative integer of at most <code>N</code> decimal digits, where <code>N</code> is at most 15.</dd>
    <dt><code>domain(value, max_length=N)</code></dt>
    <dd>
      A lowercase DNS hostname of at least two labels, using letters, digits, and inner hyphens.
      <code>max_length</code> defaults to and may not exceed 253.
    </dd>
    <dt><code>identifier(value, max_length=N)</code></dt>
    <dd>
      An opaque value that starts with a letter or digit and continues with letters, digits, <code>.</code>,
      <code>_</code>, <code>:</code>, or <code>-</code>, of at most <code>N</code> characters, where <code>N</code> is at
      most 128.
    </dd>
  </dl>
  <p>
    Write each helper directly as a <code>text()</code> keyword argument with a literal maximum. Shimpz inserts the
    value exactly once, never translates or interprets it, and never sends it to the translator. A value outside its
    kind's form or maximum fails the request, so constrain the Action input to the parameter's form or choose a
    separate message. For example, a DNS record name with a leading underscore or a wildcard is neither a
    <code>domain</code> nor an <code>identifier</code>.
  </p>
</section>

<section class="guide-section" aria-labelledby="budget-title">
  <span class="section-label">Budgets</span>
  <h2 id="budget-title">Every message fits its field before it runs</h2>
  <p>
    The template's literal characters plus the declared maximum of every parameter must fit the field: 80 characters
    for a title, label, or option label, 120 for a placeholder, 160 for an option description, and 500 for a
    description. The rendered copy is checked again after insertion and is never truncated.
  </p>
  <p>
    A <code>text()</code> call written directly as a request argument takes that field's bound. A call anywhere else
    needs a literal <code>max_length</code> of 80, 120, 160, or 500, and can then be used only in fields at least that
    large:
  </p>
  <CodeBlock label="Messages chosen before the request" title="Inside a declared Action" variant="code" {...data.reused} />
  <p>
    A message used in several fields must fit the smallest of them. The manifest <code>summary</code> joins the same
    catalog with a 160-character bound, so it cannot contain braces.
  </p>
</section>

<section class="guide-section" aria-labelledby="extract-title">
  <span class="section-label">Static extraction</span>
  <h2 id="extract-title">Shimpz reads the catalog without running your code</h2>
  <p>
    Before any Assistant code is imported, the SDK reads every <code>actions/*.py</code> file and every
    <code>lib/**/*.py</code> file and collects each <code>text()</code> call. Import the names with
    <code>from shimpz import text, integer, domain, identifier</code> or call <code>shimpz.text(...)</code> after
    <code>import shimpz</code>. These forms fail with a <code>file:line</code> diagnostic:
  </p>
  <CodeBlock label="Refused request copy" title="Refused forms" variant="code" {...data.refused} />
  <p>
    Importing <code>text</code> under another name or from another module, calling it through
    <code>import shimpz as ...</code>, and a local name that hides an imported <code>text</code>,
    <code>integer</code>, <code>domain</code>, or <code>identifier</code> are refused as well. Rename the local
    variable instead.
  </p>
</section>

<section class="guide-section" aria-labelledby="translation-title">
  <span class="section-label">Translation</span>
  <h2 id="translation-title">Eight interface languages from one English catalog</h2>
  <p>
    English is the catalog. Shimpz translates each message into Arabic (<code>ar</code>), German (<code>de</code>),
    Spanish (<code>es</code>), French (<code>fr</code>), Japanese (<code>ja</code>), Portuguese (<code>pt</code>), and
    Chinese (<code>zh</code>), and keeps the result for that exact message, so a later preparation or publication
    that reuses the message does not translate it again. A translation is admitted only when it keeps exactly the template's placeholders and fits the
    message's bound; there is no human review queue, so an automatic translation can still be imperfect.
  </p>
  <p>
    Request kinds, option values, parameters, Assistant and Action names, identifiers, URLs, scopes, schema values,
    and Genesis are never translated. Stored Input <code>label</code> and <code>description</code> declarations in
    <code>shimpz.toml</code> stay as written.
  </p>
</section>

<section class="guide-section" aria-labelledby="generated-title">
  <span class="section-label">Generated files</span>
  <h2 id="generated-title">You own the source; Shimpz owns the catalog and the pack</h2>
  <dl>
    <dt>Message catalog</dt>
    <dd>
      The generated contract lists every message as <code>{"{id, msgid, max_length, params}"}</code>, where
      <code>id</code> is the SHA-256 of the message's UTF-8 bytes. It is derived on every check, run, stage, and build.
    </dd>
    <dt>Language pack</dt>
    <dd>
      For a Local snapshot, <code>shimpz assistant prepare</code> keeps it in the CLI cache. For a publication, the
      build places it in the final image. It is never part of the source package.
    </dd>
  </dl>
  <p>
    Do not write, commit, or edit a catalog, contract, or pack in the Assistant repository. Change the
    <code>text()</code> calls instead; <a href="/developers/assistants/local/">Test in Local</a> shows when to prepare
    again.
  </p>
</section>

<section class="guide-section" aria-labelledby="run-title">
  <span class="section-label">Canonical requests</span>
  <h2 id="run-title">The request is the same in every language</h2>
  <p>
    Each copy field travels as a reference, <code>{'{"message": id, "params": {...}}'}</code>. Its fingerprint covers
    the references and parameter values, never the display language. <code>shimpz assistant run</code> shows the
    English rendering in your terminal; Team renders the person's interface language.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue human requests">
  <a href="/developers/assistants/requests/"><span>Back</span><strong>Overview</strong></a>
  <a href="/developers/assistants/requests/approval/"><span>Next</span><strong>Approval</strong></a>
</nav>
