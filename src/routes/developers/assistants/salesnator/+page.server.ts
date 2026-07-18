import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const fixture = `{
  "assistant_id": "salesnator",
  "team_id": "demo-team",
  "run_id": "run-20260715t120000z",
  "scheduled_at": "2026-07-15T12:00:00Z",
  "campaign": { "status": "ACTIVE" },
  "adset": { "status": "ACTIVE" },
  "ad": { "status": "WITH_ISSUES" },
  "metrics": {
    "spend_cents": 12000,
    "leads": 0
  }
}`;

const verdict = `{
  "audit": {
    "assistant_id": "salesnator",
    "team_id": "demo-team",
    "run_id": "run-20260715t120000z",
    "power": "campaign-health",
    "result": "blocked"
  },
  "effective_status": "blocked",
  "cpl_cents": null,
  "recommendation": "review",
  "mutation_performed": false,
  "notification": {
    "idempotency_key": "salesnator:campaign-health:run-20260715t120000z",
    "enqueued": true
  }
}`;

export const load: PageServerLoad = async () => ({
  fixture: await highlightCode(fixture, "json"),
  verdict: await highlightCode(verdict, "json"),
});
