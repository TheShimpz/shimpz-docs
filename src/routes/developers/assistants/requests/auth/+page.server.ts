import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const password = `ctx.request_auth(
    "password",
    title="Confirm the DNS change",
    description="Re-enter your platform password before publishing this change.",
)

return await publish_dns_change(change)`;

const totp = `ctx.request_auth(
    "totp",
    title="Confirm the credential rotation",
    description="Use your configured second factor before rotating this credential.",
)

return await rotate_credential(credential_id)`;

const passkey = `ctx.request_auth(
    "passkey",
    title="Confirm the production release",
    description="Use a registered passkey before releasing to production.",
)

return await release_to_production(release_id)`;

export const load: PageServerLoad = async () => ({
  password: await highlightCode(password, "python"),
  totp: await highlightCode(totp, "python"),
  passkey: await highlightCode(passkey, "python"),
});
