import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const rules = `# Hello Pulse

Respond naturally to questions and conversation. Use the declared \`hello\` Power only when the Captain explicitly
asks you to run or demonstrate it. After a Power result, explain the outcome naturally.
Ask for the person's name when it is missing.
Keep the greeting brief and friendly.
Never infer another Power or send data outside the Team.`;

export const load: PageServerLoad = async () => ({
  rules: await highlightCode(rules, "markdown"),
});
