import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const page = readFileSync(
  new URL("../src/routes/developers/assistants/spec/approvals/+page.svelte", import.meta.url),
  "utf8",
);
const schema = JSON.parse(
  readFileSync(new URL("../static/specs/assistant/manifest.schema.json", import.meta.url), "utf8"),
);

test("static approval docs state the hosted execution limitation", () => {
  assert.match(page, /Hosted Store chat currently uses <code>shimpz\.chat\.v2<\/code>/);
  assert.match(page, /terminal <code>409<\/code> and does not execute a Power/);
  assert.match(page, /installed local Admin\/controller supports/);
});

test("static approval schema describes the same hosted limitation", () => {
  const description = schema.$defs.power.properties.approval.description;
  assert.match(description, /local controller executes once\/always/);
  assert.match(description, /Hosted Store chat v2 currently returns terminal 409 without executing/);
});
