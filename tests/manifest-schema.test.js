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
const quickstartPage = await readFile(
  new URL("../src/routes/developers/assistants/quickstart/+page.server.ts", import.meta.url),
  "utf8",
);
const schema = JSON.parse(
  await readFile(new URL("../static/specs/assistant/manifest.schema.json", import.meta.url), "utf8"),
);
const countWords = ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"];

/** @param {string} source */
function extractManifest(source) {
  const match = source.match(/const manifest = `([\s\S]*?)`;/);
  assert.ok(match, "the page exports a manifest example");
  return match[1];
}

/** @param {string} manifest */
function scanTopLevel(manifest) {
  const withoutMultilineStrings = manifest.replace(/("""|''')[\s\S]*?\1/g, '""');
  const source = withoutMultilineStrings.split(/^\[/m, 1)[0];
  const keys = new Set(
    [
      ...source.matchAll(
        /^[ \t]*(?:"([^"]+)"|'([^']+)'|([A-Za-z0-9_-]+))(?:[ \t]*\.[ \t]*(?:"[^"]+"|'[^']+'|[A-Za-z0-9_-]+))*[ \t]*=/gm,
      ),
    ].map((match) => match[1] ?? match[2] ?? match[3]),
  );
  return { keys, source };
}

/** @param {Set<string>} keys */
function assertKnownKeys(keys) {
  for (const key of keys) {
    assert.ok(Object.hasOwn(schema.properties, key), `manifest example does not declare unknown ${key}`);
  }
}

/** @param {string} source */
function assertManifestExample(source) {
  const manifest = extractManifest(source);
  const { keys, source: topLevel } = scanTopLevel(manifest);
  for (const key of schema.required) {
    assert.ok(keys.has(key), `manifest example includes required ${key}`);
  }
  assertKnownKeys(keys);

  const id = topLevel.match(/^id = "([^"]+)"$/m)?.[1];
  assert.ok(id, "manifest example declares a string id");
  assert.match(id, new RegExp(schema.$defs.assistantIdentifier.pattern));
  assert.ok(
    id.length >= schema.$defs.assistantIdentifier.minLength &&
      id.length <= schema.$defs.assistantIdentifier.maxLength,
    "manifest example id respects the schema length bounds",
  );
  assert.ok(!schema.$defs.assistantIdentifier.not.enum.includes(id), "manifest example id is not reserved");
}

test("static manifest key scan ignores multiline values without hiding later keys", () => {
  for (const delimiter of ['"""', "'''"]) {
    const oppositeDelimiter = delimiter === '"""' ? "'''" : '"""';
    const manifest = `spec = 1
genesis = ${delimiter}
Reply with ${oppositeDelimiter}
[accounts.fake]
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

[accounts.example]
scopes = ["read"]`;
    const scanned = scanTopLevel(manifest);
    assert.deepEqual([...scanned.keys], [
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
    assert.equal(scanned.source.match(/^id = "([^"]+)"$/m)?.[1], "example");
    assert.throws(
      () => assertKnownKeys(new Set(["toString"])),
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
  assert.deepEqual(schema.required, [
    "spec",
    "id",
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

test("static published manifest examples contain every required top-level key and a valid id", () => {
  assertManifestExample(manifestPage);
  assertManifestExample(quickstartPage);
  const countWord = countWords[schema.required.length];
  assert.ok(countWord, "the guide supports the schema required-key count");
  assert.match(manifestGuide, new RegExp(`>${countWord} required keys`));
  for (const key of schema.required) {
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

test("static published shimpz.toml schema exposes only authored Spec v1 fields", () => {
  assert.deepEqual(Object.keys(schema.properties).sort(), [
    "accounts",
    "allowed_hosts",
    "creators",
    "genesis",
    "github",
    "id",
    "name",
    "spec",
    "summary",
    "version",
  ]);
  assert.deepEqual(schema.properties.id, { $ref: "#/$defs/assistantIdentifier" });
  assert.equal(schema.$defs.assistantIdentifier.maxLength, 40);
  assert.deepEqual(schema.$defs.assistantIdentifier.not.enum, ["postgres", "app-egress-proxy"]);
  assert.equal(schema.properties.accounts.propertyNames.$ref, "#/$defs/identifier");
  assert.deepEqual(schema.$defs.account.required, ["scopes"]);
  assert.equal(schema.$defs.account.additionalProperties, false);
  assert.equal("provider" in schema.$defs.account.properties, false);
});
