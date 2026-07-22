import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const declaration = `[secrets.media-token-id]
name = "Media API Token ID"
summary = "Identifies this Team to the media API."

[secrets.media-token-secret]
name = "Media API Token Secret"
summary = "Authenticates this Team to the media API."

[secrets.media-webhook-signing-secret]
name = "Media Webhook Signing Secret"
summary = "Verifies that a webhook payload was signed by the provider."

[powers.list-media-assets]
summary = "List recent media assets."
approval = "never"
secrets = ["media-token-id", "media-token-secret"]

[powers.verify-media-webhook]
summary = "Verify one media webhook signature locally."
approval = "never"
secrets = ["media-webhook-signing-secret"]`;

const envelope = `{
  "input": { "limit": 10 },
  "secrets": {
    "media-token-id": "<resolved in memory>",
    "media-token-secret": "<resolved in memory>"
  },
  "accounts": {}
}`;

export const load: PageServerLoad = async () => ({
  declaration: await highlightCode(declaration, "toml"),
  envelope: await highlightCode(envelope, "json"),
});
