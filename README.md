# shimpz-docs

The public documentation for **[Shimpz](https://shimpz.com)**. The User guide installs the stable Space,
creates a Team, configures its Brain, installs Assistants, and maintains the local installation.
The Developer guide explains the single current Assistant SPEC in small, independent steps.
Served at
**docs.shimpz.com**; the same hardened origin serves the pull-only bootstrap at
**install.shimpz.com**.

```sh
pnpm install && pnpm run build   # Node.js 24 → ./build (static)
docker build -t shimpz-docs .    # multi-arch static site on :8080
```
