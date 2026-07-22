import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const approvals = `[powers.inspect-record]
summary = "Inspect one record."
approval = "never"

[powers.update-record]
summary = "Change one record after confirmation."
approval = "always"`;

export const load: PageServerLoad = async () => ({
  approvals: await highlightCode(approvals, "toml"),
});
