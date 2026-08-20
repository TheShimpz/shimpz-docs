<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Recover a Local Shimpz Space — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/help/" />
  <meta
    name="description"
    content="Start from a visible Local Shimpz symptom and follow the current safe check or recovery path."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">Use Shimpz</a><span aria-hidden="true">/</span><strong>Help and recovery</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Local recovery</span>
  <h1>Start with what you can see</h1>
  <p class="docs-lede">
    Match the visible symptom, run the first safe check, and continue in the guide that owns the complete procedure.
  </p>
</header>

<section class="guide-section" aria-labelledby="install-recovery-title">
  <span class="section-label">Install and open</span>
  <h2 id="install-recovery-title">Installation stopped</h2>
  <p>
    First run <code>docker version</code> and <code>docker compose version</code> in the same environment where the
    installation command runs. If <code>shimpz</code> is already installed, run <code>shimpz status</code> to inspect
    the current Space. If either Docker command fails, repair Docker before running the installation command again.
    Use the check for <a href="/install/linux/#check-docker-title">Linux</a>,
    <a href="/install/macos/#check-docker-title">macOS</a>, or
    <a href="/install/windows/#check-docker-title">Windows with WSL2</a>.
  </p>
  <p>
    If both Docker commands succeed but Shimpz reports Docker or a required host tool as unavailable or refused,
    reacquire the current release-bound CLI before retrying. Run the installation command again from an interactive
    terminal. The bootstrap verifies the CLI before it reconciles the Space.
  </p>
  <CodeBlock
    label="Reacquire the current Shimpz CLI"
    title="Terminal · Shimpz recovery"
    lines={[{ value: "curl -fsSL https://install.shimpz.com | sh" }]}
  />
  <p>
    If Docker works and <code>shimpz install</code> reports that its existing Local Space failed runtime validation,
    read the listed deletion scope. Answer <strong>Yes</strong> only when you intend to erase that complete Local Space
    and install a fresh one. Answer <strong>No</strong> or press Enter to leave every local resource unchanged.
    Continue with <a href="/manage/">Maintain your Space</a> for the full recovery and reset boundaries.
  </p>

  <h3>Admin does not open</h3>
  <p>
    Use the exact Admin address printed by <code>shimpz install</code>; do not assume the port is <code>7777</code>. Compare the
    visible result with the final step for <a href="/install/linux/#confirm-admin-title">Linux</a>,
    <a href="/install/macos/#confirm-admin-title">macOS</a>, or
    <a href="/install/windows/#confirm-admin-title">Windows with WSL2</a>.
  </p>
</section>

<section class="guide-section" aria-labelledby="team-recovery-title">
  <span class="section-label">Team and Assistant</span>
  <h2 id="team-recovery-title">The Team does not reply</h2>
  <p>
    Send one message that does not require an Assistant. If Shimpz still asks for model configuration, return to
    <a href="/admin/#verify-team-title">Verify the Team can reply</a> and check the selected model and provider key.
  </p>

  <h3>The Assistant is missing or authorization did not open</h3>
  <p>
    Confirm that the Assistant is installed in the exact Team shown in Chat. If an authorization window was
    expected, allow pop-ups for Local Admin and retry the message once. Continue with
    <a href="/assistants/#problems-title">the visible Assistant checks</a>.
  </p>
</section>

<section class="guide-section" aria-labelledby="integration-recovery-title">
  <span class="section-label">Integration</span>
  <h2 id="integration-recovery-title">The provider identity is wrong</h2>
  <p>
    Disconnect that Integration before authorizing the intended provider identity. Use
    <a href="/assistants/#disconnect-title">Disconnect before uninstalling</a> to remove access deliberately.
  </p>

  <h3>The provider tab shows Bad Gateway</h3>
  <p>
    No provider grant was created. Close the provider tab and follow the fail-closed recovery under
    <a href="/admin/#oauth-bad-gateway-title">Bad Gateway means authorization did not start</a>.
  </p>
</section>

<section class="guide-section" aria-labelledby="maintenance-recovery-title">
  <span class="section-label">Maintenance</span>
  <h2 id="maintenance-recovery-title">An update failed or rolled back</h2>
  <p>
    Read the error printed by <code>shimpz install</code> before retrying. If the replacement did not become healthy,
    Shimpz keeps or restores the previous working version. Fix the reported cause, then return to
    <a href="/manage/">Maintain your Space</a>.
  </p>

  <h3>You want to remove access or delete Local data</h3>
  <p>
    Disconnect provider Integrations and uninstall the affected Assistant when that is enough. Use
    <a href="/manage/#reset-title">reset</a> only when you intend to delete every managed Team, Assistant,
    Integration, setting, conversation, and local Shimpz data.
  </p>
</section>

<nav class="docs-page-nav" aria-label="Leave recovery">
  <a href="/"><span>Return</span><strong>Use Shimpz</strong></a>
</nav>
