import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const declaration = `[powers.inspect-record]
summary = "Inspect one record by its identifier."
approval = "never"`;

const inputSchema = `{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "additionalProperties": false,
  "required": ["record_id"],
  "properties": {
    "record_id": {
      "type": "string",
      "pattern": "^[a-z0-9-]{1,64}$"
    }
  }
}`;

const outputSchema = `{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "additionalProperties": false,
  "required": ["name", "status"],
  "properties": {
    "name": { "type": "string", "maxLength": 120 },
    "status": { "enum": ["active", "inactive"] }
  }
}`;

export const load: PageServerLoad = async () => {
  const [power, input, output] = await Promise.all([
    highlightCode(declaration, "toml"),
    highlightCode(inputSchema, "json"),
    highlightCode(outputSchema, "json"),
  ]);
  return { power, input, output };
};
