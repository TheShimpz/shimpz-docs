import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const manifestPage = await readFile(
  new URL("../src/routes/developers/assistants/spec/manifest/+page.server.ts", import.meta.url),
  "utf8",
);
const manifestGuide = await readFile(
  new URL("../src/routes/developers/assistants/spec/manifest/+page.svelte", import.meta.url),
  "utf8",
);
const schema = JSON.parse(
  await readFile(new URL("../static/specs/assistant/manifest.schema.json", import.meta.url), "utf8"),
);
const upstream = JSON.parse(
  await readFile(new URL("../static/specs/assistant/upstream.json", import.meta.url), "utf8"),
);
/** @param {string} source */
function extractManifest(source) {
  const match = source.match(/const manifest = `([\s\S]*?)`;/);
  assert.ok(match, "the page exports a manifest example");
  return match[1];
}

/** @param {string} manifest */
function scanTables(manifest) {
  const withoutMultilineStrings = manifest.replace(/("""|''')[\s\S]*?\1/g, '""');
  const tables = new Map([["", { keys: new Set(), source: "" }]]);
  let current = "";
  for (const line of withoutMultilineStrings.split("\n")) {
    const header = line.match(/^[ \t]*\[([A-Za-z0-9_.-]+)\][ \t]*$/);
    if (header) {
      current = header[1];
      if (!tables.has(current)) tables.set(current, { keys: new Set(), source: "" });
      continue;
    }
    const table = tables.get(current);
    assert.ok(table);
    table.source += `${line}\n`;
    const assignment = line.match(
      /^[ \t]*(?:"([^"]+)"|'([^']+)'|([A-Za-z0-9_-]+))(?:[ \t]*\.[ \t]*(?:"[^"]+"|'[^']+'|[A-Za-z0-9_-]+))*[ \t]*=/,
    );
    if (assignment) table.keys.add(assignment[1] ?? assignment[2] ?? assignment[3]);
  }
  return tables;
}

/** @param {Set<string>} keys @param {object} properties */
function assertKnownKeys(keys, properties) {
  for (const key of keys) {
    assert.ok(Object.hasOwn(properties, key), `manifest example does not declare unknown ${key}`);
  }
}

/** @param {string} source */
function assertManifestExample(source) {
  const manifest = extractManifest(source);
  const tables = scanTables(manifest);
  const root = tables.get("");
  assert.ok(root);
  assert.deepEqual([...root.keys], [], "manifest example has no root-level fields");
  for (const table of schema.required) {
    assert.ok(tables.has(table), `manifest example includes required [${table}]`);
  }
  for (const table of tables.keys()) {
    const root = table.split(".", 1)[0];
    if (root) assert.ok(Object.hasOwn(schema.properties, root), `manifest example declares unknown [${table}]`);
  }
  const metadata = tables.get("shimpz");
  const network = tables.get("network");
  assert.ok(metadata && network);
  for (const key of schema.$defs.shimpz.required) assert.ok(metadata.keys.has(key), `[shimpz] includes ${key}`);
  for (const key of schema.$defs.network.required) assert.ok(network.keys.has(key), `[network] includes ${key}`);
  assertKnownKeys(metadata.keys, schema.$defs.shimpz.properties);
  assertKnownKeys(network.keys, schema.$defs.network.properties);

  const id = metadata.source.match(/^id = "([^"]+)"$/m)?.[1];
  assert.ok(id, "manifest example declares a string id");
  assert.match(id, new RegExp(schema.$defs.assistantIdentifier.pattern));
  assert.ok(
    id.length >= schema.$defs.assistantIdentifier.minLength &&
      id.length <= schema.$defs.assistantIdentifier.maxLength,
    "manifest example id respects the schema length bounds",
  );
  assert.ok(!schema.$defs.assistantIdentifier.not.enum.includes(id), "manifest example id is not reserved");
}

test("static manifest table scan ignores multiline values without losing section ownership", () => {
  for (const delimiter of ['"""', "'''"]) {
    const oppositeDelimiter = delimiter === '"""' ? "'''" : '"""';
    const manifest = `[shimpz]
spec = 1
genesis = ${delimiter}
Reply with ${oppositeDelimiter}
[integrations.fake]
id = "postgres"
body_key = "not top level"
${delimiter}
id = "example"
unknown_key = true
Extra-Key = true
"quoted-extra" = true
  indented = true
toString = true
telemetry.enabled = true

[network]
allowed_hosts = []

[integrations.example]
scopes = ["read"]`;
    const tables = scanTables(manifest);
    const metadata = tables.get("shimpz");
    const network = tables.get("network");
    assert.ok(metadata && network);
    assert.deepEqual([...metadata.keys], [
      "spec",
      "genesis",
      "id",
      "unknown_key",
      "Extra-Key",
      "quoted-extra",
      "indented",
      "toString",
      "telemetry",
    ]);
    assert.equal(metadata.source.match(/^id = "([^"]+)"$/m)?.[1], "example");
    assert.deepEqual([...network.keys], ["allowed_hosts"]);
    assert.throws(
      () => assertKnownKeys(new Set(["toString"]), schema.$defs.shimpz.properties),
      /manifest example does not declare unknown toString/,
    );
  }
});

test("static published shimpz.toml schema is the closed Spec v1 contract", () => {
  assert.equal(schema.$schema, "https://json-schema.org/draft/2020-12/schema");
  assert.equal(schema.$id, "https://schemas.shimpz.com/assistant/v1/manifest.schema.json");
  assert.equal(schema.title, "Shimpz Assistant manifest v1");
  assert.equal(schema.type, "object");
  assert.equal(schema.additionalProperties, false);
  assert.deepEqual(schema.required, ["shimpz", "network"]);
  assert.equal(schema.$defs.shimpz.properties.spec.const, 1);
});

test("static manifest schema projection pins Developers authority", () => {
  assert.deepEqual(upstream, {
    repository: "https://github.com/TheShimpz/shimpz-developers",
    commit: "6ea04da64f75abd652e0f2c6142b2f14141b04d7",
    path: "protocol/assistant/v1/manifest.schema.json",
    sha256: "31c0715e8cf6d21deea708bc6bae341eccbff2ee413a14ffb22df9d7e2678afb",
  });
});

test("static published manifest examples contain both required tables and a valid id", () => {
  assertManifestExample(manifestPage);
  assert.match(manifestGuide, />Two required tables/);
  assert.match(manifestGuide, /<dt><code>\[shimpz\]<\/code><\/dt>/);
  assert.match(manifestGuide, /<dt><code>\[network\]<\/code><\/dt>/);
  for (const key of schema.$defs.shimpz.required) {
    assert.match(manifestGuide, new RegExp(`<dt><code>${key}</code></dt>`));
  }
  for (const key of schema.$defs.network.required) {
    assert.match(manifestGuide, new RegExp(`<dt><code>${key}</code></dt>`));
  }
  const idDescription = manifestGuide.match(
    /<dt><code>id<\/code><\/dt>\s*<dd>([\s\S]*?)<\/dd>/,
  )?.[1];
  assert.ok(idDescription, "the guide documents the Assistant id");
  assert.match(
    idDescription,
    new RegExp(
      `${schema.$defs.assistantIdentifier.minLength} to ${schema.$defs.assistantIdentifier.maxLength} characters`,
    ),
  );
  for (const reserved of schema.$defs.assistantIdentifier.not.enum) {
    assert.match(idDescription, new RegExp(`<code>${reserved}</code>`));
  }
});

test("static documented Cloudflare manifest keeps one coherent current tuple", () => {
  const manifest = extractManifest(manifestPage);
  const version = manifest.match(/^version = "([^"]+)"$/m)?.[1];
  const scopes = manifest
    .match(/^scopes = \[([^\]]+)\]$/m)?.[1]
    .split(",")
    .map((scope) => scope.trim().replaceAll('"', ""));
  assert.equal(version, "0.4.4");
  assert.deepEqual(scopes, ["zone.read", "dns.read", "dns.write", "offline_access"]);
});

test("static published shimpz.toml schema exposes only authored Spec v1 fields", () => {
  assert.deepEqual(Object.keys(schema.properties).sort(), ["integrations", "network", "shimpz"]);
  assert.deepEqual(schema.properties.shimpz, { $ref: "#/$defs/shimpz" });
  assert.deepEqual(schema.properties.network, { $ref: "#/$defs/network" });
  assert.deepEqual(schema.$defs.shimpz.properties.id, { $ref: "#/$defs/assistantIdentifier" });
  assert.deepEqual(schema.$defs.network.required, ["allowed_hosts"]);
  assert.equal(schema.$defs.network.additionalProperties, false);
  assert.equal(schema.$defs.assistantIdentifier.maxLength, 40);
  assert.deepEqual(schema.$defs.assistantIdentifier.not.enum, [
    "postgres",
    "assistant-egress",
    "shimpz-assistant-egress",
  ]);
  assert.equal(schema.properties.integrations.propertyNames.$ref, "#/$defs/identifier");
  assert.deepEqual(schema.$defs.integration.required, ["scopes"]);
  assert.equal(schema.$defs.integration.additionalProperties, false);
  assert.equal("provider" in schema.$defs.integration.properties, false);
});
