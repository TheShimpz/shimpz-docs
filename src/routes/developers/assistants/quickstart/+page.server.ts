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

const approval = `request: Send a greeting
request: Greet Ada with a Hello World message.
request: Approve this action? [y/N]
y`;

const result = `{"message":"Hello, Ada!"}`;

export const load: PageServerLoad = async () => ({
  create: await highlightCode(create, "bash"),
  files: await highlightCode(files, "text"),
  verify: await highlightCode(verify, "bash"),
  approval: await highlightCode(approval, "text"),
  result: await highlightCode(result, "json"),
});
