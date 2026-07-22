import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const help = `# Record Reader

Use this Assistant to inspect one record you already know.

Try asking:

> Inspect record customer-42 and explain its status.

It reads information only. It does not change or delete records.`;

export const load: PageServerLoad = async () => ({
  help: await highlightCode(help, "markdown"),
});
