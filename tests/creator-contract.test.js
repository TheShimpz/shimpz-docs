import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";

const ROOT = new URL("../", import.meta.url);

/** @param {string} path */
function text(path) {
  return readFileSync(new URL(path, ROOT), "utf8");
}

test("static public commands and SDK examples use only current contracts", () => {
  const home = text("src/routes/+page.svelte");
  const actionExample = text("src/routes/developers/assistants/spec/actions/+page.server.ts");
  const actionGuide = text("src/routes/developers/assistants/spec/actions/+page.svelte");
  const integrationExample = text("src/routes/developers/assistants/spec/integrations/+page.server.ts");
  const execution = text("src/routes/developers/assistants/spec/execution/+page.svelte");

  assert.doesNotMatch(home, /shimpz start/);
  assert.doesNotMatch(`${actionExample}\n${integrationExample}`, /ctx: Context = None|dict\[str, str\]/);
  assert.doesNotMatch(`${actionExample}\n${actionGuide}`, /"method"|"path"|POST \/v1\/actions/);
  assert.match(actionExample, /"human_requests": \[\]/);
  assert.match(execution, /responses/);
  assert.match(execution, /8-second execution deadline/);
  assert.match(execution, /512 KiB/);
});
