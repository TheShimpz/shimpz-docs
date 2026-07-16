import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const response = `{
  "message": "Hello, Ada!"
}`;

export const load: PageServerLoad = async () => ({
  response: await highlightCode(response, "json"),
});
