<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";
  import RequestExample from "$lib/components/RequestExample.svelte";
  import { authExamples } from "$lib/actionRequestExamples";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Request authentication from an Action — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/requests/auth/" />
  <meta
    name="description"
    content="Request fresh Supervisor password authorization without receiving the password."
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
    The password and factor metadata never enter Assistant code.
  </p>
</header>

<aside class="scope-note" aria-labelledby="auth-fragments-title">
  <span id="auth-fragments-title" class="kicker">Illustrative fragments</span>
  <p>
    The snippets below belong inside a declared Action; the decorator, surrounding async function, and Creator-owned
    operation are omitted.
  </p>
</aside>

<section class="guide-section" aria-labelledby="blocking-title">
  <span class="section-label">Automatic block</span>
  <h2 id="blocking-title">Successful assurance returns nothing; failure never returns</h2>
  <p>
    Declare the exact capability, <code>auth:password</code>, in <code>@action(human_requests=[...])</code>. The SDK
    call returns <code>None</code> only after fresh, request-bound assurance succeeds. Rejection, cancellation, expiry, or an
    unavailable ceremony terminates the Action automatically. The <code>title</code> and <code>description</code> are
    <a href="/developers/assistants/requests/copy/"><code>shimpz.text</code> request copy</a>. Local may let its
    Supervisor correct a rejected password inside the same pending ceremony; the Action remains paused and receives
    nothing until assurance succeeds or the request terminates.
  </p>
  <p>
    An Action declares and issues at most one authorization request: either <code>approval</code> or one
    <code>auth:*</code> mechanism. Input requests remain independent. Do not add approval before authentication;
    successful authentication already authorizes the exact pending Action.
  </p>
</section>

<section class="guide-section" aria-labelledby="auth-preview-title">
  <span class="section-label">Native interface</span>
  <h2 id="auth-preview-title">See the trusted password ceremony</h2>
  <p>This is the semantic control Shimpz presents without exposing it to the Action.</p>
  <RequestExample id="auth" examples={authExamples} />
</section>

<section class="guide-section" aria-labelledby="password-title">
  <span class="section-label">Password</span>
  <h2 id="password-title">password</h2>
  <p>
    Use when the Supervisor must re-enter the current Supervisor password before the Action continues.
  </p>
  <CodeBlock label="Fresh password assurance" title="Inside a declared Action" variant="code" {...data.password} />
</section>

<section class="guide-section" aria-labelledby="availability-title">
  <span class="section-label">Availability</span>
  <h2 id="availability-title">Request only assurance a Space can prove</h2>
  <dl>
    <dt><code>password</code></dt>
    <dd>Available, using the current Supervisor password.</dd>
    <dt><code>totp</code>, <code>passkey</code></dt>
    <dd>
      Valid declarations that a Space cannot prove. Team stops the Action as unavailable assurance before any
      ceremony appears.
    </dd>
  </dl>
  <p>An unavailable assurance class fails closed; it never falls back to a weaker class. Declare <code>password</code>.</p>
</section>

<aside class="scope-note" aria-labelledby="auth-input-title">
  <span id="auth-input-title" class="kicker">Never emulate authentication with input</span>
  <p>
    Do not ask for a Shimpz password, authenticator code, passkey result, or recovery code through
    <code>request_input</code>. Use <code>request_auth</code> so the factor stays with Admin and Team and the
    Action receives no reusable credential.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue human requests">
  <a href="/developers/assistants/requests/input/"><span>Back</span><strong>Inputs</strong></a>
  <a href="/developers/assistants/requests/lifecycle/"><span>Next</span><strong>Replay and lifecycle</strong></a>
</nav>
