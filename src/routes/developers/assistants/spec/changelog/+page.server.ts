import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const changelog = `# Changelog

## 0.1.0

- Added one controller-owned Cloudflare OAuth Account.
- Added bounded zone and DNS record listing Powers.
- Restricted outbound traffic to the exact api.cloudflare.com host.
- Kept both provider operations read-only and schema-validated.`;

export const load: PageServerLoad = async () => ({
  changelog: await highlightCode(changelog, "markdown"),
});
