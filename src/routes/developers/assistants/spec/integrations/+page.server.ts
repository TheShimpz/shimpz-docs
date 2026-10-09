import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `[integrations.cloudflare]
scopes = ["zone.read", "dns.read", "dns.write", "offline_access"]`;

const action = `from typing import TypedDict

from shimpz import Context, action


class ZoneResult(TypedDict):
    zone_id: str
    status: str


@action(
    integrations=["cloudflare"],
    description="Show whether one of your domains is active on Cloudflare.",
)
async def run(domain: str, *, ctx: Context) -> ZoneResult:
    response = await ctx.fetch(
        "GET",
        f"https://api.cloudflare.com/client/v4/zones?name={domain}",
        headers={"Accept": "application/json"},
    )
    zone = response.json()["result"][0]
    return {"zone_id": zone["id"], "status": zone["status"]}`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
  action: await highlightCode(action, "python"),
});
