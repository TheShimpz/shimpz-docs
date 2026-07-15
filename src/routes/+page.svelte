<svelte:head>
  <title>Install your Shimpz Space — Shimpz docs</title>
  <meta name="description" content="Install the Shimpz Space development channel and open its local Admin." />
</svelte:head>

<span class="badge" style="border-color:color-mix(in oklab, var(--color-primary) 30%, var(--color-border))">
  <span class="mr-1.5 inline-block size-1.5 rounded-full" style="background:var(--color-primary)"></span>
  Shimpz · User docs
</span>

<h1 class="mt-5 text-4xl font-extrabold tracking-tight sm:text-5xl">Install your <span class="gradient-text">Shimpz Space</span>.</h1>

<p class="mt-4 text-lg leading-relaxed dim">
  The development installer pulls one prebuilt image, pins its registry digest, and opens the local
  Admin. It does not clone repositories or build Shimpz on your machine.
</p>

<div class="card my-7">
  <span class="kicker">Validated scope</span>
  <p class="mt-2">
    This initial delivery boots only the Admin. It does not install or advertise a Driver, Capsule, or
    App package.
  </p>
</div>

<h2>1 · Requirements</h2>
<ul>
  <li>A Linux amd64 machine.</li>
  <li>Docker Engine with Docker Compose v2.</li>
  <li>Your user must be allowed to run Docker.</li>
</ul>

<h2>2 · Install</h2>
<pre class="whitespace-pre-wrap break-all"><code>curl -fsSL https://install.shimpz.com | sh</code></pre>
<p>
  The installer keeps private state in <code>$HOME/.shimpz</code>, publishes the Admin only on host
  loopback, and waits for its health check before reporting success.
</p>

<h2>3 · Open the Admin</h2>
<pre class="whitespace-pre-wrap break-all"><code>http://127.0.0.1:7777</code></pre>
<p>Create the initial Admin password with at least 12 characters.</p>

<h3>Remote Linux host</h3>
<p>Keep the Admin private and forward its loopback port over SSH:</p>
<pre class="whitespace-pre-wrap break-all"><code>ssh -L 7777:127.0.0.1:7777 user@your-server</code></pre>
<p>Leave that session open, then visit <code>http://127.0.0.1:7777</code> on your own computer.</p>

<h2>4 · Know the boundaries</h2>
<ul>
  <li><strong>Space</strong> is the Shimpz installation owned by this machine.</li>
  <li><strong>Driver</strong> is a Space-wide service available to authorized Apps across its Capsules.</li>
  <li><strong>Capsule</strong> is an isolated environment inside the Space.</li>
  <li><strong>App</strong> belongs to exactly one Capsule. Apps can communicate only inside that same Capsule
      and can use Drivers exposed by their Space.</li>
</ul>

<h2>5 · Update or reset</h2>
<p>Run the install command again to pull the current development image. The installer keeps the previous
digest and restores it when the replacement does not become healthy.</p>

<p>Reset stops the managed Space and permanently removes its local Admin data:</p>
<pre class="whitespace-pre-wrap break-all"><code>curl -fsSL https://install.shimpz.com | sh -s -- --reset</code></pre>
