import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const changelog = `# Changelog

## 0.6.0

- Renamed provider authorization from Connections to Accounts.
- Declared one controller-owned X Account for the four Powers that reference it.
- Added three just-in-time Mux BYOK Secrets, each delivered only to its declaring Power.
- Restricted outbound traffic to the exact api.x.com and api.mux.com hosts.
- Kept explicit approval on X Post writes and Mux upload mutations.`;

export const load: PageServerLoad = async () => ({
  changelog: await highlightCode(changelog, "markdown"),
});
