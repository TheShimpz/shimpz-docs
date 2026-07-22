import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const projectFiles = `shimpz.assistant.toml
GENESIS.md
help/
  HELP-en.md
schemas/
  inspect-record.input.schema.json
  inspect-record.output.schema.json`;

export const load: PageServerLoad = async () => ({
  projectFiles: await highlightCode(projectFiles, "text"),
});
