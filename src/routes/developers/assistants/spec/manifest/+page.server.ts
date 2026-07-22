import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const minimalManifest = `schema_version = 2
name = "Hello Summary"
summary = "Return one schema-validated summary."
creators = ["@your-github-user"]
allowed_hosts = []

[powers.summarize]
summary = "Summarize one supplied text."
approval = "never"`;

const integrationManifest = `schema_version = 2
name = "Shimpz Cloudflare"
summary = "List Cloudflare zones and inspect their DNS records through OAuth."
creators = ["@roxygens"]
github = "https://github.com/TheShimpz/shimpz-cloudflare"
allowed_hosts = ["api.cloudflare.com"]

[accounts.cloudflare]
provider = "cloudflare"
scopes = ["zone.read", "dns.read", "offline_access"]

[powers.list-zones]
summary = "List a bounded page of Cloudflare zones and domains."
approval = "never"
accounts = ["cloudflare"]

[powers.list-dns-records]
summary = "List a bounded page of DNS records from one Cloudflare zone."
approval = "never"
accounts = ["cloudflare"]`;

export const load: PageServerLoad = async () => ({
  minimalManifest: await highlightCode(minimalManifest, "toml"),
  integrationManifest: await highlightCode(integrationManifest, "toml"),
});
