# shimpz-docs

The public documentation for **[Shimpz](https://shimpz.com)**. The User guide installs the stable Space,
creates a Team, configures its Brain, connects Cloudflare through OAuth, and maintains the local installation.
The Developer guide documents only the current Assistant Spec v2 surface, the production Cloudflare example,
and the reviewed path for adding another OAuth provider.
Served at
**docs.shimpz.com**; the same hardened origin serves the pull-only bootstrap at
**install.shimpz.com**.

```sh
pnpm install && pnpm run build   # Node.js 24 → ./build (static)
docker build -t shimpz-docs .    # multi-arch static site on :8080
```
