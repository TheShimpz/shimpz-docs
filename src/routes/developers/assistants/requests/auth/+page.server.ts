import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const password = `ctx.request_auth(
    "password",
    title=text("Confirm the DNS change"),
    description=text("Re-enter your Supervisor password before publishing this change."),
)

return await publish_dns_change(change)`;

export const load: PageServerLoad = async () => ({
  password: await highlightCode(password, "python"),
});
