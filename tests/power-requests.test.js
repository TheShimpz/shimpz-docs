import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";

const ROOT = new URL("../", import.meta.url);
const ROUTE = new URL("src/routes/developers/assistants/requests/", ROOT);
const SCREENSHOT = new URL("static/developers/power-requests/", ROOT);

/** @param {string} path */
function text(path) {
  return readFileSync(new URL(path, ROOT), "utf8");
}

test("static Developer navigation exposes the dedicated Power request submenu", () => {
  const layout = text("src/routes/+layout.svelte");
  assert.match(layout, /label: "Power requests"/);
  for (const page of ["approval", "input", "auth", "lifecycle"]) {
    assert.match(layout, new RegExp(`/developers/assistants/requests/${page}/`));
  }
});

test("static Power request guides cover the public SDK and settled safety boundaries", () => {
  const pages = [
    readFileSync(new URL("+page.svelte", ROUTE), "utf8"),
    readFileSync(new URL("approval/+page.svelte", ROUTE), "utf8"),
    readFileSync(new URL("input/+page.svelte", ROUTE), "utf8"),
    readFileSync(new URL("auth/+page.svelte", ROUTE), "utf8"),
    readFileSync(new URL("lifecycle/+page.svelte", ROUTE), "utf8"),
  ].join("\n");

  for (const surface of [
    "request_approval",
    "request_input",
    "request_auth",
    "text",
    "textarea",
    "password",
    "phone",
    "select",
    "choice",
    "choices",
    "reauth",
    "second-factor",
    "phishing-resistant",
  ]) {
    assert.match(pages, new RegExp(surface));
  }
  assert.match(pages, /At most 8 human requests/);
  assert.match(pages, /At most 16 human requests/);
  assert.match(pages, /300 seconds/);
  assert.match(pages, /third-party secret/i);
  assert.match(pages, /request-before-action/i);
  assert.match(pages, /Hosted continuation is memory-only/);
  assert.match(pages, /entire Team turn/);
});

test("static complete Power examples use SDK-supported TypedDict results", () => {
  const examples = [
    readFileSync(new URL("+page.server.ts", ROUTE), "utf8"),
    readFileSync(new URL("approval/+page.server.ts", ROUTE), "utf8"),
    readFileSync(new URL("lifecycle/+page.server.ts", ROUTE), "utf8"),
  ].join("\n");
  assert.doesNotMatch(examples, /-> dict\[/);
  assert.match(examples, /TypedDict/);
});

test("static every specialized request guide uses a real PNG modal screenshot", () => {
  const names = [
    "approval",
    "input-text",
    "input-textarea",
    "input-password",
    "input-phone",
    "input-select",
    "input-choice",
    "input-choices",
    "auth-reauth",
    "auth-second-factor",
    "auth-phishing-resistant",
  ];
  for (const name of names) {
    const image = readFileSync(new URL(`${name}.png`, SCREENSHOT));
    assert.deepEqual([...image.subarray(0, 8)], [137, 80, 78, 71, 13, 10, 26, 10]);
    assert.ok(image.length > 1_000, `${name} screenshot is unexpectedly small`);
  }
});
