import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const manifest = `schema_version = 1
id = "postgresql"
title = "PostgreSQL"
version = "3.0.0"
summary = "Managed PostgreSQL databases isolated per Capsule and App."
interface = "shimpz.postgresql/v1"
scope = "space"
credential_policy = "managed"
data_plane = "direct"
port = 7072
health_path = "/healthz"
metadata_path = "/v1/driver"
[capabilities]
operations = [
  "capsule.provision",
  "capsule.finalize",
  "capsule.drop",
  "capsule.app.create",
  "capsule.app.drop",
]`;

const credentialForm = `{
  "schema_version": 1,
  "owner_scope": "capsule",
  "cardinality": "many",
  "profiles": [
    {
      "id": "access-key",
      "kind": "secret-fields",
      "title": "Access key",
      "fields": [
        {
          "id": "account_id",
          "type": "text",
          "label": "Account ID",
          "required": true,
          "format": "account-id",
          "min_length": 1,
          "max_length": 128
        },
        {
          "id": "api_key",
          "type": "secret",
          "label": "API key",
          "required": true,
          "format": "api-key",
          "min_length": 16,
          "max_length": 4096,
          "write_only": true
        }
      ]
    }
  ]
}`;

export const load: PageServerLoad = async () => ({
  manifest: await highlightCode(manifest, "toml"),
  credentialForm: await highlightCode(credentialForm, "json"),
});
