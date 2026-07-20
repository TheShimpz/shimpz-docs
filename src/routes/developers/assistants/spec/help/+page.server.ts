import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const help = `# Shimpz Assistant

Use this Assistant to read public X profiles and manage Posts for one connected X account.

## Try asking

- “Look up the public X profile @TheShimpz.”
- “Which X account is connected?”
- “Draft this Post and show me the exact text before asking to publish it.”
- “Delete the Post we just created.”

The Admin securely asks for a missing X credential when a Power needs it. Never paste a token or secret into
chat. Publishing and deleting each require your explicit approval.`;

export const load: PageServerLoad = async () => ({
  help: await highlightCode(help, "markdown"),
});
