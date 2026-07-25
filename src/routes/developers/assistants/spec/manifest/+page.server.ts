import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `spec = 1
version = "0.1.0"
name = "Shimpz Cloudflare"
summary = "List Cloudflare zones and inspect their DNS records through OAuth."
creators = ["@roxygens"]
allowed_hosts = ["api.cloudflare.com"]
github = "https://github.com/TheShimpz/shimpz-cloudflare"
genesis = """
Use this Assistant only to inspect Cloudflare zones and DNS records.
Call list-zones before list-dns-records.
"""

[accounts.cloudflare]
scopes = ["zone.read", "dns.read", "offline_access"]`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
});
