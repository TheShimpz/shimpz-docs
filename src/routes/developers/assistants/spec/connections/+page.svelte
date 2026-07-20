<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant connections — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/connections/" />
  <meta
    name="description"
    content="Declare reviewed OAuth provider scopes while Shimpz owns consent, token storage, refresh, and revocation."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Connections</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Concept · provider consent</span>
  <h1>Declare scopes. Let the controller own OAuth.</h1>
  <p class="docs-lede">
    A connection names one reviewed provider and the smallest scopes its Powers need. The Assistant never
    receives a developer client secret, authorization code, refresh token, PKCE verifier, or callback URL.
  </p>
</header>

<aside class="scope-note" aria-labelledby="connection-boundary-title">
  <span id="connection-boundary-title" class="kicker">Not a password form</span>
  <p>
    Use <code>secrets</code> for user-owned API keys. Use <code>connections</code> when a provider requires a
    browser redirect, consent scopes, refresh, or revocation. Never ask a person to paste X developer app
    credentials into an Assistant.
  </p>
</aside>

<section class="guide-section" aria-labelledby="connection-contract-title">
  <span class="section-label">Public contract</span>
  <h2 id="connection-contract-title">Reference a reviewed connection from each Power</h2>
  <CodeBlock
    label="X connection intent and two Power references"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.declaration}
  />
  <ul>
    <li>The lowercase connection ID is local to this Assistant release.</li>
    <li><code>provider</code> must match a controller-owned, reviewed provider adapter.</li>
    <li><code>scopes</code> is a unique, closed subset supported by that adapter.</li>
    <li>A Power receives no connection unless its own <code>connections</code> list references that ID.</li>
    <li>Provider endpoints, Client IDs, callback URLs, credentials, and tokens are never manifest fields.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="connection-jit-title">
  <span class="section-label">Just-in-time consent</span>
  <h2 id="connection-jit-title">Pause safely when an account is not connected</h2>
  <ol>
    <li>The Brain selects a declared Power; it never handles OAuth material.</li>
    <li>The controller checks the exact connection and scopes admitted for that Assistant release.</li>
    <li>If missing or expired beyond refresh, the Power remains unexecuted and the Admin offers Connect X.</li>
    <li>The controller creates a short-lived, one-use PKCE S256 challenge bound to the session, Team, Assistant, and connection.</li>
    <li>After provider consent, the controller validates state, exchanges the code, seals the tokens, and resumes once.</li>
  </ol>
  <p>
    Closing the flow leaves the Power unexecuted. Connecting an account never approves a write Power; its
    <code>approval</code> policy is a separate decision after the connection becomes usable.
  </p>
</section>

<section class="guide-section" aria-labelledby="connection-custody-title">
  <span class="section-label">Controller custody</span>
  <h2 id="connection-custody-title">Keep refresh and revocation outside the Assistant</h2>
  <p>
    Access and refresh tokens are independently encrypted for one Team, Assistant, connection ID, and release
    generation. The controller serializes refresh, validates returned scopes, and revokes or deletes the
    connection without exposing plaintext through the Admin API, Brain, logs, environment, or process arguments.
  </p>
  <p>
    The Admin shows account identity, provider, scopes, status, and expiry metadata only. It may reconnect or
    disconnect the account, but it can never reveal a stored token.
  </p>
</section>

<section class="guide-section" aria-labelledby="connection-envelope-title">
  <span class="section-label">Private RPC</span>
  <h2 id="connection-envelope-title">Deliver only the access token for one invocation</h2>
  <CodeBlock
    label="Illustrative private invocation envelope; values never belong in source"
    title="Controller to Assistant · stdin JSON"
    variant="code"
    {...data.envelope}
  />
  <p>
    The connection object contains only the exact ID declared by the selected Power and a bounded access token.
    Refresh tokens, authorization codes, PKCE verifiers, developer credentials, and unrelated connections are
    rejected. The Assistant may send the access token only to an exact admitted <code>allowed_hosts</code> host.
  </p>
</section>

<section class="guide-section" aria-labelledby="connection-x-title">
  <span class="section-label">X reference adapter</span>
  <h2 id="connection-x-title">Use OAuth 2.0 Authorization Code with PKCE</h2>
  <p>
    The reviewed X adapter fixes the authorization, token, and revocation endpoints inside Shimpz and uses
    S256 PKCE. Its current Assistant API destination is exactly <code>api.x.com</code>; redirect following is
    disabled so a provider response cannot escape that boundary.
  </p>
  <p>
    Request only the scopes each published release needs. The reference Assistant declares
    <code>tweet.read</code>, <code>users.read</code>, <code>tweet.write</code>, and <code>offline.access</code>
    for identity, reading, posting, deletion, and controller-owned refresh.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/secrets/"><span>Back</span><strong>Secrets</strong></a>
  <a href="/developers/assistants/spec/permissions/"><span>Next</span><strong>Permissions</strong></a>
</nav>
