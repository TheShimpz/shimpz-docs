import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async () => {
  const [none, oneHost] = await Promise.all([
    highlightCode("allowed_hosts = []", "toml"),
    highlightCode('allowed_hosts = ["api.open-meteo.com"]', "toml"),
  ]);
  return { none, oneHost };
};
