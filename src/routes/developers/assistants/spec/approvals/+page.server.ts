import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const approval = `@power(accounts=["cloudflare"])
async def create_dns(
    domain=field(str, prompt="The domain to update."),
    ctx=None,
):
    ip = await ctx.human.request(
        str,
        title="IP address",
        summary="Enter the IP address for the DNS record.",
    )
    approved = await ctx.human.approval(
        title="Create DNS record",
        summary=f"Point {domain} to {ip}?",
        runs="always",
    )
    if not approved:
        return {"created": False}

    return await create_record(domain, ip, ctx.accounts.cloudflare.access_token)`;

export const load: PageServerLoad = async () => ({
  approval: await highlightCode(approval, "python"),
});
