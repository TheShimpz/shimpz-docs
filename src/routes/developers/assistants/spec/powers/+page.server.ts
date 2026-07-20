import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const power = `[powers.public-user-lookup]
summary = "Read one public X profile by username."
approval = "never"
secrets = ["x-bearer-token"]

[powers.create-post]
summary = "Publish one Post from the connected X account after explicit approval."
approval = "always"
secrets = [
  "x-api-key",
  "x-api-key-secret",
  "x-access-token",
  "x-access-token-secret",
]`;

const inputSchema = `{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "username": { "type": "string", "pattern": "^[A-Za-z0-9_]{1,15}$" }
  },
  "required": ["username"],
  "additionalProperties": false
}`;

export const load: PageServerLoad = async () => ({
  power: await highlightCode(power, "toml"),
  inputSchema: await highlightCode(inputSchema, "json"),
});
