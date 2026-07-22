import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const declaration = `[accounts.cloudflare]
provider = "cloudflare"
scopes = ["zone.read", "dns.read", "offline_access"]

[powers.list-zones]
summary = "List a bounded page of Cloudflare zones."
approval = "never"
accounts = ["cloudflare"]

[powers.list-dns-records]
summary = "List a bounded page of DNS records for one zone."
approval = "never"
accounts = ["cloudflare"]`;

const envelope = `{
  "input": { "text": "Hello from my Team." },
  "secrets": {},
  "accounts": {
    "cloudflare": {
      "type": "oauth2-bearer",
      "access_token": "<short-lived access token>"
    }
  }
}`;

export const load: PageServerLoad = async () => ({
  declaration: await highlightCode(declaration, "toml"),
  envelope: await highlightCode(envelope, "json"),
});
