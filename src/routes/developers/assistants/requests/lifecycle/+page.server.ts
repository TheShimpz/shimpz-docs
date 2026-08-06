import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const safeOrder = `from typing import TypedDict

from shimpz import Context, InputOption, InputRequest, power


class PublishedRecord(TypedDict):
    id: str
    status: str


@power(
    integrations=["cloudflare"],
    human_requests=["input:choice", "approval", "auth:reauth"],
)
async def run(zone: str, *, ctx: Context) -> PublishedRecord:
    # Replay-safe prefix: pure decisions only.
    mode = ctx.request_input(
        InputRequest(
            kind="choice",
            title="Choose the DNS mode",
            description="Select exactly one routing behavior.",
            label="Mode",
            options=(
                InputOption("proxied", "Proxied"),
                InputOption("dns-only", "DNS only"),
            ),
        )
    )
    ctx.request_approval(
        title="Publish the DNS record",
        description=f"Publish {zone} in {mode} mode.",
    )
    ctx.request_auth(
        "reauth",
        title="Confirm the DNS publication",
        description="Reauthenticate before this external write.",
    )

    # Secret/action phase: no more human requests are allowed.
    token = ctx.integrations.cloudflare.access_token
    return await publish_record(zone, mode, token)
`;

export const load: PageServerLoad = async () => ({
  safeOrder: await highlightCode(safeOrder, "python"),
});
