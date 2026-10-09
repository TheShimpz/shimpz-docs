import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const approval = `from typing import TypedDict

from shimpz import Context, action, domain, text


class PublishedDns(TypedDict):
    id: str
    status: str


@action(
    human_requests=["approval"],
    description="Publish a reviewed DNS change to one of your zones.",
)
async def run(zone: str, *, ctx: Context) -> PublishedDns:
    ctx.request_approval(
        title=text("Publish the reviewed DNS change"),
        description=text("Create the approved records in {zone}.", zone=domain(zone, max_length=253)),
    )

    # The externally visible action happens only after approval.
    return await publish_dns_change(zone)
`;

export const load: PageServerLoad = async () => ({
  approval: await highlightCode(approval, "python"),
});
