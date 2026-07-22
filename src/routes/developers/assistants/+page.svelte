<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Assistant project files — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/" />
  <meta name="description" content="Create the files of a Shimpz Assistant SPEC project in small steps." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Developers</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Assistant SPEC</a><span aria-hidden="true">/</span>
  <strong>Project files</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Baby step 1</span>
  <h1>Create four kinds of files</h1>
  <p class="docs-lede">
    Start with the public contract, not with API code. A small Assistant project has one manifest, one
    Genesis document, Help for people, and two schemas for every Power.
  </p>
</header>

<section class="guide-section" aria-labelledby="shape-title">
  <span class="section-label">Folder shape</span>
  <h2 id="shape-title">Give every decision one home</h2>
  <CodeBlock
    label="Small Assistant project"
    title="Project · SPEC files"
    lines={[
      { value: "shimpz.assistant.toml", kind: "output" },
      { value: "GENESIS.md", kind: "output" },
      { value: "help/", kind: "output" },
      { value: "  HELP-en.md", kind: "output" },
      { value: "schemas/", kind: "output" },
      { value: "  inspect-record.input.schema.json", kind: "output" },
      { value: "  inspect-record.output.schema.json", kind: "output" },
    ]}
  />
</section>

<section class="guide-section" aria-labelledby="meaning-title">
  <span class="section-label">What each file answers</span>
  <h2 id="meaning-title">Read the project as four questions</h2>
  <ol>
    <li><strong>Manifest:</strong> What is this Assistant, and what access does it request?</li>
    <li><strong>Genesis:</strong> How should the Brain use its Powers and explain the result?</li>
    <li><strong>Help:</strong> What can a person ask in normal language?</li>
    <li><strong>Schemas:</strong> Which exact JSON may enter and leave each Power?</li>
  </ol>
</section>

<section class="guide-section" aria-labelledby="order-title">
  <span class="section-label">Recommended order</span>
  <h2 id="order-title">Make one Power understandable before adding another</h2>
  <ol>
    <li>Write one sentence describing a useful result.</li>
    <li>Name one Power for that result using lowercase kebab-case.</li>
    <li>Define the smallest possible input and output schemas.</li>
    <li>Add only the Account, Secret, or external host that Power needs.</li>
    <li>Explain the Power in Genesis and show one plain-language prompt in Help.</li>
  </ol>
  <blockquote>Inspect one record by its identifier and return its name and status.</blockquote>
</section>

<aside class="scope-note" aria-labelledby="outside-title">
  <span id="outside-title" class="kicker">Not part of the SPEC</span>
  <p>
    Container orchestration, databases, provider registration, release channels, CI, and Store publishing are
    platform concerns. They do not belong in these files and are not documented as Assistant SPEC fields.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant SPEC">
  <a href="/developers/assistants/spec/"><span>Back</span><strong>SPEC overview</strong></a>
  <a href="/developers/assistants/spec/manifest/"><span>Next</span><strong>Manifest and identity</strong></a>
</nav>
