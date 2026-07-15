<script lang="ts">
  import { onDestroy } from "svelte";

  type CodeLine = {
    value: string;
    kind?: "command" | "output";
    prompt?: string;
  };

  type Props = {
    label: string;
    title: string;
    lines: readonly CodeLine[];
  };

  let { label, title, lines }: Props = $props();
  let copyStates = $state<Record<number, "copied" | "error">>({});
  const resetTimers = new Map<number, ReturnType<typeof setTimeout>>();

  function statusFor(index: number) {
    return copyStates[index] ?? "idle";
  }

  function buttonText(index: number) {
    const status = statusFor(index);
    return status === "copied" ? "Copied" : status === "error" ? "Copy failed" : "Copy";
  }

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

  async function copyLine(value: string, index: number) {
    let copied = false;

    if (navigator.clipboard?.writeText) {
      try {
        await navigator.clipboard.writeText(value);
        copied = true;
      } catch {
        copied = copyWithSelection(value);
      }
    } else {
      copied = copyWithSelection(value);
    }

    copyStates[index] = copied ? "copied" : "error";
    const previousTimer = resetTimers.get(index);
    if (previousTimer) clearTimeout(previousTimer);
    resetTimers.set(
      index,
      setTimeout(() => {
        delete copyStates[index];
        resetTimers.delete(index);
      }, copied ? 2000 : 3000),
    );
  }

  onDestroy(() => {
    for (const timer of resetTimers.values()) clearTimeout(timer);
    resetTimers.clear();
  });
</script>

<div class="terminal" role="group" aria-label={label}>
  <div class="terminal-bar">
    <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
    <span class="terminal-title">{title}</span>
  </div>

  {#each lines as line, index}
    <div class:terminal-output={line.kind === "output"} class:terminal-command={line.kind !== "output"}>
      <span aria-hidden="true">{line.prompt ?? (line.kind === "output" ? "›" : "$")}</span>
      <code>{line.value}</code>
      <button
        type="button"
        class:copied={statusFor(index) === "copied"}
        class:error={statusFor(index) === "error"}
        class="terminal-copy"
        onclick={() => copyLine(line.value, index)}
        aria-label={`${buttonText(index)} line ${index + 1} from ${label}`}
      >
        {#if statusFor(index) === "copied"}
          <svg viewBox="0 0 20 20" aria-hidden="true"><path d="m4 10 3.5 3.5L16 5" /></svg>
        {:else}
          <svg viewBox="0 0 20 20" aria-hidden="true">
            <rect x="6.5" y="6.5" width="9" height="9"></rect>
            <path d="M4.5 12.5h-1v-9h9v1"></path>
          </svg>
        {/if}
        <span aria-live="polite">{buttonText(index)}</span>
      </button>
    </div>
  {/each}
</div>
