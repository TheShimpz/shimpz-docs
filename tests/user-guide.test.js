import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";

const ROOT = new URL("../", import.meta.url);

/** @param {string} path */
function text(path) {
  return readFileSync(new URL(path, ROOT), "utf8");
}

test("static user journey names observable current outcomes", () => {
  const home = text("src/routes/+page.svelte");
  const assistant = text("src/routes/assistants/+page.svelte");
  const admin = text("src/routes/admin/+page.svelte");
  const install = ["linux", "macos", "windows"]
    .map((platform) => text(`src/routes/install/${platform}/+page.svelte`))
    .join("\n");
  const manage = text("src/routes/manage/+page.svelte");
  const concepts = text("src/routes/concepts/+page.svelte");

  assert.doesNotMatch(home, /href="\/admin\/"/);
  assert.match(`${admin}\n${install}`, /SHIMPZ_PORT/);
  assert.match(admin, /https:\/\/local\.shimpz\.com/);
  assert.match(manage, /Shimpz Space is up to date/);
  assert.match(manage, /Shimpz Space was reset/);
  assert.match(manage, /attests its\s+loopback listener/);
  assert.match(manage, /If no\s+managed runtime remains/);
  assert.match(manage, /Ambiguous or foreign state inside a Shimpz-owned resource\s+stops reset with an error/);
  assert.match(manage, /Unrecognized content outside the owned scope is preserved and listed in the successful\s+result/);
  assert.match(assistant, /Team's complete response/);
  assert.match(assistant, /memory-only/);
  assert.doesNotMatch(assistant, /configured Secrets|Assistant's result|show me what it can read/);
  assert.match(concepts, /Local Space/);
  assert.match(concepts, /Hosted Space/);
});
