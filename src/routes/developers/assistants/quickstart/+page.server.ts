import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `[shimpz]
spec = 1
id = "echo-demo"
version = "0.1.0"
name = "Echo Assistant"
summary = "Returns a message unchanged."
creators = ["@your-handle"]
github = "https://github.com/your-handle/echo-assistant"
genesis = "Use echo when the user asks you to repeat a short message."

[network]
allowed_hosts = []`;

const project = `[project]
name = "echo-assistant"
version = "0.1.0"
requires-python = ">=3.14"
dependencies = ["shimpz==0.1.0"]`;

const action = `from typing import TypedDict

from shimpz import action


class EchoResult(TypedDict):
    message: str


@action()
async def run(message: str) -> EchoResult:
    return {"message": message}`;

const verify = `shimpz check
shimpz test echo --input '{"message":"hello"}'`;

const result = `{"message":"hello"}`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
  project: await highlightCode(project, "toml"),
  action: await highlightCode(action, "python"),
  verify: await highlightCode(verify, "bash"),
  result: await highlightCode(result, "json"),
});
