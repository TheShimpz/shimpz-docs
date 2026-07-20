import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const declaration = `[secrets.x-bearer-token]
name = "X Bearer Token"
summary = "App-only token used exclusively for public X profile reads."

[powers.public-user-lookup]
summary = "Read one public X profile by username."
approval = "never"
secrets = ["x-bearer-token"]`;

const envelope = `{
  "input": { "username": "TheShimpz" },
  "secrets": {
    "x-bearer-token": "<resolved in memory>"
  }
}`;

export const load: PageServerLoad = async () => ({
  declaration: await highlightCode(declaration, "toml"),
  envelope: await highlightCode(envelope, "json"),
});
