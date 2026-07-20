import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const declaration = `[connections.x]
provider = "x"
scopes = ["tweet.read", "users.read", "tweet.write", "offline.access"]

[powers.identity-me]
summary = "Read the connected X account."
approval = "never"
connections = ["x"]

[powers.create-post]
summary = "Publish one post from the connected X account."
approval = "always"
connections = ["x"]`;

const envelope = `{
  "input": { "text": "Hello from my Team." },
  "secrets": {},
  "connections": {
    "x": {
      "type": "oauth2-bearer",
      "access_token": "<short-lived access token>"
    }
  }
}`;

export const load: PageServerLoad = async () => ({
  declaration: await highlightCode(declaration, "toml"),
  envelope: await highlightCode(envelope, "json"),
});
