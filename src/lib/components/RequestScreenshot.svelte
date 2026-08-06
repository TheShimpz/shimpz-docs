<script lang="ts">
  let {
    src,
    alt,
    caption,
  }: {
    src: string;
    alt: string;
    caption: string;
  } = $props();
</script>

<figure class="request-screenshot">
  <div class="request-screenshot-frame">
    <img {src} {alt} width="512" loading="lazy" decoding="async" />
  </div>
  <figcaption>{caption}</figcaption>
</figure>

<style>
  .request-screenshot {
    margin: 1.75rem 0 0;
  }

  .request-screenshot-frame {
    display: grid;
    overflow: hidden;
    place-items: center;
    border-left: 2px solid var(--color-cyan);
    background: #000;
    box-shadow: inset 0 0 0 1px var(--color-border);
  }

  img {
    display: block;
    width: min(100%, 32rem);
    height: auto;
  }

  figcaption {
    margin-top: 0.65rem;
    color: var(--color-muted-2);
    font: 400 0.72rem/1.55 var(--font-mono);
  }
</style>
