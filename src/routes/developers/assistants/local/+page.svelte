<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { CodeLine } from "$lib/code";

  const validate: readonly CodeLine[] = [
    { kind: "command", prompt: "$", value: "shimpz assistant check" },
    { kind: "output", prompt: "✓", value: "Assistant is valid." },
  ];

  const stage: readonly CodeLine[] = [
    { kind: "command", prompt: "$", value: "shimpz assistant stage" },
    { kind: "output", prompt: "›", value: "Local Assistant snapshot staged." },
    { kind: "output", prompt: "›", value: "Assistant: <assistant-id> <version>" },
    { kind: "output", prompt: "›", value: "Image: sha256:<64 hexadecimal characters>" },
    {
      kind: "output",
      prompt: "›",
      value: "Next: open Local Admin and install this unpublished snapshot for a Team.",
    },
  ];
</script>

<svelte:head>
  <title>Test an unpublished Assistant in Local — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/local/" />
  <meta
    name="description"
    content="Stage and install an unpublished Assistant snapshot in one Local Shimpz Space before publication."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/">Creator overview</a><span aria-hidden="true">/</span>
  <strong>Test in Local</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Creator task · about 10 minutes</span>
  <h1>Run an unpublished Assistant through your Local Team</h1>
  <p class="docs-lede">
    Stage one exact snapshot on your machine, authorize it for a Team in Local Admin, and exercise its normal
    Actions before you publish—or keep it local permanently.
  </p>
</header>

<aside class="scope-note" aria-labelledby="before-title">
  <span id="before-title" class="kicker">Before you start</span>
  <p>
    You need a running Local Space, its MFA-enabled Supervisor, the current native <code>shimpz</code> CLI, Docker,
    and an Assistant project you trust. Run every terminal command from that independent Assistant repository.
  </p>
</aside>

<section class="guide-section" aria-labelledby="validate-title">
  <span class="section-label">1 · Validate</span>
  <h2 id="validate-title">Check the complete project first</h2>
  <CodeBlock label="Validate the Assistant project" title="Assistant project" lines={validate} />
  <p>
    Fix the first reported error before continuing. This check validates the source package and generated machine
    contract; it does not install or publish anything.
  </p>
</section>

<section class="guide-section" aria-labelledby="stage-title">
  <span class="section-label">2 · Stage</span>
  <h2 id="stage-title">Build one exact snapshot in your Docker daemon</h2>
  <CodeBlock label="Stage an unpublished Local snapshot" title="Assistant project" lines={stage} />
  <p>
    The values inside angle brackets vary. Save the complete <code>sha256:</code> image ID: it is the immutable
    identity you will authorize. To stage a different working directory, run
    <code>shimpz assistant stage --project /path/to/assistant</code>.
  </p>
  <p>
    A successful stage leaves one untagged image in the host Docker daemon. Repeating the command for unchanged
    source reuses the exact snapshot; changed source uses the layer cache and produces a new image ID.
  </p>
</section>

<aside class="scope-note" aria-labelledby="trust-title">
  <span id="trust-title" class="kicker">Local trust boundary</span>
  <p>
    A Docker-authorized local principal can stage code, but only the MFA-authenticated Local Supervisor can bind the
    exact displayed image to a Team. Shimpz has not published, reviewed, signed, or scanned this snapshot. Install
    only code you trust on this machine.
  </p>
</aside>

<section class="guide-section" aria-labelledby="install-title">
  <span class="section-label">3 · Install</span>
  <h2 id="install-title">Authorize the exact image for one Team</h2>
  <ol>
    <li>Open the Local Admin address printed by your installation, normally <code>https://local.shimpz.com</code>.</li>
    <li>Sign in as Supervisor and complete the required TOTP factor.</li>
    <li>Open <strong>Assistants</strong> and select the destination Team.</li>
    <li>
      Find the Assistant card marked <strong>LOCAL</strong>. If the same Assistant is published, the Local card is
      the only version shown on this machine.
    </li>
    <li>Select <strong>Install or replace</strong>.</li>
    <li>
      In the dialog, read the unpublished-code disclosure, compare the complete image ID, and confirm that exact
      snapshot.
    </li>
  </ol>
  <p>
    Success is visible as <strong>Local Assistant installed</strong>. Team admits the embedded manifest, contract,
    source package, icon, platform, and runtime before it starts the workload. A failed install does not authorize a
    partial snapshot. A failed Local-to-Local replacement leaves the current Assistant in place. Replacing a
    published Assistant first admits the Local snapshot, then removes all published Team state and creates a fresh
    Local binding; if that final install fails, the Assistant is absent and you can safely retry the same snapshot.
  </p>
</section>

<section class="guide-section" aria-labelledby="exercise-title">
  <span class="section-label">4 · Exercise</span>
  <h2 id="exercise-title">Use the same Action path as an installed Assistant</h2>
  <p>
    Open the destination Team and request work supported by one declared Action. Verify the Team's complete response
    and the external result when the Action has one. Normal egress, Action validation, human requests, audit,
    Integrations, and Stored Input boundaries apply after admission.
  </p>
  <p>
    Staging never asks for provider access. An OAuth Integration is configured only when its Action needs it. A
    declared Stored Input—such as a WhatsApp token—is requested just in time and retained under that Team's custody
    instead of being requested on every run.
  </p>
</section>

<section class="guide-section" aria-labelledby="iterate-title">
  <span class="section-label">Iterate</span>
  <h2 id="iterate-title">Restage changed source, then replace deliberately</h2>
  <ol>
    <li>Edit the Assistant and rerun <code>shimpz assistant check</code>.</li>
    <li>Run <code>shimpz assistant stage</code> and record the new image ID.</li>
    <li>
      Reload the Assistants page in Admin, compare that ID in the install dialog, and select
      <strong>Install or replace</strong>.
    </li>
    <li>Exercise the changed Action again through the Team.</li>
  </ol>
  <p>
    A successful replacement may remove the old image only after no binding or container references it. If the
    successor fails, the current binding and the newly staged image remain so you can inspect or retry them.
  </p>
</section>

<section class="guide-section" aria-labelledby="cleanup-title">
  <span class="section-label">Cleanup</span>
  <h2 id="cleanup-title">Remove only the exact staged image you no longer need</h2>
  <p>
    Uninstalling the Local Assistant removes Team-owned workload, binding, egress, icon, Integration, Stored Input,
    continuation, and audit state. The host-staged image remains. Admin reports the exact next command in the form
    <code>docker image rm sha256:&lt;64-hex-image-id&gt;</code>; copy that exact command only after no Team needs the
    snapshot.
  </p>
  <p>Do not run a global Docker image prune. Unrelated projects and another retained snapshot may share layers.</p>
</section>

<section class="guide-section" aria-labelledby="limits-title">
  <span class="section-label">Scope and recovery</span>
  <h2 id="limits-title">Keep the snapshot in its one Local boundary</h2>
  <dl>
    <dt>The snapshot does not appear in Admin</dt>
    <dd>
      Confirm the CLI used the same machine and Docker daemon as the Local Space, then rerun
      <code>shimpz assistant stage</code> and reload snapshots. Local fails closed instead of truncating when more
      than 50 staged candidates exist; remove exact unused image IDs and retry.
    </dd>
    <dt>The exact image is missing after staging</dt>
    <dd>Restage the trusted source. Team never pulls a replacement for a Local image.</dd>
    <dt>You need Hosted, another Space, Store discovery, or distribution</dt>
    <dd>
      <a href="/developers/assistants/publish/">Publish a separate immutable release through Developers</a>.
      Local staging needs no Account, Creator profile, Developers request, Store listing, or Neuron operation, but
      it also creates none of their distribution or trust evidence.
    </dd>
  </dl>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Creator guide">
  <a href="/developers/assistants/quickstart/"><span>Back</span><strong>Build your first Assistant</strong></a>
  <a href="/developers/assistants/publish/"><span>Next</span><strong>Publish an Assistant</strong></a>
</nav>
