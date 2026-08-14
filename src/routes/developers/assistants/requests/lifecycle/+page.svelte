<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>Action request lifecycle and security — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/requests/lifecycle/" />
  <meta
    name="description"
    content="Design deterministic Action request replay, handle denial, and keep credentials at the last boundary."
  />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/requests/">Human requests</a><span aria-hidden="true">/</span>
  <strong>Replay and lifecycle</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Deterministic continuation</span>
  <h1>Write a replay-safe prefix and an action-only suffix</h1>
  <p class="docs-lede">
    A human request does not keep untrusted code suspended in memory. It ends the Action process. After a valid human
    response, Shimpz invokes the same immutable Action again and the SDK deterministically replays completed requests.
  </p>
</header>

<section class="guide-section" aria-labelledby="sequence-title">
  <span class="section-label">What actually happens</span>
  <h2 id="sequence-title">One logical Action may use several short processes</h2>
  <ol>
    <li>The Controller invokes the reviewed Action with its original input and no response transcript.</li>
    <li>The SDK reaches request ordinal 0, emits a canonical suspension, and terminates the process.</li>
    <li>Team validates the declared capability and shows a challenge through Admin or Store.</li>
    <li>The authenticated Supervisor or Owner responds once before the 300-second expiry.</li>
    <li>Team re-invokes the exact immutable binding with the original input and a bounded response transcript.</li>
    <li>The SDK matches kind, ordinal, and request fingerprint, returns the recorded value, and continues.</li>
    <li>A later request repeats the cycle; a terminal result is accepted only after every response was consumed.</li>
  </ol>
</section>

<section class="guide-section" aria-labelledby="ordering-title">
  <span class="section-label">Safe ordering</span>
  <h2 id="ordering-title">Collect inputs, request one authorization, then access secrets and act</h2>
  <CodeBlock
    label="Illustrative replay-safe Action shape"
    title="actions/publish_record.py"
    variant="code"
    {...data.safeOrder}
  />
  <p>
    Reading an Integration access token closes the human-request phase. The SDK rejects every later request. This
    makes the boundary visible in code, but it cannot prove that arbitrary outbound traffic had no side effect;
    Creator code must still obey request-before-action. The final provider helper is illustrative Creator code.
  </p>
</section>

<section class="guide-section" aria-labelledby="determinism-title">
  <span class="section-label">Fingerprint stability</span>
  <h2 id="determinism-title">The same ordinal must describe the same request on every replay</h2>
  <ul>
    <li>Build request copy and options from original Action inputs or already replayed responses.</li>
    <li>Do not use current time, randomness, unordered external data, mutable globals, or network reads.</li>
    <li>Keep option values stable; changing copy, bounds, order, or kind changes the canonical fingerprint.</li>
    <li>A changed Assistant image, Integration generation, Team context, principal, or fingerprint fails closed.</li>
  </ul>
</section>

<section class="guide-section" aria-labelledby="terminal-title">
  <span class="section-label">Terminal outcomes</span>
  <h2 id="terminal-title">Denial is control flow owned by Team, not an exception to recover from</h2>
  <p>
    Denial, dismiss, cancellation, expiry, failed authentication, unavailable assurance, malformed frames, and
    divergent replay all stop the logical Action. Assistant code does not receive a false value or catchable denial
    result. Team deletes the abandoned continuation and never retries the action automatically.
  </p>
  <p>
    If an earlier Action in the same Brain-requested batch already completed an external action, that action remains
    complete. The blocked batch is abandoned and audited; a later user turn is a separate operation.
  </p>
</section>

<section class="guide-section" aria-labelledby="secret-title">
  <span class="section-label">Secret custody</span>
  <h2 id="secret-title">Keep every sensitive value at its narrowest authority</h2>
  <dl>
    <dt>Integration token</dt>
    <dd>Injected only for an Action that declared the Integration; reading it closes requests.</dd>
    <dt><code>input:password</code></dt>
    <dd>
      A third-party secret deliberately delivered to Assistant code. Memory-only, final request, protected from
      logs and results. Prefer an OAuth Integration whenever possible.
    </dd>
    <dt><code>request_auth</code> factor</dt>
    <dd>Owned by the Shimpz platform ceremony. It never enters Assistant input, transcript, logs, or results.</dd>
    <dt>Public request metadata</dt>
    <dd>Bounded title, description, labels, options, Assistant identity, Action identity, and expiry only.</dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="limits-title">
  <span class="section-label">Operational limits</span>
  <h2 id="limits-title">Design within the closed budget</h2>
  <ul>
    <li>At most 8 human requests in one logical Action.</li>
    <li>At most 16 human requests across one Team turn.</li>
    <li>Each challenge expires 300 seconds after Team creates it.</li>
    <li>Password input must be the last request across the entire Team turn and is never durably resumed.</li>
    <li>Local can restore only a non-secret paused request after a controller restart.</li>
    <li>Hosted continuation is memory-only; infrastructure loss stops the operation safely.</li>
  </ul>
</section>

<aside class="scope-note" aria-labelledby="llm-title">
  <span id="llm-title" class="kicker">Checklist for code generators</span>
  <p>
    Declare every exact kind. Use the narrowest presentation. Keep copy printable and secret-free. Put every request
    before token access and side effects. Keep descriptors deterministic. Treat password as third-party,
    non-returnable, and the final request across the whole Team turn. Use <code>request_auth</code> for Shimpz
    authentication. Never implement retry after denial.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue human requests">
  <a href="/developers/assistants/requests/auth/"><span>Back</span><strong>Authentication</strong></a>
  <a href="/developers/assistants/publish/"><span>Next</span><strong>Publish an Assistant</strong></a>
</nav>
