import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const copy = `from typing import Annotated, TypedDict

from shimpz import Context, action, domain, identifier, integer, text

Zone = Annotated[str, "Zone to publish.", {"maxLength": 60, "pattern": "^[a-z0-9.-]+$"}]


class PublishedChanges(TypedDict):
    change_id: str


@action(human_requests=["approval"])
async def run(zone: Zone, change_id: str, count: int, *, ctx: Context) -> PublishedChanges:
    ctx.request_approval(
        title=text("Publish the reviewed DNS changes"),
        description=text(
            "DNS changes to publish: {count}. Zone: {zone}. Change: {change}.",
            count=integer(count, digits=4),
            zone=domain(zone, max_length=60),
            change=identifier(change_id, max_length=40),
        ),
    )
    return await publish_changes(zone, change_id)
`;

const reused = `# Outside a request argument, a message names the smallest field it must fit.
if proxied:
    mode = text("Serve {zone} through the proxy.", zone=domain(zone, max_length=60), max_length=500)
else:
    mode = text("Serve {zone} as DNS only.", zone=domain(zone, max_length=60), max_length=500)

ctx.request_approval(title=text("Change the DNS mode"), description=mode)`;

const refused = `title = text(f"Delete {name}")             # f-string
title = text("Delete " + name)             # computed template
title = text(TEMPLATE)                     # template is not a literal in the call
say = text                                 # alias or reference
title = text("Delete {name}", **params)    # **params
title = text("Delete {name}", name=identifier(name, max_length=limit))  # non-literal maximum
name = identifier(record, max_length=40)   # helper outside a text() argument
from shimpz import *                       # wildcard import`;

export const load: PageServerLoad = async () => ({
  copy: await highlightCode(copy, "python"),
  reused: await highlightCode(reused, "python"),
  refused: await highlightCode(refused, "python"),
});
