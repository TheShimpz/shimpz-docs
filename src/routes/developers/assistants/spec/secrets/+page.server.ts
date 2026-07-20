import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const declaration = `[secrets.mux-token-id]
name = "Mux Token ID"
summary = "Identifies this Team to the Mux API."

[secrets.mux-token-secret]
name = "Mux Token Secret"
summary = "Authenticates this Team to the Mux API."

[secrets.mux-webhook-signing-secret]
name = "Mux Webhook Signing Secret"
summary = "Verifies that a webhook payload was signed by Mux."

[powers.list-direct-uploads]
summary = "List recent Mux direct uploads."
approval = "never"
secrets = ["mux-token-id", "mux-token-secret"]

[powers.verify-mux-webhook]
summary = "Verify one Mux webhook signature locally."
approval = "never"
secrets = ["mux-webhook-signing-secret"]`;

const envelope = `{
  "input": { "limit": 10 },
  "secrets": {
    "mux-token-id": "<resolved in memory>",
    "mux-token-secret": "<resolved in memory>"
  },
  "accounts": {}
}`;

export const load: PageServerLoad = async () => ({
  declaration: await highlightCode(declaration, "toml"),
  envelope: await highlightCode(envelope, "json"),
});
