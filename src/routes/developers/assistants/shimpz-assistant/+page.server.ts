import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const response = `{
  "observed_at": "2026-07-18T09:00",
  "temperature_c": 21.4,
  "apparent_temperature_c": 21.1,
  "wind_speed_kmh": 8.6,
  "weather_code": 1,
  "timezone": "Europe/Lisbon"
}`;

export const load: PageServerLoad = async () => ({
  response: await highlightCode(response, "json"),
});
