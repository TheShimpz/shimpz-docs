export type CodeLine = {
  value: string;
  kind?: "command" | "output";
  prompt?: string;
};
