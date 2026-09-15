import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const ROOT = new URL("../", import.meta.url);

/** @param {string} path */
function text(path) {
  return readFileSync(new URL(path, ROOT), "utf8");
}

const page = text("src/routes/developers/assistants/local/+page.svelte");

test("static Local snapshot task documents the released CLI and Admin journey", () => {
  for (const contract of [
    "shimpz assistant check",
    "shimpz assistant stage",
    "Local Assistant snapshot staged.",
    "Staged on this machine",
    "Install or replace",
    "Local Assistant installed",
    "docker image rm sha256:",
  ]) {
    assert.match(page, new RegExp(contract.replaceAll(" ", "\\s+")));
  }
  assert.match(page, /MFA-authenticated Local Supervisor/);
  assert.match(page, /same machine and Docker daemon as the Local Space/);
  assert.match(page, /more\s+than 50 staged candidates/);
  assert.match(page, /Do not run a global Docker image prune/);
});

test("static Local snapshot task preserves provenance, locality, and secret boundaries", () => {
  assert.match(page, /not published, reviewed, signed, or scanned/);
  assert.match(page, /no Account, Creator profile, Developers request, Store listing, or Neuron operation/);
  assert.match(page, /Hosted, another Space, Store discovery, or distribution/);
  assert.match(page, /WhatsApp token/);
  assert.match(page, /requested just in time and retained under that Team's custody/);
  assert.match(page, /Staging never asks for provider access/);
  assert.match(page, /failed replacement leaves the current Assistant in place/);
  assert.match(page, /successor fails[\s\S]+newly staged image remain/);
});

test("static Local snapshot guide is reachable from every public discovery surface", () => {
  const route = "/developers/assistants/local/";
  assert.match(text("src/routes/+layout.svelte"), new RegExp(`href: "${route}"`));
  assert.match(text("src/routes/developers/+page.svelte"), new RegExp(`href="${route}"`));
  assert.match(text("static/sitemap.xml"), new RegExp(`https://docs\\.shimpz\\.com${route}`));
  assert.match(text("static/llms.txt"), new RegExp(`https://docs\\.shimpz\\.com${route}`));
});
