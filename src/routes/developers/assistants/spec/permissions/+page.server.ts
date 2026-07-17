import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const emptyPermissions = `[permissions]
egress = []
services = []
assistants = []`;

const permissionRequests = `[permissions]
egress = []

[[permissions.services]]
id = "meta-ads"
interface = "shimpz.meta-ads/v1"
operations = ["meta-ads.read"]
credential_refs = ["customer-ad-account"]

[[permissions.assistants]]
id = "copy-editor"
interface = "shimpz.copy-editor/v1"
powers = ["review-copy"]`;

export const load: PageServerLoad = async () => ({
  emptyPermissions: await highlightCode(emptyPermissions, "toml"),
  permissionRequests: await highlightCode(permissionRequests, "toml"),
});
