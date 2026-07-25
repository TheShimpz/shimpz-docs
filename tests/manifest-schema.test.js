import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const schema = JSON.parse(
  await readFile(new URL("../static/specs/assistant/manifest.schema.json", import.meta.url), "utf8"),
);

test("published shimpz.toml schema is the closed Spec v1 contract", () => {
  assert.equal(schema.$schema, "https://json-schema.org/draft/2020-12/schema");
  assert.equal(schema.$id, "https://schemas.shimpz.com/assistant/v1/manifest.schema.json");
  assert.equal(schema.title, "Shimpz Assistant manifest v1");
  assert.equal(schema.type, "object");
  assert.equal(schema.additionalProperties, false);
  assert.deepEqual(schema.required, [
    "spec",
    "version",
    "name",
    "summary",
    "creators",
    "github",
    "allowed_hosts",
    "genesis",
  ]);
  assert.equal(schema.properties.spec.const, 1);
});

test("published shimpz.toml schema exposes only authored Spec v1 fields", () => {
  assert.deepEqual(Object.keys(schema.properties).sort(), [
    "accounts",
    "allowed_hosts",
    "creators",
    "genesis",
    "github",
    "name",
    "spec",
    "summary",
    "version",
  ]);
  assert.equal(schema.properties.accounts.propertyNames.$ref, "#/$defs/identifier");
  assert.deepEqual(schema.$defs.account.required, ["scopes"]);
  assert.equal(schema.$defs.account.additionalProperties, false);
  assert.equal("provider" in schema.$defs.account.properties, false);
});
