import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";

const ROOT = new URL("../", import.meta.url);

/** @param {string} path */
function text(path) {
  return readFileSync(new URL(path, ROOT), "utf8");
}

test("static publication guide follows the current one-command contract", () => {
  const page = text("src/routes/developers/assistants/publish/+page.svelte");
  const layout = text("src/routes/+layout.svelte");
  const icons = text("src/routes/developers/assistants/icons/+page.server.ts");
  const spec = text("src/routes/developers/assistants/spec/+page.svelte");

  assert.match(layout, /\/developers\/assistants\/publish\//);
  assert.match(page, /shimpz publish --visibility public/);
  assert.match(page, /shimpz publish --visibility private/);
  assert.match(page, /identity:read/);
  assert.match(page, /assistant:publish/);
  assert.match(page, /Assistant published and installable\./);
  assert.match(page, /queued[\s\S]*resolving[\s\S]*building[\s\S]*scanning[\s\S]*signing[\s\S]*artifact_ready/);
  assert.match(page, /creator_consent_required/);
  assert.match(page, /version_already_published/);
  assert.match(page, /consent is bound to the exact Assistant id, version, and source digest/);
  assert.match(page, /Visibility is a separate[\s\S]*immutable publication setting/);
  assert.match(page, /A separate <code>shimpz auth<\/code> step is not required/);
  assert.doesNotMatch(page, /Neuron|Bearer |\/api\/v1\/publications/);
  assert.doesNotMatch(icons, /shimpz publish/);
  assert.doesNotMatch(spec, /shimpz publish --visibility/);
  assert.match(spec, /href="\/developers\/assistants\/publish\/"/);
});
