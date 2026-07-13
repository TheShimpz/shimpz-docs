<svelte:head>
  <title>Shimpz docs — build a Shimpz</title>
  <meta name="description" content="How to build and sell a Shimpz — the app-creation standard for the Shimpz marketplace." />
</svelte:head>

<span class="badge" style="border-color:color-mix(in oklab, var(--color-primary) 30%, var(--color-border))">
  <span class="mr-1.5 inline-block size-1.5 rounded-full" style="background:var(--color-primary)"></span>
  Shimpz · developer docs
</span>

<h1 class="mt-5 text-4xl font-extrabold tracking-tight sm:text-5xl">Build a <span class="gradient-text">Shimpz</span>.</h1>

<p class="mt-4 text-lg leading-relaxed dim">
  A <strong>Shimpz</strong> is an installable AI product — its own agent skill and container — that a Captain
  installs into a <strong>Capsule</strong> (their sealed AI environment). This is the standard for building
  one and selling it on the marketplace.
</p>

<h2>The shape of a Shimpz</h2>
<ul>
  <li>Its OWN git repo, following the app contract (one <code>shimpz.app.toml</code> declares what it is and needs).</li>
  <li>A pre-built, pinned image — deployed into a Capsule's isolated network with its own scoped database.</li>
  <li>Declares its supported CPU <strong>architectures</strong> (amd64 / arm64) — an amd64-only Shimpz can't run on an ARM Capsule.</li>
  <li>Runs hardened by construction: non-root, read-only rootfs, capabilities dropped, no Docker socket, deny-by-default egress.</li>
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

<h2>Install a Capsule to develop against</h2>
<p>One command runs a standalone Capsule on your machine (the admin panel on port 7777) with the SDK checked out:</p>
<pre><code>curl -fsSL https://install.shimpz.com | sh -s -- --dev</code></pre>
<p class="text-sm dim">Linux or macOS · Docker + Compose v2 · git. Then open <code>http://localhost:7777</code>.</p>

<h2>Selling it</h2>
<p>
  Publishing a Shimpz to the marketplace makes it installable by every Captain. Becoming a publisher is a
  paid developer membership (annual) — <strong>free through the first year</strong>. Pricing a Shimpz is
  locked to ShimpzPay, the one billing rail.
</p>
