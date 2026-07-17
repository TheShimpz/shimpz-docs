import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const rules = `# Hello Pulse

Use only the declared \`hello\` Power.
Ask for the person's name when it is missing.
Keep the greeting brief and friendly.
Never infer another Power or send data outside the Capsule.`;

export const load: PageServerLoad = async () => ({
  rules: await highlightCode(rules, "markdown"),
});
