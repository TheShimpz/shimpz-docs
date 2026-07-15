<script lang="ts">
  import "../app.css";
  let { children } = $props();
</script>

<a class="skip-link" href="#main-content">Skip to the content</a>

<header
  class="sticky top-0 z-10 border-b hair backdrop-blur"
  style="background:color-mix(in oklab, var(--color-bg) 82%, transparent)"
>
  <div class="wrap flex h-16 items-center gap-4">
    <a href="/" class="mono flex items-center gap-2.5 text-lg font-extrabold uppercase tracking-wide">
      <span
        class="app-icon grid place-items-center"
        style="--g1:var(--color-cyan);--g2:var(--color-magenta);width:28px;height:28px;font-size:15px"
        aria-hidden="true">◆</span
      >
      <span class="glitch" data-text="SHIMPZ" style="color:var(--color-fg)">SHIMPZ</span>
    </a>
    <span class="hidden text-sm dim sm:inline">· docs</span>
    <nav class="ml-auto flex items-center gap-1 text-sm" aria-label="Primary navigation">
      <a href="https://shimpz.com" class="rounded-lg px-3 py-1.5 dim transition hover:text-[var(--color-fg)]"
        >Shimpz ↗</a
      >
    </nav>
  </div>
</header>

<div class="wrap flex flex-col gap-10 pt-9 pb-16 lg:flex-row lg:gap-14">
  <aside class="docs-sidebar lg:w-60 lg:shrink-0">
    <div class="lg:sticky lg:top-24">
      <p id="user-navigation-title" class="kicker">User guide</p>
      <nav class="mt-4" aria-labelledby="user-navigation-title">
        <ul class="docs-nav-list">
          <li>
            <a href="#linux" class="docs-nav-link">
              <span class="docs-nav-index" aria-hidden="true">01</span>
              <span><strong>Linux</strong><small>amd64 · Supported</small></span>
            </a>
          </li>
          <li>
            <a href="#macos" class="docs-nav-link">
              <span class="docs-nav-index" aria-hidden="true">02</span>
              <span><strong>macOS</strong><small>Apple Silicon · Supported</small></span>
            </a>
          </li>
          <li>
            <a href="#windows" class="docs-nav-link">
              <span class="docs-nav-index" aria-hidden="true">03</span>
              <span><strong>Windows</strong><small>Unsupported</small></span>
            </a>
          </li>
        </ul>
      </nav>
    </div>
  </aside>

  <main id="main-content" tabindex="-1" class="docs-prose min-w-0 flex-1 max-w-3xl">
    {@render children()}
  </main>
</div>

<footer class="border-t hair py-10">
  <div class="wrap flex flex-wrap items-center justify-between gap-4 text-sm dim">
    <span>Shimpz · User guide — install and open your Space</span>
    <div class="flex gap-4">
      <a href="https://shimpz.com" class="transition hover:text-[var(--color-fg)]">Shimpz</a>
    </div>
  </div>
</footer>
