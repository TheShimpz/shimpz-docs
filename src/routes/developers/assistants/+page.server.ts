import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const projectFiles = `my-assistant/
├── icon.png
├── shimpz.toml
├── actions/
│   ├── create_dns.py
│   ├── delete_dns.py
│   └── list_dns.py
├── lib/
│   └── cloudflare.py
└── pyproject.toml`;

const action = `from typing import TypedDict

from shimpz import action


class EchoResult(TypedDict):
    message: str


@action()
async def run(message: str) -> EchoResult:
    return {"message": message}`;

export const load: PageServerLoad = async () => ({
  projectFiles: await highlightCode(projectFiles, "text"),
  action: await highlightCode(action, "python"),
});
