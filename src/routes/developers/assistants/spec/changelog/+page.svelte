<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant Changelog — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/changelog/" />
  <meta
    name="description"
    content="Write the required Assistant changelog and understand safe automatic updates and local notifications."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Changelog</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Concept · release communication</span>
  <h1>Explain every update.</h1>
  <p class="docs-lede">
    Every Assistant publish must update the required root <code>CHANGELOG.md</code>. Write only what the
    person using the Assistant needs to understand about the release.
  </p>
</header>

<section class="guide-section" aria-labelledby="changelog-contract-title">
  <span class="section-label">Source contract</span>
  <h2 id="changelog-contract-title">Keep one safe Markdown history</h2>
  <ul>
    <li>Use the exact root filename <code>CHANGELOG.md</code>; no manifest field is needed.</li>
    <li>Write non-empty UTF-8 Markdown and keep the complete file at or below 64 KiB.</li>
    <li>Add a short release heading and concise bullets describing user-visible changes.</li>
    <li>Never include API keys, tokens, passwords, hidden instructions, or other secret material.</li>
    <li>Never include installation commands, container digests, or executable release metadata.</li>
  </ul>
  <p>
    The notification feed applies a tighter 32 KiB limit to each release note. Keep each entry short even
    when the root file contains more than one release.
  </p>
</section>

<section class="guide-section" aria-labelledby="changelog-example-title">
  <span class="section-label">Minimal example</span>
  <h2 id="changelog-example-title">Lead with the newest release</h2>
  <CodeBlock
    label="User-visible release history for Shimpz Assistant"
    title="CHANGELOG.md"
    variant="code"
    {...data.changelog}
  />
</section>

<aside class="scope-note" aria-labelledby="changelog-authority-title">
  <span id="changelog-authority-title" class="kicker">Display only</span>
  <p>
    Changelog text is never installation authority. It cannot choose an image, expand Powers, change allowed
    hosts, grant access, or run a command. The Admin safely renders the supported Markdown subset as HTML;
    raw HTML stays inert and unsafe links are rejected.
  </p>
</aside>

<section class="guide-section" aria-labelledby="changelog-delivery-title">
  <span class="section-label">Updates and notifications</span>
  <h2 id="changelog-delivery-title">Notify only the people using this Assistant</h2>
  <ol>
    <li>After a Space or controller release, the Admin checks its installed Assistants when the owner enters.</li>
    <li>An installed outdated Assistant is replaced with the reviewed immutable release automatically.</li>
    <li>The Admin records the matching changelog notice only after that local Assistant is current.</li>
    <li>Assistants that are not installed in any local Team do not create notifications.</li>
  </ol>
  <p>
    The public release feed is cacheable and conditional; each Admin filters it against its own local
    installations. There is no notification fan-out per installation and no need to report the local
    inventory to Shimpz. If the Admin was closed or offline, it catches up the next time the owner enters.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/runtime/"><span>Back</span><strong>Brain runtime</strong></a>
  <a href="/developers/assistants/spec/build-release/"><span>Next</span><strong>Build and release</strong></a>
</nav>
