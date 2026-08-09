<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
  import RequestScreenshot from "$lib/components/RequestScreenshot.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Request authentication from a Power — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/requests/auth/" />
  <meta
    name="description"
    content="Request password reauthentication, a second factor, or phishing-resistant assurance without receiving credentials."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/requests/">Power requests</a><span aria-hidden="true">/</span>
  <strong>Authentication</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">request_auth</span>
  <h1>Ask Shimpz to prove authority without receiving the factor</h1>
  <p class="docs-lede">
    A Power names an assurance class, not a credential field. Shimpz chooses and completes the trusted ceremony.
    Passwords, authenticator codes, passkey assertions, and factor metadata never enter Assistant code.
  </p>
</header>

<section class="guide-section" aria-labelledby="blocking-title">
  <span class="section-label">Automatic block</span>
  <h2 id="blocking-title">Successful assurance returns nothing; failure never returns</h2>
  <p>
    Declare the exact capability — <code>auth:reauth</code>, <code>auth:second-factor</code>, or
    <code>auth:phishing-resistant</code> — in <code>@power(human_requests=[...])</code>. The SDK call returns
    <code>None</code> only after fresh, request-bound assurance succeeds. Rejection, cancellation, expiry, or an
    unavailable ceremony terminates the Power automatically. Local may let its Supervisor correct a rejected
    reauthentication password inside the same pending ceremony; the Power remains paused and receives nothing until
    assurance succeeds or the request terminates. Hosted invalid-factor behavior remains terminal.
  </p>
</section>

<section class="guide-section" aria-labelledby="reauth-title">
  <span class="section-label">Password reauthentication</span>
  <h2 id="reauth-title">reauth</h2>
  <p>
    Use when the human must re-enter the password for the Shimpz authority they are currently using. Local verifies
    the Supervisor password; Hosted verifies the authenticated Account Owner through Account authority.
  </p>
  <CodeBlock label="Fresh password assurance" title="Inside a declared Power" variant="code" {...data.reauth} />
  <RequestScreenshot
    src="/developers/power-requests/auth-reauth.png"
    alt="Power authentication dialog requesting the current platform password"
    caption="The password is submitted to the platform ceremony. The Power receives only success or a terminal block."
  />
</section>

<section class="guide-section" aria-labelledby="factor-title">
  <span class="section-label">Second factor</span>
  <h2 id="factor-title">second-factor</h2>
  <p>Use when a sensitive Hosted action requires the Account Owner's configured second factor.</p>
  <CodeBlock label="Fresh second-factor assurance" title="Inside a declared Power" variant="code" {...data.secondFactor} />
  <RequestScreenshot
    src="/developers/power-requests/auth-second-factor.png"
    alt="Power authentication dialog requesting an authenticator code"
    caption="The authenticator code stays inside Account's ceremony and is never placed in the Team chat transcript."
  />
</section>

<section class="guide-section" aria-labelledby="passkey-title">
  <span class="section-label">Phishing-resistant</span>
  <h2 id="passkey-title">phishing-resistant</h2>
  <p>Use when a high-risk Hosted action requires a registered passkey and user verification.</p>
  <CodeBlock
    label="Fresh phishing-resistant assurance"
    title="Inside a declared Power"
    variant="code"
    {...data.phishingResistant}
  />
  <RequestScreenshot
    src="/developers/power-requests/auth-phishing-resistant.png"
    alt="Power authentication dialog offering a passkey ceremony"
    caption="The browser and Account complete WebAuthn. The resulting one-use assurance handle is consumed by Team, not the Power."
  />
</section>

<section class="guide-section" aria-labelledby="profile-title">
  <span class="section-label">Profile availability</span>
  <h2 id="profile-title">Request only assurance the current Space profile can prove</h2>
  <dl>
    <dt>Local</dt>
    <dd><code>reauth</code> only, using the current Supervisor password.</dd>
    <dt>Hosted</dt>
    <dd>
      <code>reauth</code>, <code>second-factor</code>, and <code>phishing-resistant</code> when the authenticated Team
      Owner's Account has the required factor configured.
    </dd>
  </dl>
  <p>
    An unavailable assurance class fails closed; it never falls back to a weaker class. If a Power must work in
    both profiles, choose <code>reauth</code> or expose separate Powers with clearly declared requirements.
  </p>
</section>

<aside class="scope-note" aria-labelledby="auth-input-title">
  <span id="auth-input-title" class="kicker">Never emulate authentication with input</span>
  <p>
    Do not ask for a Shimpz password, authenticator code, passkey result, or recovery code through
    <code>request_input</code>. Use <code>request_auth</code> so the factor stays with the platform authority and the
    Power receives no reusable credential.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue Power requests">
  <a href="/developers/assistants/requests/input/"><span>Back</span><strong>Inputs</strong></a>
  <a href="/developers/assistants/requests/lifecycle/"><span>Next</span><strong>Lifecycle & security</strong></a>
</nav>
