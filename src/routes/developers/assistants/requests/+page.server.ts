import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const action = `from typing import TypedDict

from shimpz import Context, InputOption, InputRequest, action


class CreatedRecord(TypedDict):
    id: str
    status: str


@action(
    human_requests=["input:choice", "auth:password"],
)
async def run(zone: str, *, ctx: Context) -> CreatedRecord:
    mode = ctx.request_input(
        InputRequest(
            kind="choice",
            title="Choose the DNS mode",
            description="Select how this record should answer traffic.",
            label="Mode",
            options=(
                InputOption("proxied", "Proxied"),
                InputOption("dns-only", "DNS only"),
            ),
        )
    )
    ctx.request_auth(
        "password",
        title="Confirm this DNS change",
        description="Re-enter your platform credential to authorize this action.",
    )
    return await create_record(zone, mode)
`;

export const load: PageServerLoad = async () => ({
  action: await highlightCode(action, "python"),
});
