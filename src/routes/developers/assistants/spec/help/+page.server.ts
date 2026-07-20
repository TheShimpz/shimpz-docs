import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const help = `# Shimpz Assistant

This reference Assistant demonstrates an X Account and manual Mux Secrets.

## Try these prompts

- “Who is @XDevelopers?”
- “Draft a short launch Post and show it to me before publishing.”
- “List my 5 most recent Mux direct uploads.”
- “Create a Mux test upload intent, then cancel that exact upload.”
- “Verify this raw Mux webhook body and its Mux-Signature header.”

The Admin opens X for Account consent or a password-style modal for missing Mux values. Never paste private
values into chat. X writes and Mux create or cancel actions require explicit approval.`;

export const load: PageServerLoad = async () => ({
  help: await highlightCode(help, "markdown"),
});
