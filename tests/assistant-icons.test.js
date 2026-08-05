import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const page = readFileSync(
  new URL("../src/routes/developers/assistants/icons/+page.svelte", import.meta.url),
  "utf8",
);
const layout = readFileSync(new URL("../src/routes/+layout.svelte", import.meta.url), "utf8");
const project = readFileSync(
  new URL("../src/routes/developers/assistants/+page.server.ts", import.meta.url),
  "utf8",
);

test("static public Creator docs project the canonical Assistant icon contract", () => {
  assert.match(page, /Exactly <code>icon\.png<\/code> at the Assistant project root/);
  assert.match(page, /Exactly 1024 × 1024 pixels, no larger than 1 MiB/);
  assert.match(page, /Animated PNG, remote URLs, SVG, JPEG, WebP/);
  assert.match(page, /covered by the source digest/);
  assert.match(page, /copyright, trademark, and brand-guideline permission/);
});

test("static icon guide is discoverable beside the canonical project layout", () => {
  assert.match(layout, /href: "\/developers\/assistants\/icons\/"/);
  assert.match(project, /├── icon\.png/);
});
