import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const create = `shimpz assistant new hello-assistant
cd hello-assistant`;

const files = `hello-assistant/
├── .gitignore
├── README.md
├── actions/hello_world.py
├── icon.png
├── lib/hello.py
├── tests/test_hello.py
├── pyproject.toml
└── shimpz.toml`;

const verify = `shimpz assistant check
shimpz assistant run hello-world --input '{"name":"Ada"}'`;

const result = `{"message":"Hello, Ada!"}`;

export const load: PageServerLoad = async () => ({
  create: await highlightCode(create, "bash"),
  files: await highlightCode(files, "text"),
  verify: await highlightCode(verify, "bash"),
  result: await highlightCode(result, "json"),
});
