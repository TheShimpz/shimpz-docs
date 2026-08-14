<script lang="ts">
  import "@shimpz/frontend/tokens.css";

  import { ActionRequestFields, Button, DialogFrame, SelectField, themeClass } from "@shimpz/frontend";

  import type { ActionRequestExample } from "$lib/actionRequestExamples";

  let {
    id,
    examples,
  }: {
    id: string;
    examples: ActionRequestExample[];
  } = $props();

  let selectedId = $state("");
  const selected = $derived(examples.find((example) => example.id === selectedId) ?? examples[0]);

  const labels = $derived({
    chooseOption: "Choose an option",
    selectionHint: selected.request.kind === "input:choices"
      ? `Choose from ${selected.request.min_selections} to ${selected.request.max_selections} options.`
      : "",
    passwordLabel: "Current platform password",
    totpLabel: "Authenticator code",
    totpPlaceholder: "000000",
  });
</script>

{#if selected}
  <figure
    class={['request-example', themeClass]}
    data-slot="request-example"
    data-request-example={id}
    data-kind={selected.request.kind}
  >
    {#if examples.length > 1}
      <div class="example-switcher">
        <SelectField
          id={`${id}-request-example`}
          label="Request type"
          options={examples.map((example) => ({ value: example.id, label: example.label }))}
          value={selected.id}
          aria-controls={`${id}-request-stage`}
          onchange={(event) => selectedId = event.currentTarget.value}
        />
      </div>
    {/if}

    <div id={`${id}-request-stage`} class="example-stage">
      <DialogFrame
        kicker={selected.kicker}
        title={selected.title}
        titleId={`${id}-request-title`}
        titleLevel={3}
        lead={selected.description}
      >
        <p class="request-context">
          Action <code><bdi>{selected.action}</bdi></code> from <strong><bdi>Example Assistant</bdi></strong> v1.0.0
          needs human validation. Expires in 300 seconds.
        </p>
        <fieldset class="request-controls" disabled aria-label="Rendered request controls">
          <ActionRequestFields request={selected.request} resetKey={selected.id} {labels} />
        </fieldset>
        {#snippet footer()}
          <Button type="button" variant="secondary" disabled>Deny and stop</Button>
          <Button type="button" disabled>{selected.primaryLabel}</Button>
        {/snippet}
      </DialogFrame>
    </div>
    <figcaption>
      Native, non-submitting documentation preview using the same frontend primitives as Shimpz. {selected.caption}
      Controls are disabled and nothing is submitted.
    </figcaption>
  </figure>
{/if}

<style>
  .request-example {
    display: grid;
    gap: 0.75rem;
    margin: 1.75rem 0 0;
    color: var(--shimpz-color-text);
    font-family: var(--shimpz-font-sans);
  }

  .example-switcher {
    display: grid;
    padding: 0.75rem;
    background: var(--shimpz-color-surface-raised);
    border: 1px solid var(--shimpz-color-border);
  }

  .example-stage {
    min-width: 0;
    padding: clamp(0.75rem, 3vw, 1.5rem);
    background: var(--shimpz-color-bg);
    border-left: 2px solid var(--shimpz-color-cyan);
    box-shadow: inset 0 0 0 1px var(--shimpz-color-border);
  }

  .example-stage :global(.shimpz-dialog-frame) {
    width: min(100%, 42rem);
    margin-inline: auto;
  }

  .request-context {
    margin: 0;
    color: var(--shimpz-color-text-muted);
    font-size: 0.82rem;
    line-height: 1.55;
  }

  .request-context code {
    color: var(--shimpz-color-cyan);
    font-family: var(--shimpz-font-mono);
  }

  .request-controls {
    display: grid;
    min-width: 0;
    gap: var(--shimpz-space-3);
    margin: 0;
    padding: 0;
    border: 0;
  }

  figcaption {
    color: var(--color-muted-2);
    font: 400 0.72rem/1.55 var(--font-mono);
  }

  @media (max-width: 520px) {
    .example-switcher { padding: 0.6rem; }
  }
</style>
