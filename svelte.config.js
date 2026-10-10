import adapter from "@sveltejs/adapter-static";
import { vitePreprocess } from "@sveltejs/vite-plugin-svelte";

// Static landing: prerender every page to plain HTML (best SEO/GEO). See +layout.ts (prerender = true).
export default {
  preprocess: vitePreprocess(),
  kit: {
    adapter: adapter(),
    version: { name: process.env.SOURCE_DATE_EPOCH || "0" },
    // Each prerendered page carries a meta policy admitting only its own inline bootstrap by hash; the image build
    // collects these hashes into the served script-src header (script-hashes.sh, security-headers.conf). Every DOM
    // HTML or script-URL sink refuses a plain string, and Svelte's template policy is the only one a page may create.
    csp: {
      mode: "hash",
      directives: {
        "script-src": ["self"],
        "require-trusted-types-for": ["script"],
        "trusted-types": ["svelte-trusted-html"],
      },
    },
  },
};
