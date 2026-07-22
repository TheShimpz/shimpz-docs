<svelte:head>
  <title>OAuth provider adapters — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/accounts/providers/" />
  <meta
    name="description"
    content="Security model, implementation sequence, and release evidence required for a Shimpz OAuth provider adapter."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/">Assistants</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/">Spec v2</a><span aria-hidden="true">/</span>
  <a href="/developers/assistants/spec/accounts/">Accounts</a><span aria-hidden="true">/</span>
  <strong>OAuth providers</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Platform guide · OAuth 2.0</span>
  <h1>Add adapters, not OAuth exceptions.</h1>
  <p class="docs-lede">
    Each provider is a reviewed adapter inside the trusted Shimpz control plane. Assistants keep declaring
    only a provider, scopes, and the Powers that use the Account. Endpoints, callbacks, client credentials,
    token parsing, refresh, and revocation never become Assistant-controlled configuration.
  </p>
</header>

<aside class="scope-note" aria-labelledby="provider-readiness-title">
  <span id="provider-readiness-title" class="kicker">Current implementation status</span>
  <p>
    Cloudflare is the first complete and live-validated reference for read-only zones and DNS records. The
    Account declaration and private invocation envelope are provider-neutral. The hosted broker, browser
    handoff, and OAuth-client vault are being generalized before provider two; adding another provider is not
    currently a registry-only change.
  </p>
</aside>

<section class="guide-section" aria-labelledby="provider-boundaries-title">
  <span class="section-label">Trust boundaries</span>
  <h2 id="provider-boundaries-title">Keep every credential with its only legitimate custodian</h2>
  <ol>
    <li>The private platform vault stores the OAuth application's client credentials as write-only encrypted state.</li>
    <li>The hosted broker owns the exact public callback and turns it into a short-lived, consume-once grant.</li>
    <li>The local Admin starts browser consent but never receives a client secret, code, access token, or refresh token.</li>
    <li>The controller encrypts the person's grant and binds it to one Team, Assistant, Account, provider, and scope set.</li>
    <li>The Brain sees no OAuth material. A selected Assistant Power receives only its bounded access token.</li>
  </ol>
  <p>
    A connection authorizes the declared scopes; it does not approve a write Power. Approval, Account access,
    Team isolation, and Assistant selection remain independent gates.
  </p>
</section>

<section class="guide-section" aria-labelledby="provider-adapter-title">
  <span class="section-label">Closed adapter</span>
  <h2 id="provider-adapter-title">Model documented differences explicitly</h2>
  <p>Before writing code, use the provider's current official documentation to record:</p>
  <ul>
    <li>exact authorization, token, revocation, issuer, metadata, callback, and API origins;</li>
    <li>client authentication, S256 PKCE behavior, grant and response types, and redirect matching;</li>
    <li>scope syntax and the smallest scopes needed by the first Assistant Powers;</li>
    <li>token fields, expiry, optional or required refresh tokens, rotation, and revocation semantics;</li>
    <li>response content types, errors, size bounds, rate limits, and client-secret rotation procedure.</li>
  </ul>
  <p>
    Shimpz uses Authorization Code and S256 PKCE for every interactive flow. State is short-lived,
    single-use, and bound to the session, Team, Assistant, Account, provider, exact scopes, callback mode,
    and return destination. Redirects are exact and OAuth HTTP requests do not follow redirects.
  </p>
</section>

<section class="guide-section" aria-labelledby="provider-mixup-title">
  <span class="section-label">Multiple authorization servers</span>
  <h2 id="provider-mixup-title">Prevent provider mix-up by construction</h2>
  <p>
    The provider selected before consent must remain bound through callback validation, token exchange,
    encrypted storage, refresh, revocation, and Assistant invocation. Shimpz uses a distinct callback for
    each authorization server unless the adapter validates the authorization response issuer with RFC 9207.
    A response from another provider is rejected before any token exchange.
  </p>
  <p>
    The Admin validates the provider's exact admitted authorization destination. Supporting another provider
    never means accepting an arbitrary HTTPS URL or using an open return redirect.
  </p>
</section>

<section class="guide-section" aria-labelledby="provider-evidence-title">
  <span class="section-label">Release evidence</span>
  <h2 id="provider-evidence-title">Prove the provider before enabling it in stable</h2>
  <ol>
    <li>Test exact metadata and reject unknown hosts, ports, schemes, fragments, scopes, and fields.</li>
    <li>Test state replay, expiry, identity mismatch, wrong issuer, wrong provider, and wrong callback.</li>
    <li>Test strict token, refresh, and revocation responses, including duplicate JSON and scope escalation.</li>
    <li>Test vault encryption, authenticated metadata, migration, tampering, redaction, and client-secret rotation.</li>
    <li>Test the local handoff, paused-turn continuation, cancellation, restart, and stale execution state.</li>
    <li>Deploy the immutable stable candidate, complete real owner consent, and run one least-privilege read Power.</li>
    <li>Verify refresh and disconnect where supported, inspect logs for secrets, and require green GitHub Actions.</li>
  </ol>
  <p>
    Write Powers require additional approval, idempotency, replay, and recovery evidence. An uncertain write
    is never replayed or deleted merely to unblock a Team.
  </p>
</section>

<section class="guide-section" aria-labelledby="provider-ready-title">
  <span class="section-label">Expansion gate</span>
  <h2 id="provider-ready-title">Provider two starts only after the common path exists</h2>
  <ul>
    <li>Provider metadata and behavior resolve through one closed adapter interface.</li>
    <li>The encrypted platform vault is provider-keyed and has a tested migration.</li>
    <li>Broker state, grants, leases, audit events, and encrypted records bind provider and exact scopes.</li>
    <li>Provider mix-up has an automated negative test.</li>
    <li>Hosted transaction state is shared before the broker is horizontally distributed.</li>
    <li>Cloudflare still passes the same production smoke test through the common path without a compatibility branch.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="provider-references-title">
  <span class="section-label">Standards baseline</span>
  <h2 id="provider-references-title">Use current primary sources</h2>
  <ul>
    <li><a href="https://www.rfc-editor.org/rfc/rfc9700.html">OAuth 2.0 Security Best Current Practice · RFC 9700</a></li>
    <li><a href="https://www.rfc-editor.org/rfc/rfc7636.html">Proof Key for Code Exchange · RFC 7636</a></li>
    <li><a href="https://www.rfc-editor.org/rfc/rfc8252.html">OAuth 2.0 for Native Apps · RFC 8252</a></li>
    <li><a href="https://www.rfc-editor.org/rfc/rfc7009.html">OAuth 2.0 Token Revocation · RFC 7009</a></li>
    <li><a href="https://www.rfc-editor.org/rfc/rfc9207.html">Authorization Server Issuer Identification · RFC 9207</a></li>
    <li><a href="https://developers.cloudflare.com/fundamentals/oauth/create-an-oauth-client/">Cloudflare OAuth clients · official documentation</a></li>
  </ul>
</section>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec v2 guide">
  <a href="/developers/assistants/spec/accounts/"><span>Back</span><strong>Accounts</strong></a>
  <a href="/developers/assistants/spec/permissions/"><span>Next</span><strong>Permissions</strong></a>
</nav>
