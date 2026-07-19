import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const changelog = `# Changelog

## 0.1.0

- Added three typed Open-Meteo Powers for location search, current weather, and daily forecasts.
- Added localized in-Admin help and a bounded Genesis playbook for the Team Brain.`;

export const load: PageServerLoad = async () => ({
  changelog: await highlightCode(changelog, "markdown"),
});
