import sourcePackageUpstream from "../../../../../static/specs/source-package/upstream.json";

import type { PageServerLoad } from "./$types";

export const load = (() => ({ sourcePackageUpstream })) satisfies PageServerLoad;
