import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `[shimpz]
spec = 1
id = "shimpz-cloudflare"
version = "0.5.2"
name = "Cloudflare"
summary = "Set up your domains' DNS without opening a dashboard or memorizing records."
description = "Look up your Cloudflare domains and their DNS records, and create, replace, or delete A, AAAA, CNAME, and TXT records without opening the Cloudflare dashboard. Every change waits for your password before anything reaches Cloudflare."
creators = ["@shimpz"]
github = "https://github.com/TheShimpz/shimpz-cloudflare"
genesis = """
Use this Assistant to inspect Cloudflare zones and to manage reviewed A, AAAA, CNAME, and TXT DNS records.

Call list-zones to discover available zones and get-zone for exact zone details. Call DNS-record Actions only with
a zone_id returned by list-zones, and get-dns-record only with a record_id returned by list-dns-records. Start with
page 1 and a small per_page. Use ensure-dns-record to converge on one exact state, replace-dns-record for a complete
replacement, and delete-dns-record for one exact record. Every mutation must complete its declared auth:password
authorization before observing an access token or contacting Cloudflare. Never claim success beyond the returned
provider result, silently retry an uncertain write, mutate a zone, or ask the user to paste OAuth credentials.
"""

[shimpz.links]
site = "https://shimpz.com/"
github = "https://github.com/TheShimpz"

[network]
allowed_hosts = ["api.cloudflare.com"]

[integrations.cloudflare]
scopes = ["zone.read", "dns.read", "dns.write", "offline_access"]`;

const routes = `[stored_inputs.exa-api-key]
kind = "password"
label = "Exa API key"
description = "Lets this Assistant search the web. Create it in the Exa dashboard."
help_url = "https://dashboard.exa.ai/api-keys"
host = "api.exa.ai"
header = "x-api-key"
routes = [{ method = "POST", path = "/search" }, { method = "POST", path = "/contents" }]`;

export const load: PageServerLoad = async () => {
  const [highlightedManifest, highlightedRoutes] = await Promise.all([
    highlightCode(manifest, "toml"),
    highlightCode(routes, "toml"),
  ]);
  return { manifest: highlightedManifest, routes: highlightedRoutes };
};
