<svelte:head><title>The manifest — Shimpz docs</title></svelte:head>

<span class="kicker">Reference</span>
<h1 class="mt-3 text-3xl font-extrabold tracking-tight sm:text-4xl">shimpz.app.toml</h1>
<p class="mt-4 text-lg dim">The one file that declares what your Shimpz is and needs. The toolchain reads it;
an operator validates it before deployment.</p>

<pre><code>name = "my-shimpz"
title = "My Shimpz"
summary = "One line for operators and users."

[needs]
apps   = []                    # optional dependencies supplied by the operator
calls  = ["some-backend"]    # service APIs to reuse (sync, wired as declared reach)
egress = ["api.example.com"] # external hosts you may reach — none by default

[provides]
skill = "my-shimpz/SKILL.md"  # the agent-facing skill this Shimpz ships

[grants]                       # scoped, ENFORCED permissions only
consume = ["other-app.topic"]  # READ another app's bus topic (a narrow, audited ACL)
publish = "own"                # publish ONLY at my-shimpz.grid.shimpz.com
dns     = "own"                # manage DNS ONLY under my-shimpz.grid.shimpz.com

[[run]]                        # local operator install/deploy plan for workspace sources
name = "my-shimpz-backend"
port = 3101
command = ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "3101"]

[config]                       # your Shimpz's OWN settings (UPPER_SNAKE)
GREETING = &lbrace; default = "Hi", help = "Shown to end users" &rbrace;</code></pre>

<h2>What the platform guarantees</h2>
<ul>
  <li><strong>Isolation by construction</strong> — each workspace App gets its own hardened container and
      private per-App network. It cannot join another App's network unless an explicit declared call requires it.</li>
  <li><strong>No internet by default</strong> — an app reaches only the hosts it declared in
      <code>[needs].egress</code>, through an audited token-gated proxy.</li>
  <li><strong>Platform secrets stay out</strong> — the workspace manifest cannot declare platform-global
      credentials, and the App receives none through this public SDK contract.</li>
  <li><strong>Operator-controlled</strong> — this manifest validates a candidate in the local workspace; it does
      not create a Store listing, install into a Capsule, or authorize a remote account.</li>
</ul>

<p class="mt-6 text-sm dim">Only permissions the platform actually ENFORCES live in <code>[grants]</code> —
a declared-but-unenforced permission would be false security, so it isn't offered.</p>
