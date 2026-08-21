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
  const help = text("src/routes/help/+page.svelte");
  const concepts = text("src/routes/concepts/+page.svelte");

  assert.doesNotMatch(home, /href="\/admin\/"/);
  assert.match(`${admin}\n${install}`, /SHIMPZ_PORT/);
  assert.match(admin, /printed by <code>shimpz install<\/code>/);
  assert.match(admin, /at least 15 characters/);
  assert.match(admin, /TOTP factor is required/);
  assert.match(admin, /A passkey is optional/);
  assert.match(admin, /http:\/\/localhost:7777/);
  assert.doesNotMatch(admin, /\binstaller\b/i);
  assert.match(install, /cryptsetup<\/code> 2\.4 or newer/);
  assert.match(admin, /https:\/\/local\.shimpz\.com/);
  assert.match(manage, /Shimpz Space is ready/);
  assert.match(manage, /<code>shimpz stop<\/code>/);
  assert.match(manage, /<code>shimpz start<\/code>/);
  assert.match(manage, /Shimpz Space is stopped/);
  assert.match(manage, /does not require the Supervisor password/);
  assert.match(manage, /Stopping first does not bypass reset authorization/);
  assert.match(manage, /Shimpz Space was reset/);
  assert.match(manage, /attests its\s+loopback listener/);
  assert.match(manage, /Before initial password setup[\s\S]+without asking for one/);
  assert.match(manage, /If the authentication record requires recovery[\s\S]+no identity exists/);
  assert.match(manage, /If\s+no\s+managed\s+runtime remains/);
  assert.match(manage, /Ambiguous or foreign state inside a Shimpz-owned resource\s+stops reset with an error/);
  assert.match(manage, /Unrecognized content outside the owned scope is preserved and listed in the successful\s+result/);
  assert.match(help, /<code>shimpz status<\/code>/);
  assert.match(help, /<code>shimpz install<\/code>/);
  assert.doesNotMatch(`${home}\n${install}\n${help}`, /installer (reports|prints|refuses)/i);
  assert.equal((text("src/routes/install/linux/+page.svelte").match(/curl -fsSL/g) ?? []).length, 1);
  assert.match(assistant, /Team's complete response/);
  assert.match(assistant, /memory-only/);
  assert.doesNotMatch(assistant, /configured Secrets|Assistant's result|show me what it can read/);
  assert.match(concepts, /Local Space/);
  assert.match(concepts, /Hosted Space/);
});
