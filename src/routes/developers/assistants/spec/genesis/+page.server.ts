import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const genesis = `# Record Reader

## Purpose

Inspect a record only when the person provides its identifier.

## Powers

Use \`inspect-record\` for one identifier at a time.

## Boundaries

Never claim that the record was changed or deleted.

## Response

Explain the returned status in plain language.`;

export const load: PageServerLoad = async () => ({
  genesis: await highlightCode(genesis, "markdown"),
});
