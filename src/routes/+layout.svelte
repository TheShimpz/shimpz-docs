<script lang="ts">
  import "../app.css";
  let { children } = $props();
</script>

<header class="sticky top-0 z-10 border-b hair backdrop-blur" style="background:color-mix(in oklab, var(--color-bg) 82%, transparent)">
  <div class="wrap flex h-16 items-center gap-4">
    <a href="/" class="mono flex items-center gap-2.5 text-lg font-extrabold uppercase tracking-wide">
      <span class="app-icon grid place-items-center" style="--g1:#00f0ff;--g2:#ff2a6d;width:28px;height:28px;font-size:15px">◆</span>
      <span class="glitch" data-text="SHIMPZ" style="color:var(--color-fg)">SHIMPZ</span>
    </a>
    <span class="hidden text-sm dim sm:inline">· docs</span>
    <nav class="ml-auto flex items-center gap-1 text-sm">
      <a href="https://shimpz.com" class="rounded-lg px-3 py-1.5 dim transition hover:text-[var(--color-fg)]">Shimpz ↗</a>
    </nav>
  </div>
</header>

<div class="wrap flex flex-col gap-8 pt-10 pb-16 lg:flex-row">
  <aside class="lg:w-52 lg:shrink-0">
    <div class="lg:sticky lg:top-24">
      <span class="kicker">Documentation</span>
      <nav class="mt-3 flex flex-wrap gap-1.5 lg:flex-col">
        <a href="/" class="rounded-lg px-3 py-2 text-sm font-semibold" style="background:var(--color-elevated);color:var(--color-fg)">User</a>
      </nav>
    </div>
  </aside>

  <main class="md min-w-0 flex-1 max-w-3xl">
    {@render children()}
  </main>
</div>

<footer class="border-t hair py-10">
  <div class="wrap flex flex-wrap items-center justify-between gap-4 text-sm dim">
    <span>Shimpz · User docs — install and open your Space</span>
    <div class="flex gap-4">
      <a href="https://shimpz.com" class="transition hover:text-[var(--color-fg)]">Shimpz</a>
    </div>
  </div>
</footer>
