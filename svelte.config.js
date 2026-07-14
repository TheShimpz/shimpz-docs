import adapter from "@sveltejs/adapter-static";
import { vitePreprocess } from "@sveltejs/vite-plugin-svelte";

// Static landing: prerender every page to plain HTML (best SEO/GEO). See +layout.ts (prerender = true).
export default {
  preprocess: vitePreprocess(),
  kit: {
    adapter: adapter(),
    version: { name: process.env.SOURCE_DATE_EPOCH || "0" },
  },
};
