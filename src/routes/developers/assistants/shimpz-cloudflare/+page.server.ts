import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const response = `{
  "zones": [],
  "pagination": {
    "page": 1,
    "per_page": 25,
    "count": 0,
    "total_count": 0,
    "total_pages": 0
  }
}`;

export const load: PageServerLoad = async () => ({
  response: await highlightCode(response, "json"),
});
