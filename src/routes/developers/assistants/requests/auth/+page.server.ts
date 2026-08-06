import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const reauth = `ctx.request_auth(
    "reauth",
    title="Confirm the DNS change",
    description="Re-enter your platform password before publishing this change.",
)

return await publish_dns_change(change)`;

const secondFactor = `ctx.request_auth(
    "second-factor",
    title="Confirm the credential rotation",
    description="Use your configured second factor before rotating this credential.",
)

return await rotate_credential(credential_id)`;

const phishingResistant = `ctx.request_auth(
    "phishing-resistant",
    title="Confirm the production release",
    description="Use a registered passkey before releasing to production.",
)

return await release_to_production(release_id)`;

export const load: PageServerLoad = async () => ({
  reauth: await highlightCode(reauth, "python"),
  secondFactor: await highlightCode(secondFactor, "python"),
  phishingResistant: await highlightCode(phishingResistant, "python"),
});
