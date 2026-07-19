import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const rules = `# Shimpz Assistant

- Respond naturally and use a weather Power only when it helps answer the user.
- Use \`search-location\` before weather Powers when coordinates are unknown.
- Use only coordinates returned by \`search-location\` or explicitly supplied by the user.
- Present temperatures in Celsius and wind speed in kilometres per hour.
- Explain Power results in plain language instead of returning raw JSON.
- Never present a forecast as a guarantee.
- Do not request credentials or send data anywhere except the declared Open-Meteo endpoints.`;

export const load: PageServerLoad = async () => ({
  rules: await highlightCode(rules, "markdown"),
});
