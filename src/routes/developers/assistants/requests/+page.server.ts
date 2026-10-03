import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const action = `from typing import TypedDict

from shimpz import Context, InputOption, InputRequest, action, text


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
            title=text("Choose the DNS mode"),
            description=text("Select how this record should answer traffic."),
            label=text("Mode"),
            options=(
                InputOption("proxied", text("Proxied")),
                InputOption("dns-only", text("DNS only")),
            ),
        )
    )
    ctx.request_auth(
        "password",
        title=text("Confirm this DNS change"),
        description=text("Re-enter your platform credential to authorize this action."),
    )
    return await create_record(zone, mode)
`;

export const load: PageServerLoad = async () => ({
  action: await highlightCode(action, "python"),
});
