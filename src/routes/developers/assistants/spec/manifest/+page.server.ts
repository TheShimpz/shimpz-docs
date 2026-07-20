import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `schema_version = 2
name = "Weather Desk"
summary = "Read current weather and forecasts with one Team-owned API key."
creators = ["@your-github-user"]
github = "https://github.com/your-github-user/weather-desk"
allowed_hosts = ["api.openweathermap.org"]

[secrets.openweather-api-key]
name = "OpenWeather API key"
summary = "Authenticates weather requests for this Team."

[powers.current-weather]
summary = "Read current weather for one coordinate pair."
approval = "never"
secrets = ["openweather-api-key"]

[powers.daily-forecast]
summary = "Read a daily forecast for one coordinate pair."
approval = "never"
secrets = ["openweather-api-key"]`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
});
