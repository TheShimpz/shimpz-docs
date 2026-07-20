import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const power = `[powers.list-direct-uploads]
summary = "List recent Mux direct uploads."
approval = "never"
secrets = ["mux-token-id", "mux-token-secret"]

[powers.create-test-direct-upload]
summary = "Create a short-lived Mux test upload intent without uploading media."
approval = "always"
secrets = ["mux-token-id", "mux-token-secret"]

[powers.identity-me]
summary = "Read the connected X account."
approval = "never"
accounts = ["x"]`;

const inputSchema = `{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "limit": { "type": "integer", "minimum": 1, "maximum": 25 }
  },
  "required": ["limit"],
  "additionalProperties": false
}`;

export const load: PageServerLoad = async () => ({
  power: await highlightCode(power, "toml"),
  inputSchema: await highlightCode(inputSchema, "json"),
});
