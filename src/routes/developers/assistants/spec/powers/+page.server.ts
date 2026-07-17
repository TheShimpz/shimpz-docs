import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const power = `[[powers]]
id = "hello"
summary = "Return a friendly greeting."
input_schema = "schemas/hello.input.schema.json"
output_schema = "schemas/hello.output.schema.json"
approval = "none"`;

const inputSchema = `{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "hello.input.schema.json",
  "type": "object",
  "properties": {
    "name": { "type": "string", "minLength": 1, "maxLength": 80 }
  },
  "required": ["name"],
  "additionalProperties": false
}`;

export const load: PageServerLoad = async () => ({
  power: await highlightCode(power, "toml"),
  inputSchema: await highlightCode(inputSchema, "json"),
});
