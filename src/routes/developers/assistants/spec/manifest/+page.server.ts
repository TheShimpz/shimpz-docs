import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `schema_version = 2
name = "Record Reader"
summary = "Inspect one record and return its public status."
creators = ["@octocat"]
github = "https://github.com/octocat/record-reader"
allowed_hosts = []

[powers.inspect-record]
summary = "Inspect one record by its identifier."
approval = "never"`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
});
