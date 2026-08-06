import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const power = `from shimpz import Context, InputOption, InputRequest, power


@power(
    human_requests=["input:choice", "approval", "auth:reauth"],
)
async def run(zone: str, *, ctx: Context) -> dict[str, str]:
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
    ctx.request_approval(
        title="Create the DNS record",
        description=f"Create {zone} in {mode} mode.",
    )
    ctx.request_auth(
        "reauth",
        title="Confirm this DNS change",
        description="Re-enter your platform credential to authorize this action.",
    )
    return await create_record(zone, mode)
`;

export const load: PageServerLoad = async () => ({
  power: await highlightCode(power, "python"),
});
