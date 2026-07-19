import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `schema_version = 2
name = "Shimpz Assistant"
summary = "Find places and inspect current or forecast weather through Open-Meteo."
creators = ["@roxygens"]
github = "https://github.com/roxygens/shimpz-assistant"
allowed_hosts = [
  "api.open-meteo.com",
  "geocoding-api.open-meteo.com",
]

[powers.search-location]
summary = "Find geographic coordinates for a city or postal code."

[powers.current-weather]
summary = "Read the current weather for one coordinate."
approval = "never"

[powers.daily-forecast]
summary = "Read a daily weather forecast for one coordinate."
approval = "never"`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
});
