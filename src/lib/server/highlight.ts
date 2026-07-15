import { codeToTokens, type BundledLanguage } from "shiki";

import type { HighlightedCode } from "$lib/code";

const CODE_THEME = "synthwave-84";

// Keep highlighting in server loads so grammars and engines never enter the browser bundle.
export async function highlightCode(
  code: string,
  language: BundledLanguage | "text",
): Promise<HighlightedCode> {
  const result = await codeToTokens(code, {
    lang: language,
    theme: CODE_THEME,
  });

  return {
    code,
    language,
    foreground: result.fg ?? "#f4f4f5",
    tokens: result.tokens.map((line) =>
      line.map(({ content, color, fontStyle }) => ({ content, color, fontStyle })),
    ),
  };
}
