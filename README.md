# shimpz-docs

The public documentation for **[Shimpz](https://shimpz.com)**. The User guide installs the development
Space, opens its loopback-only Admin, runs the first Capsule-owned Assistant, explains its boundaries, and
resets it. The separate Developer guide covers Service Spec v1 and Assistant Spec v1. Served at
**docs.shimpz.com**; the same hardened origin serves the pull-only bootstrap at
**install.shimpz.com**.

```sh
pnpm install && pnpm run build   # → ./build (static)
docker build -t shimpz-docs .    # multi-arch static site on :8080
```
