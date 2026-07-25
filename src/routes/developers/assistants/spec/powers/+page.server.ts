import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const power = `from typing import TypedDict

from shimpz import Context, power


class ZoneResult(TypedDict):
    zone_id: str
    status: str


@power(accounts=["cloudflare"])
async def run(domain: str, *, ctx: Context = None) -> ZoneResult:
    token = ctx.accounts.cloudflare.access_token
    result = await fetch_zone(domain, token)
    return {"zone_id": result["id"], "status": result["status"]}`;

const contract = `{
  "id": "inspect-zone",
  "method": "POST",
  "path": "/v1/powers/inspect-zone",
  "accounts": ["cloudflare"],
  "input_schema": {
    "type": "object",
    "properties": {"domain": {"type": "string"}},
    "required": ["domain"],
    "additionalProperties": false
  },
  "output_schema": {
    "type": "object",
    "properties": {
      "zone_id": {"type": "string"},
      "status": {"type": "string"}
    },
    "required": ["zone_id", "status"],
    "additionalProperties": false
  }
}`;

export const load: PageServerLoad = async () => ({
  power: await highlightCode(power, "python"),
  contract: await highlightCode(contract, "json"),
});
