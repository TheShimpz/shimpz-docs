<script lang="ts">
  import { page } from "$app/state";
  import "../app.css";

  const navigation = [
    {
      label: "Start here",
      items: [{ href: "/", label: "Overview", description: "Choose your computer" }],
    },
    {
      label: "Installation",
      items: [
        { href: "/install/linux/", label: "Linux", description: "amd64 · Supported" },
        { href: "/install/macos/", label: "macOS", description: "Apple Silicon · Supported" },
        { href: "/install/windows/", label: "Windows", description: "Unsupported" },
      ],
    },
    {
      label: "Your Space",
      items: [
        { href: "/admin/", label: "Open the Admin", description: "First access" },
        { href: "/manage/", label: "Update or reset", description: "Keep it current" },
      ],
    },
    {
      label: "Reference",
      items: [{ href: "/concepts/", label: "Core concepts", description: "Space, Drivers, Capsules, Apps" }],
    },
  ] as const;

  const currentLabel = $derived(
    navigation.flatMap((section) => section.items).find((item) => item.href === page.url.pathname)?.label ??
      "Overview",
  );

  let { children } = $props();
</script>

{#snippet navigationTree()}
  <ul class="docs-nav-tree">
    {#each navigation as section}
      <li class="docs-nav-group">
        <span class="docs-nav-group-label">{section.label}</span>
        <ul class="docs-nav-list">
          {#each section.items as item}
            <li>
              <a
                href={item.href}
                class="docs-nav-link"
                aria-current={page.url.pathname === item.href ? "page" : undefined}
              >
                <span class="docs-nav-rail" aria-hidden="true"></span>
                <span><strong>{item.label}</strong><small>{item.description}</small></span>
              </a>
            </li>
          {/each}
        </ul>
      </li>
    {/each}
  </ul>
{/snippet}

<a class="skip-link" href="#main-content">Skip to the content</a>

<header
  class="sticky top-0 z-10 border-b hair backdrop-blur"
  style="background:color-mix(in oklab, var(--color-bg) 82%, transparent)"
>
  <div class="wrap flex h-16 items-center gap-4">
    <a href="/" class="brand-name" aria-label="Shimpz Docs home">Shimpz</a>
    <span class="hidden text-sm dim sm:inline">· docs</span>
    <nav class="ml-auto flex items-center gap-1 text-sm" aria-label="Primary navigation">
      <a
        href="https://shimpz.com"
        class="external-link rounded-lg px-3 py-1.5 transition"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Shimpz website (opens in a new tab)">Shimpz</a
      >
    </nav>
  </div>
</header>

<div class="wrap flex flex-col gap-10 pt-9 pb-16 lg:flex-row lg:gap-14">
  <aside class="docs-sidebar lg:w-64 lg:shrink-0">
    <div class="hidden lg:sticky lg:top-24 lg:block">
      <p id="user-navigation-title" class="kicker">User guide</p>
      <nav class="mt-4" aria-labelledby="user-navigation-title">
        {@render navigationTree()}
      </nav>
    </div>

    <details class="docs-mobile-menu lg:hidden">
      <summary>
        <span>User guide</span>
        <strong>{currentLabel}</strong>
      </summary>
      <nav aria-label="User guide">{@render navigationTree()}</nav>
    </details>
  </aside>

  <main id="main-content" tabindex="-1" class="docs-prose min-w-0 flex-1 max-w-3xl">
    {@render children()}
  </main>
</div>

<footer class="border-t hair py-10">
  <div class="wrap flex flex-wrap items-center justify-between gap-4 text-sm dim">
    <span>Shimpz · User guide — install and open your Space</span>
    <div class="flex gap-4">
      <a
        href="https://shimpz.com"
        class="external-link transition"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="Shimpz website (opens in a new tab)">Shimpz</a
      >
    </div>
  </div>
</footer>
