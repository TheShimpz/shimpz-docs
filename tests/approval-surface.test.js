import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const page = readFileSync(
  new URL("../src/routes/developers/assistants/spec/approvals/+page.svelte", import.meta.url),
  "utf8",
);

test("approval docs describe the v3 in-body contract", () => {
  assert.match(page, /ctx\.human\.approval/);
  assert.match(page, /runs="always"/);
  assert.match(page, /runs="once"/);
  assert.match(page, /Local Admin chat and hosted Store chat/);
  assert.doesNotMatch(page, /shimpz\.assistant\.toml|terminal <code>409<\/code>|approval =/);
});
