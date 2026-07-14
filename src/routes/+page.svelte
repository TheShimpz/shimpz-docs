<svelte:head>
  <title>Shimpz docs — build a Shimpz</title>
  <meta name="description" content="The app-creation standard for operator-controlled Shimpz workspace Apps." />
</svelte:head>

<span class="badge" style="border-color:color-mix(in oklab, var(--color-primary) 30%, var(--color-border))">
  <span class="mr-1.5 inline-block size-1.5 rounded-full" style="background:var(--color-primary)"></span>
  Shimpz · developer docs
</span>

<h1 class="mt-5 text-4xl font-extrabold tracking-tight sm:text-5xl">Build a <span class="gradient-text">Shimpz</span>.</h1>

<p class="mt-4 text-lg leading-relaxed dim">
  A <strong>Shimpz App candidate</strong> is source code, an optional agent skill, and a manifest in an
  operator-controlled workspace. These docs cover validating and deploying that candidate on the same
  Shimpz host through the implemented workspace App contract.
</p>

<h2>The shape of a Shimpz</h2>
<ul>
  <li>Its OWN git repo, following the app contract (one <code>shimpz.app.toml</code> declares what it is and needs).</li>
  <li>Source placed in the approved workspace and launched only by an operator through <code>shimpz-app</code>.</li>
  <li>A fixed, allow-listed runtime command rather than an arbitrary executable.</li>
  <li>A hardened per-App container: non-root, read-only rootfs, capabilities dropped, no Docker socket, deny-by-default egress.</li>
</ul>

<h2>Two ways in</h2>
<div class="not-prose my-6 grid gap-4 sm:grid-cols-2">
  <a href="/build" class="card">
    <span class="kicker">Start here</span>
    <p class="mt-2 font-semibold">Build a Shimpz →</p>
    <p class="mt-1 text-sm dim">Scaffold, declare, deploy — the full app-creation walkthrough.</p>
  </a>
  <a href="/manifest" class="card">
    <span class="kicker">Reference</span>
    <p class="mt-2 font-semibold">The manifest →</p>
    <p class="mt-1 text-sm dim">Every field of <code>shimpz.app.toml</code>, and what the platform enforces.</p>
  </a>
</div>

<h2>Scope of these docs</h2>
<p>
  These pages document only the operator-controlled workspace App contract and its enforced isolation.
  Standalone distribution, Capsule installation, publisher enrollment, and marketplace commerce are
  outside the public Shimpz offer. This site is not an installer, catalog, sales flow, or publishing service.
</p>
