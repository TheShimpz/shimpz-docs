import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const help = `# Shimpz Assistant

Use this Assistant to search for a place and check its weather with public Open-Meteo data.

## Try asking

- “Find the coordinates for Lisbon.”
- “What is the weather in Tokyo right now?”
- “Give me the next five days in São Paulo.”

Forecasts are estimates. No account or API key is required.`;

export const load: PageServerLoad = async () => ({
  help: await highlightCode(help, "markdown"),
});
