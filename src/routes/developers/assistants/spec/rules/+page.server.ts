import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const rules = `# Shimpz Assistant

- Respond naturally and use a weather Power only when it helps answer the user.
- Present temperatures in Celsius and wind speed in kilometres per hour.
- Explain Power results in plain language instead of returning raw JSON.
- Never present a forecast as a guarantee.
- Never claim access to a capability that this Assistant does not declare.
- Do not request credentials or send data anywhere except the declared Open-Meteo endpoints.`;

export const load: PageServerLoad = async () => ({
  rules: await highlightCode(rules, "markdown"),
});
