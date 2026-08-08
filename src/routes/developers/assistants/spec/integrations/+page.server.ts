import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `[integrations.cloudflare]
scopes = ["zone.read", "dns.read", "dns.write", "offline_access"]`;

const power = `from shimpz import Context, power


@power(integrations=["cloudflare"])
async def run(domain: str, *, ctx: Context = None) -> dict[str, str]:
    access_token = ctx.integrations.cloudflare.access_token
    response = await fetch_zone(domain, access_token)
    return {"zone_id": response["id"], "status": response["status"]}`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
  power: await highlightCode(power, "python"),
});
