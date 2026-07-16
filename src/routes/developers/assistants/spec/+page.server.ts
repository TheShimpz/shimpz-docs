import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `schema_version = 1
id = "hello-pulse"
title = "Hello Pulse"
version = "0.1.0"
summary = "A minimal Assistant with one safe operation and one owner-disabled routine."
skill = "assistant/SKILL.md"

[artifact]
mode = "development"
source = "."
port = 8080
health_path = "/health"
architectures = ["linux/amd64", "linux/arm64"]

[[operations]]
id = "hello"
summary = "Return a friendly greeting."
input_schema = "schemas/hello.input.schema.json"
output_schema = "schemas/hello.output.schema.json"
approval = "none"

[permissions]
egress = []
services = []
assistants = []

[[routines]]
id = "pulse"
operation = "hello"
interval_seconds = 300
timeout_seconds = 10
jitter_seconds = 15
enabled_by_default = false
single_flight = true
idempotency_key = "{assistant_id}:{routine_id}:{scheduled_at}"`;

const servicePermission = `[[permissions.services]]
id = "meta-ads"
interface = "shimpz.meta-ads/v1"
operations = ["meta-ads.read"]
credential_refs = ["primary-account"]`;

const inputSchema = `{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "hello.input.schema.json",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    }
  },
  "additionalProperties": false
}`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
  servicePermission: await highlightCode(servicePermission, "toml"),
  inputSchema: await highlightCode(inputSchema, "json"),
});
