import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const declaration = `[accounts.records]
provider = "registered-provider"
scopes = ["records.read"]`;

const reference = `[powers.inspect-record]
summary = "Inspect one private record."
approval = "never"
accounts = ["records"]`;

export const load: PageServerLoad = async () => {
  const [account, power] = await Promise.all([
    highlightCode(declaration, "toml"),
    highlightCode(reference, "toml"),
  ]);
  return { account, power };
};
