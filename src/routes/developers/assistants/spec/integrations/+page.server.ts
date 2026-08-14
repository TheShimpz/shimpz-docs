import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `[integrations.cloudflare]
scopes = ["zone.read", "dns.read", "dns.write", "offline_access"]`;

const action = `from typing import TypedDict

from shimpz import Context, action


class ZoneResult(TypedDict):
    zone_id: str
    status: str


@action(integrations=["cloudflare"])
async def run(domain: str, *, ctx: Context) -> ZoneResult:
    access_token = ctx.integrations.cloudflare.access_token
    response = await fetch_zone(domain, access_token)
    return {"zone_id": response["id"], "status": response["status"]}`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
  action: await highlightCode(action, "python"),
});
