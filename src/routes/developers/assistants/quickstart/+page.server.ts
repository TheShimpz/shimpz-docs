import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const copy = `git clone https://github.com/TheShimpz/shimpz.git
cd shimpz
cp -R packages/python/shimpz/templates/starter \\
  packages/python/shimpz/templates/my-assistant
cd packages/python/shimpz/templates/my-assistant`;

const manifest = `name = "Echo Assistant"
summary = "Returns a message unchanged."
creators = ["@your-handle"]
allowed_hosts = []
github = "https://github.com/your-handle/echo-assistant"`;

const app = `from typing import TypedDict

from shimpz import field, power


class EchoResult(TypedDict):
    message: str


@power()
async def echo(
    message=field(str, prompt="The message to return."),
    ctx=None,
) -> EchoResult:
    return {"message": message}`;

const verify = `uv sync --frozen
uv run python test_app.py
uv run shimpz-assistant-contract
uv run python -m json.tool shimpz.contract.json`;

const container = `uv build ../.. --wheel --out-dir .build/sdk
docker build --tag echo-assistant:dev .
docker run --detach --rm --name echo-assistant \\
  --publish 127.0.0.1:8080:8080 echo-assistant:dev

curl --fail http://127.0.0.1:8080/healthz
printf '%s' \\
  '{"input":{"message":"hello"},"secrets":{},"accounts":{},"answers":[]}' \\
  | docker exec --interactive echo-assistant \\
      shimpz-assistant-rpc POST /v1/powers/echo

docker stop echo-assistant`;

const result = `{"result":{"message":"hello"}}`;

export const load: PageServerLoad = async () => ({
  copy: await highlightCode(copy, "bash"),
  manifest: await highlightCode(manifest, "toml"),
  app: await highlightCode(app, "python"),
  verify: await highlightCode(verify, "bash"),
  container: await highlightCode(container, "bash"),
  result: await highlightCode(result, "json"),
});
