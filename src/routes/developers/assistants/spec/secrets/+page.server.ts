import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const declaration = `[secrets.openweather-api-key]
name = "OpenWeather API key"
summary = "Authenticates current-weather requests for this Team."

[powers.current-weather]
summary = "Read current weather for one coordinate pair."
approval = "never"
secrets = ["openweather-api-key"]`;

const envelope = `{
  "input": { "latitude": -23.55, "longitude": -46.63 },
  "secrets": {
    "openweather-api-key": "<resolved in memory>"
  }
}`;

export const load: PageServerLoad = async () => ({
  declaration: await highlightCode(declaration, "toml"),
  envelope: await highlightCode(envelope, "json"),
});
