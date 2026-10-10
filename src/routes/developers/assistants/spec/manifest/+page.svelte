<script lang="ts">
  import CodeBlock from "$lib/components/CodeBlock.svelte";

  import type { PageData } from "./$types";

  let { data }: { data: PageData } = $props();
</script>

<svelte:head>
  <title>shimpz.toml — Shimpz docs</title>
  <link rel="canonical" href="https://docs.shimpz.com/developers/assistants/spec/manifest/" />
  <meta name="description" content="Declare a Shimpz Assistant's identity and security intent." />
</svelte:head>

<nav class="docs-breadcrumb" aria-label="Breadcrumb">
  <a href="/developers/assistants/spec/">Assistant Spec v1</a><span aria-hidden="true">/</span>
  <strong>shimpz.toml</strong>
</nav>

<header class="docs-page-header">
  <span class="section-label">Manifest and Genesis</span>
  <h1>Declare identity and the smallest security boundary</h1>
  <p class="docs-lede">
    <code>shimpz.toml</code> contains public identity, Brain guidance, and access intent. It never
    contains Action schemas, runtime commands, OAuth endpoints, client credentials, or tokens.
  </p>
</header>

<section class="guide-section" aria-labelledby="example-title">
  <span class="section-label">Complete example</span>
  <h2 id="example-title">Two required tables and optional link and Integration tables</h2>
  <CodeBlock label="Assistant security intent" title="shimpz.toml" variant="code" {...data.manifest} />
</section>

<section class="guide-section" aria-labelledby="identity-title">
  <span class="section-label">Identity</span>
  <h2 id="identity-title">Describe one Assistant under [shimpz]</h2>
  <dl>
    <dt><code>[shimpz]</code></dt>
    <dd>The required parent table for identity, publication disclosure, and Genesis.</dd>
    <dt><code>spec</code></dt>
    <dd>The integer <code>1</code>. No other Assistant Spec version is supported.</dd>
    <dt><code>id</code></dt>
    <dd>
      A stable identifier of 1 to 40 characters: lowercase letters and digits in hyphen-separated
      segments, starting with a letter. It is independent of repository and Python project names.
      <code>postgres</code>, <code>assistant-egress</code>, and
      <code>shimpz-assistant-egress</code> are reserved.
    </dd>
    <dt><code>version</code></dt>
    <dd>A stable semantic version such as <code>0.1.0</code>.</dd>
    <dt><code>name</code></dt>
    <dd>A display name from 1 to 80 characters, without surrounding whitespace or line breaks.</dd>
    <dt><code>summary</code></dt>
    <dd>
      A short, single-line outcome description from 1 to 80 characters, shown in full under the Assistant's name. With
      SDK 0.6.0, it joins the <a href="/developers/assistants/requests/copy/">message catalog</a> and is translated with
      it, so it must be NFC-normalized English without braces, and every translation must fit 80 characters too.
    </dd>
    <dt><code>description</code></dt>
    <dd>
      A plain-language paragraph from 1 to 400 characters, shown under the summary on the Assistant's page. Write it on
      one line, without surrounding whitespace. Like the summary, it joins the message catalog and is translated into
      every interface language, so it must be NFC-normalized English without braces; every translation must fit 500
      characters.
    </dd>
    <dt><code>creators</code></dt>
    <dd>One to 16 unique Account-owned Creator handles, each beginning with <code>@</code>.</dd>
    <dt><code>github</code></dt>
    <dd>The exact HTTPS URL of the public GitHub repository.</dd>
    <dt><code>[shimpz.links]</code></dt>
    <dd>
      An optional table of the Creator's public pages, shown as the Creator's links on the Assistant's page. Its keys
      are <code>site</code>, <code>github</code>, <code>x</code>, <code>youtube</code>, <code>linkedin</code>, and
      <code>instagram</code>, each at most once, and the table needs at least one when it is present. Each value is an
      <code>https</code> URL of at most 256 characters in the form required for <code>help_url</code>, on the kind's
      own host: <code>github.com</code> for <code>github</code>, <code>x.com</code> for <code>x</code>,
      <code>youtube.com</code> or <code>www.youtube.com</code> for <code>youtube</code>, <code>linkedin.com</code> or
      <code>www.linkedin.com</code> for <code>linkedin</code>, <code>instagram.com</code> or
      <code>www.instagram.com</code> for <code>instagram</code>, and any public host for <code>site</code>. Nothing
      verifies these links, and they are separate from the repository named by <code>github</code> above.
    </dd>
    <dt><code>genesis</code></dt>
    <dd>
      Bounded behavior and Action-composition guidance loaded by the Brain. Genesis never grants
      authority. <code>help.md</code> is not part of Assistant Spec v1 and is not loaded as Brain guidance.
    </dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="access-title">
  <span class="section-label">Access intent</span>
  <h2 id="access-title">Request only what the code needs</h2>
  <dl>
    <dt><code>[network]</code></dt>
    <dd>The required parent table for Assistant outbound network intent.</dd>
    <dt><code>allowed_hosts</code></dt>
    <dd>
      A unique list of exact public DNS hostnames. Use <code>[]</code> for no network access. Schemes,
      ports, paths, wildcards, IP literals, and private or reserved names are invalid.
    </dd>
    <dt><code>[integrations.&lt;provider&gt;]</code></dt>
    <dd>
      An optional table keyed by a registered provider id. Its only key is a unique, non-empty
      <code>scopes</code> list from that provider's supported catalog. Both the provider and every scope must exist in
      the current published catalog. Provider endpoints and OAuth client configuration remain Controller-owned.
    </dd>
    <dt><code>[stored_inputs.&lt;id&gt;]</code></dt>
    <dd>
      An optional table for a token-like third-party value that Team keeps encrypted for the Team once a person enters
      it, at most eight per manifest. It holds <code>kind = "password"</code>, a <code>label</code> of 1 to 80
      characters, a help-text <code>description</code> of 1 to 400 characters, and a required <code>help_url</code>.
      The description is what a person reads wherever the value is asked for: in plain language, what the secret is and
      the steps to get it, written for someone who has never made one. The label and the description join the message
      catalog and are translated like the summary, so both must be NFC-normalized English without braces, and every
      translation must fit 120 and 500 characters. A provider permission name such as <code>ads_read</code> is kept by
      translation intent, not guaranteed, so the linked page stays the authority. It also declares where Team places the value in provider
      calls: one <code>host</code> from <code>allowed_hosts</code>, exactly one <code>header</code> (with an optional
      <code>scheme</code> such as <code>"Bearer"</code>) or <code>query</code> parameter, and an optional
      <code>hmac</code> naming another Stored Input of the same host, which places the lowercase hexadecimal HMAC-SHA256
      keyed by this value over that one, as Meta's <code>appsecret_proof</code>. Team-owned headers such as
      <code>Host</code> or <code>Content-Length</code> and a field another Stored Input uses on the same host are
      refused. The required <a href="#routes-title"><code>routes</code></a> list names the only endpoints on that host
      that ever receive the value. Each Action names the ids it uses, any number of them, and only its calls carry
      them; several Actions may share one. See
      <a href="/developers/assistants/requests/input/#password-title">password input</a>.
    </dd>
    <dt><code>help_url</code></dt>
    <dd>
      A required key of a <code>[stored_inputs.&lt;id&gt;]</code> table: the closest official page where a person
      creates or finds the value, such as an API key page, or the provider's documentation when making it takes several
      steps. Admin shows it after the description as one "How to get it" link that opens in a new tab. It must be one
      canonical <code>https</code> URL of at most 2,048 characters on a public
      DNS host, with a path and an optional query, and without a port, credentials, a fragment, or a <code>.</code> or
      <code>..</code> segment, written exactly as a browser prints it: for example
      <code>https://dashboard.exa.ai/api-keys</code>, not <code>https://dashboard.exa.ai</code>.
    </dd>
  </dl>
</section>

<section class="guide-section" aria-labelledby="routes-title">
  <span class="section-label">Stored Input routes</span>
  <h2 id="routes-title">Name every endpoint that receives the value</h2>
  <p>
    A Stored Input reaches its <code>host</code> only on the calls its <code>routes</code> admit. List each method
    and path your Actions send it on, and nothing more: a key that only searches must never travel to an endpoint
    that changes billing or reads other credentials.
  </p>
  <CodeBlock label="Stored Input with reviewed routes" title="shimpz.toml" variant="code" {...data.routes} />
  <dl>
    <dt><code>routes</code></dt>
    <dd>
      A required key of a <code>[stored_inputs.&lt;id&gt;]</code> table: 1 to 32 inline tables
      <code>{`{ method, path, query }`}</code>, with no two sharing the same <code>method</code> and
      <code>path</code>. <code>query</code> is optional.
    </dd>
    <dt><code>method</code></dt>
    <dd>One of <code>GET</code>, <code>HEAD</code>, <code>POST</code>, <code>PUT</code>, <code>PATCH</code>, or <code>DELETE</code>.</dd>
    <dt><code>path</code></dt>
    <dd>
      At most 512 characters of <code>/</code>-prefixed segments. A segment is either a literal of 1 to 64 unreserved
      characters (<code>A-Z</code>, <code>a-z</code>, <code>0-9</code>, <code>-</code>, <code>.</code>,
      <code>_</code>, <code>~</code>) other than <code>.</code> and <code>..</code>, or <code>*</code>, which matches
      exactly one segment of 1 to 256 of those characters, such as a numeric object id. There is no root path, empty
      or trailing segment, partial wildcard such as <code>v*</code>, or wildcard spanning several segments:
      <code>/v23.0/*/messages</code> matches <code>/v23.0/1234567890/messages</code> but not
      <code>/v23.0/1/2/messages</code>.
    </dd>
    <dt><code>query</code></dt>
    <dd>
      Optional selectors for a provider parameter that changes what an endpoint returns or acts on, such as Meta's
      <code>fields</code> on an object that can also return a token. Each is <code>{`{ name, values }`}</code>: a
      name of 1 to 64 unreserved characters, unique without regard to case, and 1 to 16 unique values of at most 256
      characters. Write each value exactly as your Action's query encoder sends it, with reserved characters
      percent-encoded in uppercase hexadecimal: Python's <code>urlencode</code> sends <code>id,name</code> as
      <code>id%2Cname</code>. A call on that route must carry each selector exactly once, under that exact name,
      with one listed value; other parameters stay free. At most 8 selectors per route.
    </dd>
  </dl>
  <p>
    A route may never name an endpoint that issues, lists, or exchanges credentials. A literal segment is refused
    when, lowercased and without <code>-</code>, <code>_</code>, <code>.</code>, and <code>~</code>, it contains
    <code>apikey</code>, <code>authoriz</code>, <code>credential</code>, <code>oauth</code>, <code>password</code>,
    <code>secret</code>, or <code>token</code>, so <code>/v1/api-keys</code> and <code>/oauth/access_token</code>
    fail validation. Team applies the same test to every segment of each call, so a <code>*</code> never reaches
    such an endpoint either.
  </p>
  <p>
    Team places a credential only when <strong>every</strong> Stored Input the Action declares for the call's host
    admits the call. When two Stored Inputs share a host, such as Meta's access token and its app secret, give them
    the same routes; otherwise a call outside either list is refused before any credential is placed. See
    <a href="/developers/assistants/spec/execution/#routes-call-title">how Team matches each call</a>.
  </p>
</section>

<aside class="scope-note" aria-labelledby="validation-title">
  <span id="validation-title" class="kicker">Closed and reviewed</span>
  <p>
    Root-level fields, misplaced fields, and unknown keys fail validation. The
    <a href="/specs/assistant/manifest.schema.json">published shimpz.toml schema</a> describes the
    document shape; SDK validation and Controller admission enforce additional semantic invariants.
  </p>
</aside>

<nav class="docs-page-nav docs-page-nav-split" aria-label="Continue the Assistant Spec">
  <a href="/developers/assistants/spec/"><span>Back</span><strong>Spec overview</strong></a>
  <a href="/developers/assistants/spec/execution/"><span>Next</span><strong>Execution model</strong></a>
</nav>
