import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const projectFiles = `my-assistant/
├── shimpz.toml
├── powers/
│   ├── create_dns.py
│   ├── delete_dns.py
│   └── list_dns.py
├── lib/
│   └── cloudflare.py
└── pyproject.toml`;

const power = `from typing import TypedDict

from shimpz import power


class EchoResult(TypedDict):
    message: str


@power()
async def run(message: str) -> EchoResult:
    return {"message": message}`;

export const load: PageServerLoad = async () => ({
  projectFiles: await highlightCode(projectFiles, "text"),
  power: await highlightCode(power, "python"),
});
