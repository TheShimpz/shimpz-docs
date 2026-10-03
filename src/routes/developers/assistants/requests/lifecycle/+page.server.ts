import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const safeOrder = `from typing import TypedDict

from shimpz import Context, InputOption, InputRequest, action, text


class PublishedRecord(TypedDict):
    id: str
    status: str


@action(
    integrations=["cloudflare"],
    human_requests=["input:choice", "auth:password"],
)
async def run(zone: str, *, ctx: Context) -> PublishedRecord:
    # Replay-safe prefix: pure decisions only.
    mode = ctx.request_input(
        InputRequest(
            kind="choice",
            title=text("Choose the DNS mode"),
            description=text("Select exactly one routing behavior."),
            label=text("Mode"),
            options=(
                InputOption("proxied", text("Proxied")),
                InputOption("dns-only", text("DNS only")),
            ),
        )
    )
    ctx.request_auth(
        "password",
        title=text("Confirm the DNS publication"),
        description=text("Reauthenticate before this external write."),
    )

    # Secret/action phase: no more human requests are allowed.
    token = ctx.integrations.cloudflare.access_token
    return await publish_record(zone, mode, token)
`;

export const load: PageServerLoad = async () => ({
  safeOrder: await highlightCode(safeOrder, "python"),
});
