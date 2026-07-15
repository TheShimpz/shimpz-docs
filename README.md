# shimpz-docs

The public documentation for **[Shimpz](https://shimpz.com)**. The User guide installs the development
Space, opens its loopback-only Admin, explains its boundaries, and resets it. The separate Developer
guide begins with Driver Spec v1 and the PostgreSQL reference implementation. Served at
**docs.shimpz.com**; the same hardened origin serves the pull-only bootstrap at
**install.shimpz.com**.

```sh
pnpm install && pnpm run build   # → ./build (static)
docker build -t shimpz-docs .    # multi-arch static site on :8080
```
