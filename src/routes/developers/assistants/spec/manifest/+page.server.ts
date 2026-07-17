import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `schema_version = 2
id = "hello-pulse"
name = "Hello Pulse"
version = "0.1.0"
description = "Return a friendly greeting."
rules = "assistant/RULES.md"

[artifact]
mode = "development"
source = "."
port = 8080
health_path = "/health"
architectures = ["linux/amd64", "linux/arm64"]

[[powers]]
id = "hello"
summary = "Return a friendly greeting."
input_schema = "schemas/hello.input.schema.json"
output_schema = "schemas/hello.output.schema.json"
approval = "none"

[permissions]
egress = []
services = []
assistants = []`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
});
