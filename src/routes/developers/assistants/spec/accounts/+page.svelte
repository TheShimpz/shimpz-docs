<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Assistant Accounts — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/accounts/" />
  <meta
    name="description"
    content="Declare provider Accounts while Shimpz owns OAuth consent, token storage, refresh, and revocation."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <strong>Accounts</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Concept · provider account</span>
  <h1>Declare scopes. Let Shimpz own OAuth.</h1>
  <p class="docs-lede">
    An Account is a person's identity at an external provider, authorized through that provider's consent
    screen. The Assistant names the provider and scopes it needs; Shimpz owns the OAuth application flow,
    token custody, refresh, and revocation.
  </p>
</header>

<aside class="scope-note" aria-labelledby="account-boundary-title">
  <span id="account-boundary-title" class="kicker">Account is not a Secret</span>
  <p>
    Use <code>secrets</code> for values a person pastes, such as an API key. Use <code>accounts</code> when a
    provider requires browser consent, scopes, refresh, or revocation. OAuth application credentials and
    end-user tokens never belong in Assistant source or a password form.
  </p>
</aside>

<section class="guide-section" aria-labelledby="account-contract-title">
  <span class="section-label">Public contract</span>
  <h2 id="account-contract-title">Reference one reviewed Account from each Power</h2>
  <CodeBlock
    label="Cloudflare Account intent and two read-only Power references"
    title="shimpz.assistant.toml"
    variant="code"
    {...data.declaration}
  />
  <ul>
    <li>The lowercase kebab-case Account ID is local to this Assistant release and has at most 64 characters.</li>
    <li><code>provider</code> must match a controller-owned, reviewed provider adapter.</li>
    <li><code>scopes</code> is a unique, closed subset supported by that adapter.</li>
    <li>An Assistant may declare at most 16 Accounts and 32 scopes per Account.</li>
    <li>A Power may reference at most four declared Account IDs through <code>accounts</code>.</li>
    <li>Every declared Account must be used by at least one Power; unused or undefined references fail closed.</li>
    <li>Endpoints, Client IDs, callbacks, credentials, authorization codes, and tokens are not manifest fields.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="account-jit-title">
  <span class="section-label">Just-in-time consent</span>
  <h2 id="account-jit-title">Pause safely when the Account is missing</h2>
  <ol>
    <li>The Brain requests a declared Power; it never handles OAuth material.</li>
    <li>The controller checks the exact Account and scopes admitted for that Assistant release.</li>
    <li>If access is missing or cannot be refreshed, the Power remains unexecuted and the Admin asks the user to connect.</li>
    <li>The provider shows its own consent screen. Shimpz binds the short-lived flow to the session, Team, Assistant, and Account ID.</li>
    <li>After a validated callback, the controller seals the tokens and resumes the paused turn once.</li>
  </ol>
  <p>
    Closing the flow leaves the Power unexecuted. The controller resolves private gates before execution:
    <strong>Accounts → Secrets → approval</strong>. Connecting an Account never approves a write; the Power's
    approval policy remains a separate user decision.
  </p>
</section>

<section class="guide-section" aria-labelledby="account-custody-title">
  <span class="section-label">Controller custody</span>
  <h2 id="account-custody-title">Keep tokens outside the Assistant</h2>
  <p>
    Access and refresh tokens are encrypted and isolated to one Team, Assistant, and Account ID. The controller
    serializes refresh, validates the returned scopes, and owns disconnect and revocation. An immutable upgrade
    may reuse the grant only while its Account ID, provider, and scopes still match; declaration drift requires
    fresh consent. The Admin may show provider identity, scopes, status, and expiry metadata, but never plaintext
    tokens.
  </p>
  <p>
    Shimpz registers and operates the official OAuth application for Store Assistants. Provider client
    configuration is platform state, not creator or user input. A future private-development flow may offer a
    separate bring-your-own OAuth application contract; it is not part of Assistant Spec v2.
  </p>
</section>

<section class="guide-section" aria-labelledby="account-envelope-title">
  <span class="section-label">Private RPC</span>
  <h2 id="account-envelope-title">Deliver one bounded access token per invocation</h2>
  <CodeBlock
    label="Illustrative private invocation envelope; values never belong in source"
    title="Controller to Assistant · stdin JSON"
    variant="code"
    {...data.envelope}
  />
  <p>
    The <code>accounts</code> object contains exactly the IDs declared by the selected Power. Each entry is a
    bounded <code>oauth2-bearer</code> access token for that private invocation. Missing or extra IDs, refresh
    tokens, authorization codes, PKCE verifiers, developer credentials, and unknown fields are rejected. The
    Assistant may send the token only to an exact admitted <code>allowed_hosts</code> destination.
  </p>
</section>

<section class="guide-section" aria-labelledby="account-cloudflare-title">
  <span class="section-label">Validated reference</span>
  <h2 id="account-cloudflare-title">Start from the Cloudflare Account adapter</h2>
  <p>
    Cloudflare is the first complete Account reference. It uses OAuth 2.0 Authorization Code with S256 PKCE,
    exact callbacks, short-lived single-use state, strict token responses, encrypted local token custody,
    serialized refresh, revocation, and exact API egress. The reference Assistant requests only
    <code>zone.read</code>, <code>dns.read</code>, and <code>offline_access</code>. Its only API destination is
    <code>api.cloudflare.com</code>; redirect following is disabled.
  </p>
  <p>
    The flow has been validated with real consent and real read-only zone and DNS-record calls. This does not
    mean every OAuth provider can be enabled by changing a name. Authorization servers differ in scope syntax,
    client authentication, token rotation, issuer support, and response contracts. Platform maintainers must
    implement and prove one closed adapter for each provider.
  </p>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/secrets/"><span>Back</span><strong>Secrets</strong></a>
  <a href="/developers/assistants/spec/accounts/providers/"><span>Next</span><strong>OAuth providers</strong></a>
</nav>
