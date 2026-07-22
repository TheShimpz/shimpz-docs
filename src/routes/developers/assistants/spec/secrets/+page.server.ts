import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const declaration = `[secrets.records-api-key]
name = "Records API key"
summary = "Read-only key used to inspect records."`;

const reference = `[powers.inspect-record]
summary = "Inspect one record."
approval = "never"
secrets = ["records-api-key"]`;

export const load: PageServerLoad = async () => {
  const [secret, power] = await Promise.all([
    highlightCode(declaration, "toml"),
    highlightCode(reference, "toml"),
  ]);
  return { secret, power };
};
