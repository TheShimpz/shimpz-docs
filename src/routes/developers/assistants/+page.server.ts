import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const projectFiles = `demo-assistant/
├── shimpz.toml       # authored security intent
├── app.py            # authored Python behavior
├── pyproject.toml    # Python dependency lock input
├── uv.lock           # reproducible dependencies
├── Dockerfile        # immutable image recipe
├── GENESIS.md        # current Brain runtime document
├── help/
│   └── HELP-en.md    # current user help document
└── test_app.py       # creator-owned tests`;

const application = `from typing import TypedDict

from shimpz import field, power


class EchoResult(TypedDict):
    message: str


@power()
async def echo(
    message=field(str, prompt="The message to return."),
    ctx=None,
) -> EchoResult:
    return {"message": message}`;

export const load: PageServerLoad = async () => ({
  projectFiles: await highlightCode(projectFiles, "text"),
  application: await highlightCode(application, "python"),
});
