import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const response = `{
  "id": "123456789",
  "name": "Shimpz Example",
  "username": "TheShimpz"
}`;

export const load: PageServerLoad = async () => ({
  response: await highlightCode(response, "json"),
});
