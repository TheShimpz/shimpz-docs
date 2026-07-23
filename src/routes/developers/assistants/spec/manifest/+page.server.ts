import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `name = "Demo Assistant"
summary = "Demo assistant."
creators = ["@julianoamg"]
allowed_hosts = ["api.cloudflare.com"]
github = "https://github.com/TheShimpz/shimpz-demo-assistant"

[accounts.cloudflare]
scopes = ["zone.read", "dns.read", "offline_access"]`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
});
