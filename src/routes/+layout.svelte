<script lang="ts">
  import { page } from "$app/state";
  import "../app.css";

  type NavigationItem = {
    href: string;
    label: string;
    description: string;
    children?: NavigationItem[];
  };

  type NavigationSection = {
    label: string;
    items: NavigationItem[];
  };

  function flattenNavigation(items: NavigationItem[]): NavigationItem[] {
    return items.flatMap((item) => [item, ...flattenNavigation(item.children ?? [])]);
  }

  function isCurrentPath(pathname: string, href: string): boolean {
    return pathname === href || (href.endsWith("/") && pathname === href.slice(0, -1));
  }

  function isPathInBranch(pathname: string, href: string): boolean {
    const branchPath = href.endsWith("/") ? href : `${href}/`;
    return isCurrentPath(pathname, href) || pathname.startsWith(branchPath);
  }

  const userNavigation: NavigationSection[] = [
    {
      label: "Start here",
      items: [{ href: "/", label: "Overview", description: "Choose your computer" }],
    },
    {
      label: "Installation",
      items: [
        { href: "/install/linux/", label: "Linux", description: "amd64 · Supported" },
        { href: "/install/macos/", label: "macOS", description: "Apple Silicon · Supported" },
        { href: "/install/windows/", label: "Windows", description: "x64 via WSL2 · Supported" },
      ],
    },
    {
      label: "Your Space",
      items: [
        { href: "/admin/", label: "Open the Admin", description: "First access" },
        { href: "/assistants/", label: "First Assistant", description: "Create, install, and chat" },
        { href: "/manage/", label: "Update or reset", description: "Keep it current" },
      ],
    },
    {
      label: "Reference",
      items: [{ href: "/concepts/", label: "Core concepts", description: "Space, Services, Teams, Assistants" }],
    },
  ];

  const developerNavigation: NavigationSection[] = [
    {
      label: "Services",
      items: [
        { href: "/developers/services/", label: "Overview", description: "Shared Space capabilities" },
        { href: "/developers/services/spec/", label: "Service Spec v1", description: "Versioned compatibility contract" },
        {
          href: "/developers/services/postgresql/",
          label: "PostgreSQL",
          description: "First v1 reference",
        },
      ],
    },
    {
      label: "Assistants",
      items: [
        { href: "/developers/assistants/", label: "Overview", description: "Team-owned capabilities" },
        {
          href: "/developers/assistants/spec/",
          label: "Assistant Spec v2",
          description: "Start with the current contract",
          children: [
            {
              href: "/developers/assistants/spec/manifest/",
              label: "Project manifest",
              description: "One file maps the project",
            },
            {
              href: "/developers/assistants/spec/genesis/",
              label: "Genesis",
              description: "Define behavior and compose Powers",
            },
            {
              href: "/developers/assistants/spec/help/",
              label: "Help",
              description: "Guide the person using it",
            },
            {
              href: "/developers/assistants/spec/powers/",
              label: "Powers",
              description: "Declare safe actions",
            },
            {
              href: "/developers/assistants/spec/secrets/",
              label: "Secrets",
              description: "Deliver private values just in time",
            },
            {
              href: "/developers/assistants/spec/accounts/",
              label: "Accounts",
              description: "Authorize provider accounts safely",
            },
            {
              href: "/developers/assistants/spec/accounts/providers/",
              label: "OAuth providers",
              description: "Implement and validate provider adapters",
            },
            {
              href: "/developers/assistants/spec/permissions/",
              label: "Permissions",
              description: "Transparent egress, controller-owned grants",
            },
            {
              href: "/developers/assistants/spec/routines/",
              label: "Routines",
              description: "Future owner schedules",
            },
            {
              href: "/developers/assistants/spec/runtime/",
              label: "Brain runtime",
              description: "LangGraph, API keys, and files",
            },
            {
              href: "/developers/assistants/spec/changelog/",
              label: "Changelog",
              description: "Explain every published update",
            },
            {
              href: "/developers/assistants/spec/build-release/",
              label: "Build and release",
              description: "Validate and pin artifacts",
            },
          ],
        },
      ],
    },
    {
      label: "Assistant examples",
      items: [
        {
          href: "/developers/assistants/shimpz-assistant/",
          label: "Shimpz Assistant",
          description: "Accounts + Secrets reference",
        },
      ],
    },
  ];

  const isDeveloperGuide = $derived(page.url.pathname.startsWith("/developers/"));
  const navigation = $derived(isDeveloperGuide ? developerNavigation : userNavigation);
  const guideLabel = $derived(isDeveloperGuide ? "Developer guide" : "User guide");
  const guideSummary = $derived(
    isDeveloperGuide ? "build Services and Assistants" : "install and use your Space",
  );
  const navigationTitleId = $derived(isDeveloperGuide ? "developer-navigation-title" : "user-navigation-title");

  const currentLabel = $derived(
    navigation
      .flatMap((section) => flattenNavigation(section.items))
      .find((item) => item.href === page.url.pathname)?.label ?? "Overview",
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
            {@const submenuOpen = Boolean(item.children?.length && isPathInBranch(page.url.pathname, item.href))}
            <li class:has-submenu={Boolean(item.children?.length)} class:is-submenu-open={submenuOpen}>
              <a
                href={item.href}
                class="docs-nav-link"
                class:is-branch-current={submenuOpen && !isCurrentPath(page.url.pathname, item.href)}
                class:is-submenu-open={submenuOpen}
                aria-current={isCurrentPath(page.url.pathname, item.href) ? "page" : undefined}
              >
                <span class="docs-nav-rail" aria-hidden="true"></span>
                <span><strong>{item.label}</strong><small>{item.description}</small></span>
              </a>
              {#if item.children?.length && submenuOpen}
                <ul class="docs-nav-sublist" aria-label={`${item.label} topics`}>
                  {#each item.children as child}
                    <li>
                      <a
                        href={child.href}
                        class="docs-nav-sublink"
                        aria-current={page.url.pathname === child.href ? "page" : undefined}
                      >
                        <span class="docs-nav-subrail" aria-hidden="true"></span>
                        <span><strong>{child.label}</strong><small>{child.description}</small></span>
                      </a>
                    </li>
                  {/each}
                </ul>
              {/if}
            </li>
          {/each}
        </ul>
      </li>
    {/each}
  </ul>
{/snippet}

{#snippet guideSwitch()}
  <div class="mb-6 grid grid-cols-2 gap-2" role="group" aria-label="Documentation guides">
    <a
      href="/"
      class="chip justify-center"
      class:is-active={!isDeveloperGuide}
      aria-current={!isDeveloperGuide ? "page" : undefined}>User</a
    >
    <a
      href="/developers/services/"
      class="chip justify-center"
      class:is-active={isDeveloperGuide}
      aria-current={isDeveloperGuide ? "page" : undefined}>Developers</a
    >
  </div>
{/snippet}

<a class="skip-link" href="#main-content">Skip to the content</a>

<header
  class="sticky top-0 z-10 border-b hair backdrop-blur"
  style="background:color-mix(in oklab, var(--color-bg) 82%, transparent)"
>
  <div class="wrap flex h-16 items-center gap-4">
    <a href="/" class="brand-name" aria-label="Shimpz Docs home">
      <img
        src="/brand/shimpz-cyberchimp-friendly-v2.png"
        class="brand-mark"
        alt=""
        width="1254"
        height="1254"
      />
      <span>Shimpz</span>
    </a>
    <span class="docs-label hidden text-sm dim sm:inline-flex">· docs</span>
    <nav class="ml-auto flex items-center gap-1 text-sm" aria-label="Primary navigation">
      <a
        href="https://github.com/TheShimpz"
        class="github-link"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="The Shimpz on GitHub (opens in a new tab)"
      >
        <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
          <path
            d="M12 .3a12 12 0 0 0-3.8 23.4c.6.1.8-.3.8-.6v-2.1c-3.3.7-4-1.6-4-1.6-.5-1.4-1.3-1.8-1.3-1.8-1.1-.7.1-.7.1-.7 1.2.1 1.8 1.2 1.8 1.2 1.1 1.8 2.8 1.3 3.5 1 .1-.8.4-1.3.8-1.6-2.7-.3-5.5-1.3-5.5-5.9 0-1.3.5-2.4 1.2-3.2-.1-.3-.5-1.5.1-3.2 0 0 1-.3 3.3 1.2a11.5 11.5 0 0 1 6 0c2.3-1.5 3.3-1.2 3.3-1.2.6 1.7.2 2.9.1 3.2.8.8 1.2 1.9 1.2 3.2 0 4.6-2.8 5.6-5.5 5.9.4.4.8 1.1.8 2.2v3.3c0 .3.2.7.8.6A12 12 0 0 0 12 .3Z"
          />
        </svg>
      </a>
    </nav>
  </div>
</header>

<div class="wrap flex flex-col gap-10 pt-9 pb-16 lg:flex-row lg:gap-14">
  <aside class="docs-sidebar lg:w-64 lg:shrink-0">
    <div class="docs-sidebar-panel hidden lg:sticky lg:top-24 lg:block">
      {@render guideSwitch()}
      <p id={navigationTitleId} class="kicker">{guideLabel}</p>
      <nav class="mt-4" aria-labelledby={navigationTitleId}>
        {@render navigationTree()}
      </nav>
    </div>

    <details class="docs-mobile-menu lg:hidden">
      <summary>
        <span>{guideLabel}</span>
        <strong>{currentLabel}</strong>
      </summary>
      <nav aria-label={guideLabel}>
        {@render guideSwitch()}
        {@render navigationTree()}
      </nav>
    </details>
  </aside>

  <main id="main-content" tabindex="-1" class="docs-prose min-w-0 flex-1 max-w-3xl">
    {@render children()}
  </main>
</div>

<footer class="border-t hair py-10">
  <div class="wrap flex flex-wrap items-center justify-between gap-4 text-sm dim">
    <span>Shimpz · {guideLabel} — {guideSummary}</span>
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
