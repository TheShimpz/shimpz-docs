import { redirect } from "@sveltejs/kit";

export function load() {
  redirect(308, "/developers/assistants/spec/runtime/");
}
