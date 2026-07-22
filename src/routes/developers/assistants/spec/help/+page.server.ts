import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const help = `# Shimpz Cloudflare

This reference Assistant lists Cloudflare zones and DNS records through a read-only OAuth Account.

## Try these prompts

- “List my Cloudflare zones.”
- “Show the DNS records for example.com.”
- “Which zones are currently paused?”

The Admin opens Cloudflare for Account consent when required. Never paste private values into chat. Both Powers
are read-only and the controller delivers the token only to the declared invocation.`;

export const load: PageServerLoad = async () => ({
  help: await highlightCode(help, "markdown"),
});
