import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const workflow = `my-assistant/
├── icon.png
├── shimpz.toml
├── pyproject.toml
└── actions/

shimpz assistant check`;

export const load: PageServerLoad = async () => ({
  workflow: await highlightCode(workflow, "text"),
});
