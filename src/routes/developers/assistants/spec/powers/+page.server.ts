import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const power = `[powers.current-weather]
summary = "Read current weather for one coordinate pair."
approval = "never"
secrets = ["openweather-api-key"]

[powers.send-weather-alert]
summary = "Send one weather alert after explicit approval."
approval = "always"
secrets = ["alert-api-token"]`;

const inputSchema = `{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "latitude": { "type": "number", "minimum": -90, "maximum": 90 },
    "longitude": { "type": "number", "minimum": -180, "maximum": 180 }
  },
  "required": ["latitude", "longitude"],
  "additionalProperties": false
}`;

export const load: PageServerLoad = async () => ({
  power: await highlightCode(power, "toml"),
  inputSchema: await highlightCode(inputSchema, "json"),
});
