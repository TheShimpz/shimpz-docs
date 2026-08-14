import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const specPageServer = await readFile(
  new URL("../src/routes/developers/assistants/spec/+page.server.ts", import.meta.url),
  "utf8",
);
const specPage = await readFile(
  new URL("../src/routes/developers/assistants/spec/+page.svelte", import.meta.url),
  "utf8",
);

test("static Spec guide derives source-package authority from its published projection", () => {
  assert.match(specPageServer, /static\/specs\/source-package\/upstream\.json/);
  assert.match(specPage, /data\.sourcePackageUpstream\.commit/);
  assert.match(specPage, /data\.sourcePackageUpstream\.tree/);
  assert.doesNotMatch(specPage, /[a-f0-9]{40}/);
  assert.doesNotMatch(specPage, /\/commit\//);
});
