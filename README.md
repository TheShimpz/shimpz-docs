# shimpz-docs

The initial public User documentation for **[Shimpz](https://shimpz.com)**: install the Linux amd64
development Space, open its loopback-only Admin, understand the Space/Driver/Capsule/App boundaries,
and reset the local installation. Served at **docs.shimpz.com**. The same hardened origin serves the
pull-only bootstrap at **install.shimpz.com**.

```sh
pnpm install && pnpm run build   # → ./build (static)
docker build -t shimpz-docs .    # multi-arch static site on :8080
```
