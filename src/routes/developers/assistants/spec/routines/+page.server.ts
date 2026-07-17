import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const routine = `[[routines]]
id = "pulse"
power = "hello"
interval_seconds = 300
timeout_seconds = 10
jitter_seconds = 15
enabled_by_default = false
single_flight = true
idempotency_key = "{assistant_id}:{routine_id}:{scheduled_at}"`;

export const load: PageServerLoad = async () => ({
  routine: await highlightCode(routine, "toml"),
});
