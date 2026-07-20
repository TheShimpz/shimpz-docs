import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const changelog = `# Changelog

## 0.2.0

- Added four typed X Powers for public profile lookup, connected identity, Post creation, and Post deletion.
- Added five declarative X secret fields with least-privilege delivery per Power.
- Restricted provider traffic to the exact api.x.com host.
- Required explicit approval before creating or deleting a Post.`;

export const load: PageServerLoad = async () => ({
  changelog: await highlightCode(changelog, "markdown"),
});
