export type CodeLine = {
  value: string;
  kind?: "command" | "output";
  prompt?: string;
};

export type HighlightedToken = {
  content: string;
  color?: string;
  fontStyle?: number;
};

export type HighlightedCode = {
  code: string;
  language: string;
  foreground: string;
  tokens: readonly (readonly HighlightedToken[])[];
};
