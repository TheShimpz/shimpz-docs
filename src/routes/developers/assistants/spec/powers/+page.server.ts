import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const power = `[powers.list-zones]
summary = "List a bounded page of Cloudflare zones and domains."
approval = "never"
accounts = ["cloudflare"]

[powers.list-dns-records]
summary = "List a bounded page of DNS records from one Cloudflare zone."
approval = "never"
accounts = ["cloudflare"]`;

const inputSchema = `{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "page": { "type": "integer", "minimum": 1, "maximum": 100000 },
    "per_page": { "type": "integer", "minimum": 1, "maximum": 100 }
  },
  "required": ["page", "per_page"],
  "additionalProperties": false
}`;

export const load: PageServerLoad = async () => ({
  power: await highlightCode(power, "toml"),
  inputSchema: await highlightCode(inputSchema, "json"),
});
