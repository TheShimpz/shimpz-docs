<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { CodeLine } from "$lib/code";

  const publicCommand: readonly CodeLine[] = [
    { kind: "command", prompt: "$", value: "shimpz check" },
    { kind: "output", prompt: "✓", value: "Assistant is valid." },
    { kind: "command", prompt: "$", value: "shimpz publish --visibility public" },
  ];

  const privateCommand: readonly CodeLine[] = [
    { kind: "command", prompt: "$", value: "shimpz publish --visibility private" },
  ];

  const progressStates = [
    ["queued", "The accepted release is waiting to start."],
    ["resolving", "Dependencies are being resolved and locked."],
    ["building", "The immutable amd64/arm64 image is being built."],
    ["scanning", "The image is being scanned and its SBOM generated."],
    ["signing", "The image and provenance are being signed."],
    ["artifact_ready", "The signed artifact is installable."],
  ] as const;
</script>

<svelte:head>
  <title>Publish a Shimpz Assistant — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/publish/" />
  <meta
    name="description"
    content="Publish a validated Shimpz Assistant as one private or public immutable release."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Creator overview</a><span aria-hidden="true">/</span>
  <strong>Publish</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Creator task · up to 30 minutes</span>
  <h1>Publish one exact Assistant release</h1>
  <p class="docs-lede">
    Validate the current source, choose who can discover it, authorize that immutable release, and wait until its
    signed artifact is installable.
  </p>
</header>

<section class="guide-section" aria-labelledby="before-title">
  <span class="section-label">Before you publish</span>
  <h2 id="before-title">Make identity and behavior final</h2>
  <ul>
    <li>Replace the starter <code>@your-github-username</code> with your verified Creator handle.</li>
    <li>Choose a deliberate, unreleased semantic version in <code>shimpz.toml</code>.</li>
    <li>Test representative Actions and make the manifest, icon, network, and Integration declarations final.</li>
    <li>Run the command from the Assistant project whose exact source you intend to publish.</li>
  </ul>
  <aside class="scope-note" aria-labelledby="immutable-title">
    <span id="immutable-title" class="kicker">Immutable boundary</span>
    <p>
      Creator consent is bound to the exact Assistant id, version, and source digest. Visibility is a separate
      immutable publication setting. Changed source or a different visibility requires a new version; Shimpz does
      not overwrite or reclassify an existing release.
    </p>
  </aside>
</section>

<section class="guide-section" aria-labelledby="visibility-title">
  <span class="section-label">Visibility</span>
  <h2 id="visibility-title">Choose how Teams can discover the release</h2>
  <dl>
    <dt><code>private</code></dt>
    <dd>Unlisted. Only an exact authorized resolution can find and install the release.</dd>
    <dt><code>public</code></dt>
    <dd>Eligible for Store discovery after a separate review approves it.</dd>
  </dl>
  <p>
    Visibility controls discovery, not Team authority. In both cases, the Team verifies and authorizes the exact
    artifact before installation.
  </p>
</section>

<section class="guide-section" aria-labelledby="command-title">
  <span class="section-label">One command</span>
  <h2 id="command-title">Validate, authorize, and publish</h2>
  <CodeBlock label="Public Assistant publication" title="Assistant project" lines={publicCommand} />
  <p>For an unlisted release, choose private explicitly:</p>
  <CodeBlock label="Private Assistant publication" title="Assistant project" lines={privateCommand} />
  <p>
    <code>shimpz publish</code> builds the canonical source package, validates its generated contract, obtains
    <code>identity:read</code> and <code>assistant:publish</code> authorization when needed, records your exact Creator
    consent, submits the release, and waits for its artifact. A separate <code>shimpz auth</code> step is not required.
  </p>
</section>

<aside class="scope-note" aria-labelledby="fraud-title">
  <span id="fraud-title" class="kicker">Stop if the code does not match</span>
  <p>
    Compare the code in your terminal with the browser before authorizing. Continue only for a publication command
    you started, then verify the Assistant id, version, source digest, and Creators shown before consent. A mismatch
    can authorize an attacker to publish as you. Never paste a token or password into the terminal.
  </p>
</aside>

<section class="guide-section" aria-labelledby="progress-title">
  <span class="section-label">Build progress</span>
  <h2 id="progress-title">Wait for one terminal state</h2>
  <p>
    The CLI polls every five seconds, honors server retry timing, and prints a state only when it changes. Normal
    progress is:
  </p>
  <ol>
    {#each progressStates as state}
      <li><code>{state[0]}</code> — {state[1]}</li>
    {/each}
  </ol>
  <p>
    A failed build ends at <code>build_failed</code> with a safe reason and, when available, its build-run link.
    Do not restart a publication while these states are advancing.
  </p>
</section>

<section class="guide-section" aria-labelledby="verify-title">
  <span class="section-label">Verification</span>
  <h2 id="verify-title">Confirm the artifact, not only the upload</h2>
  <p>Publication is complete only when the CLI prints:</p>
  <blockquote><p><code>Assistant published and installable.</code></p></blockquote>
  <p>
    The result includes source and OCI digests, review state, build run, signature, provenance, and the Developers
    portal URL. A private release can be installable without a Store listing. A public release appears in the Store
    only after its review state becomes <code>approved</code>.
  </p>
</section>

<section class="guide-section" aria-labelledby="troubleshooting-title">
  <span class="section-label">Troubleshooting</span>
  <h2 id="troubleshooting-title">Recover without changing the release accidentally</h2>
  <dl>
    <dt><code>creator_consent_required</code></dt>
    <dd>One or more attributed Creators have not consented to this exact id, version, and source digest.</dd>
    <dt><code>version_already_published</code> or <code>visibility_already_set</code></dt>
    <dd>Do not mutate or reclassify that release. Choose a new version for changed source or visibility.</dd>
    <dt>Validation fails before upload</dt>
    <dd>Fix the first reported project field or file, rerun <code>shimpz check</code>, then publish again.</dd>
    <dt>Dependency, test, scan, build, or signing failure</dt>
    <dd>Use the safe failure code and build-run URL. Fix authored source only when the failure belongs to it.</dd>
    <dt>The wait reaches 30 minutes</dt>
    <dd>The CLI instructs you to rerun the same <code>shimpz publish</code> command with unchanged source.</dd>
  </dl>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Creator guide">
  <a href="/developers/assistants/requests/lifecycle/"><span>Back</span><strong>Replay and lifecycle</strong></a>
  <a href="/developers/assistants/spec/"><span>Next</span><strong>Assistant Spec v1</strong></a>
</nav>
