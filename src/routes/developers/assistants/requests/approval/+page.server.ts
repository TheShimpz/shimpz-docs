import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const approval = `from shimpz import Context, power


@power(human_requests=["approval"])
async def run(zone: str, *, ctx: Context) -> dict[str, str]:
    ctx.request_approval(
        title="Publish the reviewed DNS change",
        description=f"Create the approved records in {zone}.",
    )

    # The externally visible action happens only after approval.
    return await publish_dns_change(zone)
`;

export const load: PageServerLoad = async () => ({
  approval: await highlightCode(approval, "python"),
});
