<svelte:head><title>The manifest — Shimpz docs</title></svelte:head>

<span class="kicker">Reference</span>
<h1 class="mt-3 text-3xl font-extrabold tracking-tight sm:text-4xl">shimpz.app.toml</h1>
<p class="mt-4 text-lg dim">The one file that declares what your Shimpz is and needs. The toolchain reads it;
the marketplace surfaces it.</p>

<pre><code>name = "my-shimpz"
title = "My Shimpz"
summary = "One line the store shows."

[needs]
native = ["openai"]          # audited integrations to ENABLE
apps   = ["notification-center"] # other Shimpz this one reuses
calls  = ["some-backend"]    # service APIs to reuse (sync, wired as declared reach)
egress = ["api.example.com"] # external hosts you may reach — none by default

[provides]
skill = "my-shimpz/SKILL.md"  # the agent-facing skill this Shimpz ships

[grants]                       # scoped, ENFORCED permissions only
consume = ["other-app.topic"]  # READ another app's bus topic (a narrow, audited ACL)
publish = "own"                # publish ONLY at my-shimpz.grid.shimpz.com
dns     = "own"                # manage DNS ONLY under my-shimpz.grid.shimpz.com

[billing]                      # charge for it (payment locked to ShimpzPay)
pay = "shimpzpay"
price = 9.90
period = "monthly"             # monthly | yearly | once

[[run]]                        # makes `shimpz-app install my-shimpz` deploy the whole app + deps
name = "my-shimpz-backend"
port = 3101
command = ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "3101"]

[config]                       # your Shimpz's OWN settings (UPPER_SNAKE)
GREETING = &lbrace; default = "Hi", help = "Shown to end users" &rbrace;</code></pre>

<h2>What the platform guarantees</h2>
<ul>
  <li><strong>Isolation by construction</strong> — each installed Shimpz gets its own container, its own
      private network, its own scoped database. It can never see another Shimpz's data, nor the platform's.</li>
  <li><strong>No internet by default</strong> — an app reaches only the hosts it declared in
      <code>[needs].egress</code>, through an audited token-gated proxy.</li>
  <li><strong>Secrets stay in the platform</strong> — native integrations (OpenAI, Cloudflare, ShimpzPay…)
      are audited credential-broker sidecars; the app never holds the key.</li>
  <li><strong>Per-Capsule</strong> — every Capsule installs its OWN isolated copy with its own data; a shared
      instance across Capsules is disallowed.</li>
</ul>

<p class="mt-6 text-sm dim">Only permissions the platform actually ENFORCES live in <code>[grants]</code> —
a declared-but-unenforced permission would be false security, so it isn't offered.</p>
