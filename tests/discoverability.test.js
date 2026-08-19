import assert from "node:assert/strict";
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import { test } from "node:test";

const ROOT = new URL("../", import.meta.url);
const ORIGIN = "https://docs.shimpz.com";

/** @param {string} path */
function text(path) {
  return readFileSync(new URL(path, ROOT), "utf8");
}

/** @param {string} directory @param {string[]} segments */
function pageRoutes(directory, segments = []) {
  const entries = readdirSync(new URL(directory, ROOT), { withFileTypes: true });
  const routes = entries.some((entry) => entry.isFile() && entry.name === "+page.svelte")
    ? [`/${segments.length ? `${segments.join("/")}/` : ""}`]
    : [];
  for (const entry of entries) {
    if (entry.isDirectory()) routes.push(...pageRoutes(join(directory, entry.name), [...segments, entry.name]));
  }
  return routes;
}

test("static discovery artifacts cover every canonical public page", () => {
  const routes = pageRoutes("src/routes").sort();
  const expectedURLs = routes.map((route) => `${ORIGIN}${route}`);
  const sitemap = text("static/sitemap.xml");
  const sitemapURLs = [...sitemap.matchAll(/<loc>([^<]+)<\/loc>/g)].map((match) => match[1]).sort();

  assert.deepEqual(sitemapURLs, expectedURLs);
  assert.equal(new Set(sitemapURLs).size, sitemapURLs.length);
  assert.doesNotMatch(sitemap, /<lastmod>/);

  const titles = new Set();
  const descriptions = new Set();
  for (const route of routes) {
    const pagePath = route === "/" ? "src/routes/+page.svelte" : `src/routes${route}+page.svelte`;
    const page = text(pagePath);
    const canonical = page.match(/<link\s+rel="canonical"\s+href="([^"]+)"/);
    const title = page.match(/<title>([^<]+)<\/title>/);
    const description = page.match(/<meta\s+name="description"\s+content="([^"]+)"/s);
    assert.equal(canonical?.[1], `${ORIGIN}${route}`, `${route} has its exact canonical URL`);
    assert.ok(title?.[1], `${route} has a title`);
    assert.ok(description?.[1], `${route} has a description`);
    assert.ok(!titles.has(title[1]), `${route} has a unique title`);
    assert.ok(!descriptions.has(description[1]), `${route} has a unique description`);
    titles.add(title[1]);
    descriptions.add(description[1]);
  }

  const llms = text("static/llms.txt");
  assert.match(llms, /Maintain your Space.*with the `shimpz` CLI/);
  assert.doesNotMatch(llms, /Maintain your Space.*with the installer/);
  const llmsURLs = [...llms.matchAll(/\]\((https:\/\/docs\.shimpz\.com\/[^)#]*)(?:#[^)]*)?\)/g)].map(
    (match) => match[1],
  );
  const llmsPageURLs = llmsURLs.filter((url) => new URL(url).pathname.endsWith("/")).sort();
  assert.deepEqual(llmsPageURLs, expectedURLs);

  for (const url of llmsURLs.filter((candidate) => !new URL(candidate).pathname.endsWith("/"))) {
    const target = new URL(url);
    assert.equal(target.origin, ORIGIN);
    assert.ok(statSync(new URL(`static${target.pathname}`, ROOT)).isFile(), `${url} resolves to a static authority`);
  }
});

test("static robots policy points crawlers to the canonical sitemap", () => {
  assert.equal(
    text("static/robots.txt"),
    "User-agent: *\nAllow: /\nSitemap: https://docs.shimpz.com/sitemap.xml\n",
  );
});
