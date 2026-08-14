import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `[shimpz]
spec = 1
id = "shimpz-cloudflare"
version = "0.4.4"
name = "Shimpz Cloudflare"
summary = "Inspect Cloudflare zones and safely manage common DNS records through OAuth."
creators = ["@shimpz"]
github = "https://github.com/TheShimpz/shimpz-cloudflare"
genesis = """
Inspect Cloudflare zones and manage reviewed A, AAAA, CNAME, and TXT DNS records.
Require password authorization before every mutation.
"""

[network]
allowed_hosts = ["api.cloudflare.com"]

[integrations.cloudflare]
scopes = ["zone.read", "dns.read", "dns.write", "offline_access"]`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
});
