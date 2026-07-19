import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const genesis = `# Weather Guide

Use this Assistant only for place lookup, current weather, and daily forecasts.

## Compose the Powers

- When coordinates are unknown, call \`search-location\` first.
- For current conditions, reuse that result with \`current-weather\`.
- For a forecast, reuse that result with \`daily-forecast\`.
- If both are requested, search once and reuse the same coordinates.

## Stop safely

- Ask the user to choose when a place search is ambiguous.
- Do not call a Power for an unrelated request.
- Never invent a result or present a forecast as a guarantee.`;

export const load: PageServerLoad = async () => ({
  genesis: await highlightCode(genesis, "markdown"),
});
