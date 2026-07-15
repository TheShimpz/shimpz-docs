<script lang="ts">
  import { onDestroy } from "svelte";

  type CodeLine = {
    value: string;
    kind?: "command" | "output";
    prompt?: string;
  };

  type CodeToken = {
    value: string;
    kind: "plain" | "key" | "section" | "string" | "number" | "punctuation" | "comment";
  };

  type Props = {
    label: string;
    title: string;
    lines: readonly CodeLine[];
    variant?: "terminal" | "code";
    language?: "toml" | "text";
  };

  const BLOCK_COPY_INDEX = -1;

  let { label, title, lines, variant = "terminal", language = "text" }: Props = $props();
  const blockSource = $derived(lines.map((line) => line.value).join("\n"));
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

  function tokenizeTomlValue(value: string): CodeToken[] {
    const tokens: CodeToken[] = [];
    let cursor = 0;

    while (cursor < value.length) {
      const character = value[cursor];

      if (character === "#") {
        tokens.push({ value: value.slice(cursor), kind: "comment" });
        break;
      }

      if (character === '"' || character === "'") {
        const quote = character;
        let end = cursor + 1;
        while (end < value.length) {
          if (value[end] === quote && (quote === "'" || value[end - 1] !== "\\")) {
            end += 1;
            break;
          }
          end += 1;
        }
        tokens.push({ value: value.slice(cursor, end), kind: "string" });
        cursor = end;
        continue;
      }

      const number = value.slice(cursor).match(/^[+-]?\d(?:[\d_]*\d)?(?:\.\d(?:[\d_]*\d)?)?/);
      if (number) {
        tokens.push({ value: number[0], kind: "number" });
        cursor += number[0].length;
        continue;
      }

      if ("[]=,{}".includes(character)) {
        tokens.push({ value: character, kind: "punctuation" });
        cursor += 1;
        continue;
      }

      let end = cursor + 1;
      while (
        end < value.length &&
        !['"', "'", "#", "[", "]", "=", ",", "{", "}"].includes(value[end]) &&
        !/[+\-\d]/.test(value[end])
      ) {
        end += 1;
      }
      tokens.push({ value: value.slice(cursor, end), kind: "plain" });
      cursor = end;
    }

    return tokens;
  }

  function tokenizeTomlLine(value: string): CodeToken[] {
    const leadingWhitespace = value.match(/^\s*/)?.[0] ?? "";
    const content = value.slice(leadingWhitespace.length);
    const tokens: CodeToken[] = leadingWhitespace ? [{ value: leadingWhitespace, kind: "plain" }] : [];
    const section = content.match(/^(\[\[?)([A-Za-z0-9_.-]+)(\]\]?)(\s*(?:#.*)?)$/);

    if (section) {
      tokens.push(
        { value: section[1], kind: "punctuation" },
        { value: section[2], kind: "section" },
        { value: section[3], kind: "punctuation" },
        ...tokenizeTomlValue(section[4]),
      );
      return tokens;
    }

    const assignment = content.match(/^([A-Za-z0-9_.-]+)(\s*)(=)(.*)$/);
    if (assignment) {
      tokens.push(
        { value: assignment[1], kind: "key" },
        { value: assignment[2], kind: "plain" },
        { value: assignment[3], kind: "punctuation" },
        ...tokenizeTomlValue(assignment[4]),
      );
      return tokens;
    }

    tokens.push(...tokenizeTomlValue(content));
    return tokens;
  }

  function tokensFor(value: string): CodeToken[] {
    return language === "toml" ? tokenizeTomlLine(value) : [{ value, kind: "plain" }];
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
    {#if variant === "code"}
      <span class="terminal-language">{language}</span>
      <button
        type="button"
        class:copied={statusFor(BLOCK_COPY_INDEX) === "copied"}
        class:error={statusFor(BLOCK_COPY_INDEX) === "error"}
        class="terminal-copy"
        onclick={() => copyValue(blockSource, BLOCK_COPY_INDEX)}
        aria-label={`${buttonText(BLOCK_COPY_INDEX)} entire ${label}`}
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

  {#if variant === "code"}
    <pre class="code-file" aria-label={`${label} source`}><code data-language={language}>{#each lines as line, index}{#each tokensFor(line.value) as token}<span class={`syntax-${token.kind}`}>{token.value}</span>{/each}{#if index < lines.length - 1}{"\n"}{/if}{/each}</code></pre>
  {:else}
    {#each lines as line, index}
      <div class:terminal-output={line.kind === "output"} class:terminal-command={line.kind !== "output"}>
        <span aria-hidden="true">{line.prompt ?? (line.kind === "output" ? "›" : "$")}</span>
        <code>{line.value}</code>
        <button
          type="button"
          class:copied={statusFor(index) === "copied"}
          class:error={statusFor(index) === "error"}
          class="terminal-copy"
          onclick={() => copyValue(line.value, index)}
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
  {/if}
</div>
