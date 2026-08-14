import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";

const ROOT = new URL("../", import.meta.url);
const ROUTE = new URL("src/routes/developers/assistants/requests/", ROOT);

/** @param {string} path */
function text(path) {
  return readFileSync(new URL(path, ROOT), "utf8");
}

test("static Creator navigation exposes the dedicated human request submenu", () => {
  const layout = text("src/routes/+layout.svelte");
  assert.match(layout, /label: "Ask a human"/);
  for (const page of ["approval", "input", "auth", "lifecycle"]) {
    assert.match(layout, new RegExp(`/developers/assistants/requests/${page}/`));
  }
});

test("static Action request guides cover the public SDK and settled safety boundaries", () => {
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
    "auth:password",
    "auth:totp",
    "auth:passkey",
  ]) {
    assert.match(pages, new RegExp(surface));
  }
  assert.match(pages, /At most 8 human requests/);
  assert.match(pages, /At most 16 human requests/);
  assert.match(pages, /at most one authorization request/i);
  assert.match(pages, /cannot combine\s+approval with authentication/i);
  assert.match(pages, /300 seconds/);
  assert.match(pages, /third-party secret/i);
  assert.match(pages, /request-before-action/i);
  assert.match(pages, /Hosted continuation is memory-only/);
  assert.match(pages, /entire Team turn/);
});

test("static complete Action examples use SDK-supported TypedDict results", () => {
  const examples = [
    readFileSync(new URL("+page.server.ts", ROUTE), "utf8"),
    readFileSync(new URL("approval/+page.server.ts", ROUTE), "utf8"),
    readFileSync(new URL("lifecycle/+page.server.ts", ROUTE), "utf8"),
  ].join("\n");
  assert.doesNotMatch(examples, /-> dict\[/);
  assert.match(examples, /TypedDict/);
});

test("static native request examples cover every settled request kind without frozen screenshots", () => {
  const fixtures = text("src/lib/actionRequestExamples.ts");
  const component = text("src/lib/components/RequestExample.svelte");
  const pages = ["approval", "input", "auth"]
    .map((name) => readFileSync(new URL(`${name}/+page.svelte`, ROUTE), "utf8"))
    .join("\n");
  const ids = [
    "approval",
    "input-text",
    "input-textarea",
    "input-password",
    "input-phone",
    "input-select",
    "input-choice",
    "input-choices",
    "auth-password",
    "auth-totp",
    "auth-passkey",
  ];
  for (const id of ids) {
    assert.match(fixtures, new RegExp(`id: "${id}"`));
  }
  for (const primitive of ["ActionRequestFields", "Button", "DialogFrame", "SelectField", "themeClass"]) {
    assert.match(component, new RegExp(`\\b${primitive}\\b`));
  }
  for (const entryPoint of ["ActionRequestFields", "Button", "DialogFrame", "SelectField"]) {
    assert.match(component, new RegExp(`@shimpz/frontend/components/${entryPoint}`));
  }
  assert.match(component, /@shimpz\/frontend\/theme/);
  assert.doesNotMatch(component, /from ["']@shimpz\/frontend["']/);
  assert.match(component, /nothing is submitted/);
  assert.doesNotMatch(component, /fetch\(|onsubmit|AssistantHumanRequestDialog|PromptDialog|Modal/);
  assert.doesNotMatch(`${pages}\n${component}`, /RequestScreenshot|action-requests\/.*\.png/);
});
