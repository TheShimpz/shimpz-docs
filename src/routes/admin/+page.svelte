<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
</script>

<svelte:head>
  <title>Create your first Team — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/admin/" />
  <meta name="description" content="Open Shimpz, create your first Team, and configure its Brain." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/">Use Shimpz</a><span aria-hidden="true">/</span><strong>Create your first Team</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">After installation</span>
  <h1>Create your first Team</h1>
  <p class="docs-lede">
    A Team is your private workspace. It keeps its own conversation, Assistants, Integrations, model settings,
    and files separate from every other Team.
  </p>
</header>

<ol class="step-list">
  <li>
    <h2>Open the local Admin</h2>
    <CodeBlock
      label="Local Shimpz Admin address"
      title="Browser · local Admin"
      lines={[{ value: "http://127.0.0.1:7777", prompt: "›" }]}
    />
    <p>
      Open the exact address printed by <code>shimpz install</code>. The address above is the default; a configured
      <code>SHIMPZ_PORT</code> changes the port.
    </p>
    <p>
      When the installed port is not <code>7777</code>, use the printed address for normal Admin work and open
      <code>https://local.shimpz.com</code> when you need to authorize an Assistant Integration.
    </p>
    <p>
      Create the initial Admin password when asked. Use at least 15 characters and do not reuse it elsewhere. Then
      scan the QR code with an authenticator app and enter its current six-digit code. This TOTP factor is required
      before Admin creates your first Supervisor session.
    </p>
    <p>
      A passkey is optional. To register one, open the same port as <code>http://localhost:7777</code> (or replace
      <code>7777</code> with your configured port), complete password and TOTP verification, then choose
      <strong>Create passkey</strong>. Passkeys require that exact <code>localhost</code> address or an admitted HTTPS
      domain and remain bound to it. Return to the printed <code>127.0.0.1</code> address for automatic Integration
      authorization; there, use your authenticator code instead of the <code>localhost</code>-bound passkey.
    </p>
  </li>

  <li>
    <h2>Name the Team</h2>
    <p>
      On a clean installation, Shimpz opens <strong>Create a Team</strong> automatically. Enter a simple name,
      such as <code>Marketing</code>, then choose <strong>Create Team</strong>. You cannot enter chat without a Team.
    </p>
  </li>

  <li>
    <h2>Configure the Brain</h2>
    <p>
      Open the Team's model settings, choose OpenAI or Anthropic and a supported model, then use the key button
      beside the chat composer to save the matching API key. The key is write-only: Shimpz never shows it again.
    </p>
    <p>
      The Brain writes the Team's replies and decides when an Action can help. Do not paste API keys, passwords,
      or OAuth tokens into the message box.
    </p>
  </li>

  <li>
    <h2 id="verify-team-title">Verify the Team can reply</h2>
    <p>Open <strong>Chat</strong> and send a message that does not require an Assistant:</p>
    <blockquote>Reply with this Team's name and one short sentence.</blockquote>
    <p>
      Continue when the Team returns a complete reply without asking for model configuration. This proves the Team,
      model selection, and provider key are ready before you add an Assistant.
    </p>
  </li>
</ol>

<section class="guide-section" aria-labelledby="chat-progress-title">
  <span class="section-label">During a reply</span>
  <h2 id="chat-progress-title">Follow the Team's execution</h2>
  <p>
    After you send a message, Chat shows the server operations the Team has actually entered, such as
    <code>team-context</code>, <code>model</code>, <code>action</code>, <code>action-delivery</code>, and
    <code>reply-validation</code>. The last phase is the Admin's exact public-response validation, while
    <code>action-delivery</code> retires the durable result journal after the model accepted it.
    A moving line means that exact operation is still active. A duration appears only after the server measures
    its completion; the display does not invent a percentage or estimated finish time.
  </p>
  <p>
    When the answer arrives, open <strong>Execution stages</strong> below it to inspect the completed receipt.
    This receipt contains technical phase names and timing metadata only—not hidden reasoning, prompts, Action
    arguments, results, API keys, or Integration credentials.
  </p>
  <p>
    Every new message starts at the top of the conversation area with room below it for the answer. Shimpz does
    not pull the page back down when the answer arrives, so you can scroll and read while a long response grows.
  </p>
</section>

<aside class="scope-note" aria-labelledby="local-safety-title">
  <span id="local-safety-title" class="kicker">Keep it private</span>
  <p>
    Port <code>7777</code> is intentionally available only on this computer. Anyone who controls your operating
    system account or Docker daemon is inside the same trust boundary. Do not expose this port directly to the internet.
  </p>
  <p>
    Shimpz returns Integration authorization automatically when this page is exactly
    <code>http://127.0.0.1:7777</code> or <code>https://local.shimpz.com</code>. No OAuth wildcard or callback
    registration is required for another domain.
  </p>
  <p>
    At any other external HTTPS address admitted after your password and authenticator, Shimpz opens the provider in a new tab.
    After approval, the fixed <code>shimpz.com</code> callback shows a short-lived, one-use completion code. Copy it,
    return to the original authenticated Admin tab, and paste it into the completion field. The code is not a
    provider token or OAuth authorization code, and you should never paste it into chat or another site.
  </p>
  <h3 id="oauth-bad-gateway-title">Bad Gateway means authorization did not start</h3>
  <p>
    If the provider tab shows <strong>Bad Gateway</strong> before Cloudflare asks for consent, authorization did not
    start and no provider grant was created. Shimpz fails closed when its hosted broker cannot reach the private
    OAuth operation boundary. Close that tab and retry from the original Admin chat after service is restored; do
    not add a wildcard callback or paste credentials to work around it.
  </p>
  <p>
    A reverse proxy or tunnel that terminates HTTPS can relay your Admin password and session, so it is inside the
    Supervisor trust boundary. Use only a TLS endpoint you control and trust. Integration tokens remain encrypted
    in Team, but a compromised Admin endpoint can still exercise everything visible to your Supervisor session.
  </p>
</aside>

<section class="guide-section" aria-labelledby="remote-access-title">
  <span class="section-label">Optional</span>
  <h2 id="remote-access-title">Open a remote Linux installation safely</h2>
  <p>
    For the smallest remote trust boundary, forward the private Admin through SSH, leave the terminal open, and use
    <code>http://127.0.0.1:7777</code> in your browser. This retains the automatic loopback OAuth return and does not
    place a TLS terminator in front of your Supervisor session.
  </p>
  <CodeBlock
    label="Forward a remote Admin through SSH"
    title="Terminal · your computer"
    lines={[{ value: "ssh -L 7777:127.0.0.1:7777 user@your-server" }]}
  />
  <p>
    If <code>shimpz install</code> used another <code>SHIMPZ_PORT</code>, keep the local side at <code>7777</code> and
    change only the remote destination. For example, an installed port of <code>49123</code> uses:
  </p>
  <CodeBlock
    label="Forward a custom installed Admin port"
    title="Terminal · your computer"
    lines={[{ value: "ssh -L 7777:127.0.0.1:49123 user@your-server" }]}
  />
</section>

<nav class="docs-page-nav" aria-label="Continue the user guide">
  <a href="/assistants/"><span>Next</span><strong>Add an Assistant</strong></a>
</nav>
