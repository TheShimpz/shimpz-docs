<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
  import RequestScreenshot from "$lib/components/RequestScreenshot.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Request authentication from an Action — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/requests/auth/" />
  <meta
    name="description"
    content="Request a password, TOTP, or passkey authorization without receiving authentication factors."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/requests/">Human requests</a><span aria-hidden="true">/</span>
  <strong>Authentication</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">request_auth</span>
  <h1>Ask Shimpz to prove authority without receiving the factor</h1>
  <p class="docs-lede">
    An Action names the exact authentication mechanism, not a credential field. Shimpz completes the trusted ceremony.
    Passwords, authenticator codes, passkey assertions, and factor metadata never enter Assistant code.
  </p>
</header>

<section class="guide-section" aria-labelledby="blocking-title">
  <span class="section-label">Automatic block</span>
  <h2 id="blocking-title">Successful assurance returns nothing; failure never returns</h2>
  <p>
    Declare the exact capability — <code>auth:password</code>, <code>auth:totp</code>, or
    <code>auth:passkey</code> — in <code>@action(human_requests=[...])</code>. The SDK call returns
    <code>None</code> only after fresh, request-bound assurance succeeds. Rejection, cancellation, expiry, or an
    unavailable ceremony terminates the Action automatically. Local may let its Supervisor correct a rejected
    password inside the same pending ceremony; the Action remains paused and receives nothing until
    assurance succeeds or the request terminates. Hosted invalid-factor behavior remains terminal.
  </p>
  <p>
    An Action declares and issues at most one authorization request: either <code>approval</code> or one
    <code>auth:*</code> mechanism. Input requests remain independent. Do not add approval before authentication;
    successful authentication already authorizes the exact pending Action.
  </p>
</section>

<section class="guide-section" aria-labelledby="password-title">
  <span class="section-label">Password</span>
  <h2 id="password-title">password</h2>
  <p>
    Use when the human must re-enter the password for the Shimpz authority they are currently using. Local verifies
    the Supervisor password; Hosted verifies the authenticated Account Owner through Account authority.
  </p>
  <CodeBlock label="Fresh password assurance" title="Inside a declared Action" variant="code" {...data.password} />
  <RequestScreenshot
    src="/developers/action-requests/auth-password.png"
    alt="Action authentication dialog requesting the current platform password"
    caption="The password is submitted to the platform ceremony. The Action receives only success or a terminal block."
  />
</section>

<section class="guide-section" aria-labelledby="factor-title">
  <span class="section-label">Authenticator code</span>
  <h2 id="factor-title">totp</h2>
  <p>Use when a sensitive Hosted action requires the Account Owner's configured TOTP authenticator.</p>
  <CodeBlock label="Fresh TOTP assurance" title="Inside a declared Action" variant="code" {...data.totp} />
  <RequestScreenshot
    src="/developers/action-requests/auth-totp.png"
    alt="Action authentication dialog requesting an authenticator code"
    caption="The authenticator code stays inside Account's ceremony and is never placed in the Team chat transcript."
  />
</section>

<section class="guide-section" aria-labelledby="passkey-title">
  <span class="section-label">Passkey</span>
  <h2 id="passkey-title">passkey</h2>
  <p>Use when a high-risk Hosted action requires a registered passkey and user verification.</p>
  <CodeBlock
    label="Fresh passkey assurance"
    title="Inside a declared Action"
    variant="code"
    {...data.passkey}
  />
  <RequestScreenshot
    src="/developers/action-requests/auth-passkey.png"
    alt="Action authentication dialog offering a passkey ceremony"
    caption="The browser and Account complete WebAuthn. The resulting one-use assurance handle is consumed by Team, not the Action."
  />
</section>

<section class="guide-section" aria-labelledby="profile-title">
  <span class="section-label">Profile availability</span>
  <h2 id="profile-title">Request only assurance the current Space profile can prove</h2>
  <dl>
    <dt>Local</dt>
    <dd><code>password</code> only, using the current Supervisor password.</dd>
    <dt>Hosted</dt>
    <dd>
      <code>password</code>, <code>totp</code>, and <code>passkey</code> when the authenticated Team
      Owner's Account has the required factor configured.
    </dd>
  </dl>
  <p>
    An unavailable assurance class fails closed; it never falls back to a weaker class. If an Action must work in
    both profiles, choose <code>password</code> or expose separate Actions with clearly declared requirements.
  </p>
</section>

<aside class="scope-note" aria-labelledby="auth-input-title">
  <span id="auth-input-title" class="kicker">Never emulate authentication with input</span>
  <p>
    Do not ask for a Shimpz password, authenticator code, passkey result, or recovery code through
    <code>request_input</code>. Use <code>request_auth</code> so the factor stays with the platform authority and the
    Action receives no reusable credential.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue human requests">
  <a href="/developers/assistants/requests/input/"><span>Back</span><strong>Inputs</strong></a>
  <a href="/developers/assistants/requests/lifecycle/"><span>Next</span><strong>Replay and lifecycle</strong></a>
</nav>
