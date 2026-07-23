import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `[accounts.cloudflare]
scopes = ["zone.read", "dns.read", "offline_access"]`;

const power = `@power(accounts=["cloudflare"])
async def inspect_zone(
    domain=field(str, prompt="The domain to inspect."),
    ctx=None,
):
    access_token = ctx.accounts.cloudflare.access_token
    response = await fetch_zone(domain, access_token)
    return {"zone_id": response["id"], "status": response["status"]}`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
  power: await highlightCode(power, "python"),
});
