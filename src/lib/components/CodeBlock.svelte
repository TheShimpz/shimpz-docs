<script lang="ts">
  import { onDestroy } from "svelte";

  type CodeLine = {
    value: string;
    kind?: "command" | "output";
    prompt?: string;
    copy?: boolean;
  };

  type Props = {
    label: string;
    title: string;
    lines: readonly CodeLine[];
  };

  let { label, title, lines }: Props = $props();
  let copyState = $state<"idle" | "copied" | "error">("idle");
  let resetTimer: ReturnType<typeof setTimeout> | undefined;

  const copyText = $derived(
    lines
      .filter((line) => line.copy ?? line.kind !== "output")
      .map((line) => line.value)
      .join("\n"),
  );

  const buttonText = $derived(
    copyState === "copied" ? "Copied" : copyState === "error" ? "Copy failed" : "Copy",
  );

  function copyWithSelection(value: string): boolean {
    const previousFocus = document.activeElement instanceof HTMLElement ? document.activeElement : undefined;
    const textarea = document.createElement("textarea");
    textarea.value = value;
    textarea.setAttribute("readonly", "");
    textarea.style.position = "fixed";
    textarea.style.opacity = "0";
    document.body.append(textarea);

    try {
      textarea.focus({ preventScroll: true });
      textarea.select();
      return typeof document.execCommand === "function" && document.execCommand("copy");
    } catch {
      return false;
    } finally {
      textarea.remove();
      previousFocus?.focus({ preventScroll: true });
    }
  }

  async function copyCode() {
    let copied = false;

    if (navigator.clipboard?.writeText) {
      try {
        await navigator.clipboard.writeText(copyText);
        copied = true;
      } catch {
        copied = copyWithSelection(copyText);
      }
    } else {
      copied = copyWithSelection(copyText);
    }

    copyState = copied ? "copied" : "error";
    if (resetTimer) clearTimeout(resetTimer);
    resetTimer = setTimeout(() => (copyState = "idle"), copied ? 2000 : 3000);
  }

  onDestroy(() => {
    if (resetTimer) clearTimeout(resetTimer);
  });
</script>

<div class="terminal" role="group" aria-label={label}>
  <div class="terminal-bar">
    <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
    <span class="terminal-title">{title}</span>
    <button
      type="button"
      class:copied={copyState === "copied"}
      class:error={copyState === "error"}
      class="terminal-copy"
      onclick={copyCode}
      aria-label={`${buttonText}: ${label}`}
    >
      {#if copyState === "copied"}
        <svg viewBox="0 0 20 20" aria-hidden="true"><path d="m4 10 3.5 3.5L16 5" /></svg>
      {:else}
        <svg viewBox="0 0 20 20" aria-hidden="true">
          <rect x="6.5" y="6.5" width="9" height="9"></rect>
          <path d="M4.5 12.5h-1v-9h9v1"></path>
        </svg>
      {/if}
      <span aria-live="polite">{buttonText}</span>
    </button>
  </div>

  {#each lines as line}
    <div class:terminal-output={line.kind === "output"} class:terminal-command={line.kind !== "output"}>
      <span aria-hidden="true">{line.prompt ?? (line.kind === "output" ? "›" : "$")}</span>
      <code>{line.value}</code>
    </div>
  {/each}
</div>
