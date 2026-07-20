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
name = "Media Publisher"
summary = "Inspect Mux uploads and publish approved X posts."
creators = ["@your-github-user"]
github = "https://github.com/your-github-user/media-publisher"
allowed_hosts = ["api.mux.com", "api.x.com"]

[secrets.mux-token-id]
name = "Mux Token ID"
summary = "Identifies this Team to the Mux API."

[secrets.mux-token-secret]
name = "Mux Token Secret"
summary = "Authenticates this Team to the Mux API."

[accounts.x]
provider = "x"
scopes = ["tweet.read", "users.read", "tweet.write", "offline.access"]

[powers.list-direct-uploads]
summary = "List recent Mux direct uploads."
approval = "never"
secrets = ["mux-token-id", "mux-token-secret"]

[powers.create-post]
summary = "Publish one approved X post."
approval = "always"
accounts = ["x"]`;

export const load: PageServerLoad = async () => ({
  minimalManifest: await highlightCode(minimalManifest, "toml"),
  integrationManifest: await highlightCode(integrationManifest, "toml"),
});
