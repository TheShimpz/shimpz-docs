import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const request = `from shimpz import choice, field, power


@power()
async def schedule_change(
    service=field(str, prompt="The service to change."),
    ctx=None,
):
    window = await ctx.human.request(
        choice("now", "next-maintenance-window"),
        title="Deployment window",
        summary=f"Choose when to update {service}.",
        docs="https://docs.example.com/deployments",
    )
    reason = await ctx.human.request(
        str,
        title="Change reason",
        summary="Explain why this change is needed.",
    )

    # External side effects begin only after every human interaction.
    return await deploy(service, window=window, reason=reason)`;

export const load: PageServerLoad = async () => ({
  request: await highlightCode(request, "python"),
});
