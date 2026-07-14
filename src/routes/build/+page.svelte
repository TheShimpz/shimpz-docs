<svelte:head><title>Build a Shimpz — Shimpz docs</title></svelte:head>

<span class="kicker">Guide</span>
<h1 class="mt-3 text-3xl font-extrabold tracking-tight sm:text-4xl">Build a Shimpz</h1>
<p class="mt-4 text-lg dim">From an empty repo to an operator-controlled workspace App candidate.</p>

<h2>1 · Scaffold</h2>
<p>Inside an approved operator-controlled workspace, scaffold a project. It writes the
<code>shimpz.app.toml</code> manifest and a working backend/frontend skeleton. This command does not
register a product or install anything for another account.</p>
<pre><code>shimpz-new my-shimpz fullstack   # or: api | web | script
shimpz-manifest check .          # validate the manifest
shimpz-manifest plan .           # show resolved workspace dependencies and calls</code></pre>

<h2>2 · Declare what it is</h2>
<p>Everything a workspace App needs is declared in one file. The platform resolves its implemented
dependencies at deploy from <code>[needs]</code>:</p>
<pre><code>[needs]
apps   = []                    # optional dependencies must exist in the operator's workspace
calls  = ["some-backend"]      # service APIs to reuse (wired as declared reach)
egress = ["api.example.com"]   # external hosts you may reach (apps have NO internet by default)</code></pre>
<p>Reuse over duplication: before building a capability, look for one that exists in the operator's registry —
<code>shimpz-bus discover &lt;keyword&gt;</code>.</p>

<h2>3 · Prepare the App</h2>
<p>A workspace candidate is source code run by the platform's approved runtime. It must obey this contract:</p>
<ul>
  <li>Serves HTTP on the declared port bound to <code>0.0.0.0</code> when it is a web service.</li>
  <li>Uses an allow-listed launcher from <code>[[run]]</code>; arbitrary commands are rejected.</li>
  <li>Runs non-root with a read-only project mount, dropped capabilities, no Docker socket, and only its
      declared service reach and egress.</li>
  <li>Receives no platform-global credential. A trusted controller may inject a database credential scoped
      to exactly this App; the workspace tooling cannot mint or borrow one.</li>
</ul>

<h2>4 · Deploy &amp; the gate chain</h2>
<p>An operator deploys the candidate into its own hardened container and private per-App network after a fixed
gate chain: standards (deterministic lint), DB isolation (a supplied DSN must be scoped to this App), no global
secrets, a security audit (BOLA/IDOR), a logging audit, and a dependency-vulnerability audit. A blue-green
cutover with a health check prevents a broken build from replacing a working one.</p>
<pre><code>shimpz-app install my-shimpz    # local operator deploy of the workspace app + dependencies</code></pre>
<p><code>install</code> here is a local operator command over workspace sources. It is not a Store, remote-account,
or Capsule installation path.</p>

<h2>5 · Publication gate</h2>
<p>Publisher enrollment, marketplace submission, and paid distribution are outside the public product offer.
Passing the local contract and deploy gates produces an internal App candidate; it does not publish a listing
or create a checkout.</p>
