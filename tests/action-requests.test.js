import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";

const ROOT = new URL("../", import.meta.url);
const ROUTE = new URL("src/routes/developers/assistants/requests/", ROOT);

/** @param {string} path */
function text(path) {
  return readFileSync(new URL(path, ROOT), "utf8");
}

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
