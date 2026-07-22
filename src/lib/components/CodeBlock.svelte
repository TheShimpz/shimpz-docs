<script lang="ts">
  import { onDestroy } from "svelte";

  import type { CodeLine, HighlightedCode } from "$lib/code";

  type BaseProps = {
    label: string;
    title: string;
  };

  type TerminalProps = BaseProps & {
    variant?: "terminal";
    lines: readonly CodeLine[];
  };

  type CodeProps = BaseProps & HighlightedCode & { variant: "code" };
  type Props = TerminalProps | CodeProps;

  const BLOCK_COPY_INDEX = -1;
  const FONT_STYLE_ITALIC = 1;
  const FONT_STYLE_BOLD = 2;
  const FONT_STYLE_UNDERLINE = 4;
  const FONT_STYLE_STRIKETHROUGH = 8;

  let props: Props = $props();
  const blockSource = $derived(
    props.variant === "code" ? props.code : props.lines.map((line) => line.value).join("\n"),
  );
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

  async function copyValue(value: string, index: number) {
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

  function hasFontStyle(fontStyle: number | undefined, flag: number) {
    return Boolean((fontStyle ?? 0) & flag);
  }

  onDestroy(() => {
    for (const timer of resetTimers.values()) clearTimeout(timer);
    resetTimers.clear();
  });
</script>

<div class="terminal" role="group" aria-label={props.label}>
  <div class="terminal-bar">
    <span class="terminal-lights" aria-hidden="true"><i></i><i></i><i></i></span>
    <span class="terminal-title">{props.title}</span>
    {#if props.variant === "code"}
      <span class="terminal-language">{props.language}</span>
      <button
        type="button"
        class:copied={statusFor(BLOCK_COPY_INDEX) === "copied"}
        class:error={statusFor(BLOCK_COPY_INDEX) === "error"}
        class="terminal-copy"
        onclick={() => copyValue(blockSource, BLOCK_COPY_INDEX)}
        aria-label={`${buttonText(BLOCK_COPY_INDEX)} entire ${props.label}`}
      >
        {#if statusFor(BLOCK_COPY_INDEX) === "copied"}
          <svg viewBox="0 0 20 20" aria-hidden="true"><path d="m4 10 3.5 3.5L16 5" /></svg>
        {:else}
          <svg viewBox="0 0 20 20" aria-hidden="true">
            <rect x="6.5" y="6.5" width="9" height="9"></rect>
            <path d="M4.5 12.5h-1v-9h9v1"></path>
          </svg>
        {/if}
        <span aria-live="polite">{buttonText(BLOCK_COPY_INDEX)}</span>
      </button>
    {/if}
  </div>

  {#if props.variant === "code"}
    <pre class="code-file" aria-label={`${props.label} source`}><code data-language={props.language} style:color={props.foreground}>{#each props.tokens as line, index}{#each line as token}<span
              class:is-italic={hasFontStyle(token.fontStyle, FONT_STYLE_ITALIC)}
              class:is-bold={hasFontStyle(token.fontStyle, FONT_STYLE_BOLD)}
              class:is-underlined={hasFontStyle(token.fontStyle, FONT_STYLE_UNDERLINE)}
              class:is-struck={hasFontStyle(token.fontStyle, FONT_STYLE_STRIKETHROUGH)}
              style:color={token.color ?? props.foreground}>{token.content}</span>{/each}{#if index < props.tokens.length - 1}{"\n"}{/if}{/each}</code></pre>
  {:else}
    {#each props.lines as line, index}
      <div class:terminal-output={line.kind === "output"} class:terminal-command={line.kind !== "output"}>
        <span aria-hidden="true">{line.prompt ?? (line.kind === "output" ? "›" : "$")}</span>
        <code>{line.value}</code>
        <button
          type="button"
          class:copied={statusFor(index) === "copied"}
          class:error={statusFor(index) === "error"}
          class="terminal-copy"
          onclick={() => copyValue(line.value, index)}
          aria-label={`${buttonText(index)} line ${index + 1} from ${props.label}`}
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
  {/if}
</div>
