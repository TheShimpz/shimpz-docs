# shimpz-docs

The public documentation for **[Shimpz](https://shimpz.com)**. The User guide installs the stable Space,
creates a Team, configures its Brain, installs Assistants, and maintains the local installation.
The Developer guide explains the single current Assistant SPEC in small, independent steps.
Served at
**docs.shimpz.com**; the same hardened origin serves the pull-only bootstrap at
**install.shimpz.com**.

```sh
pnpm install --frozen-lockfile --ignore-scripts && pnpm run build   # Node.js 26, pnpm 11.9.0 → ./build (static)
docker build -t shimpz-docs .    # multi-arch static site on :8080
```

## Origin performance (Caddy → nginx, 2026-10-10)

Measured on identical prerendered bytes (same `/srv` tree hash, `.gz` files aside) with the Compose limits (0.5 CPU,
256 MB), each server alone on a disposable network, `oha` 1.16.0 for 10 s per run with `Accept-Encoding: gzip`, 3
interleaved runs each; medians with the run range. The asset is the largest immutable chunk (53 KB). Caddy gzips per
request (level 5); nginx serves the build's `gzip -9` file (`gzip_static`), keeping on-the-fly gzip as a fallback.

| Metric | Caddy 2.11.4 | nginx 1.30.5 |
| --- | --- | --- |
| `/` at 50 connections | 1110 req/s [1107–1115], p99 97.2 ms | 12123 req/s [12080–12255], p99 54.4 ms |
| `/` at 1 connection | 1015 req/s, p50 0.42 ms, p99 3.79 ms | 11533 req/s, p50 0.05 ms, p99 0.16 ms |
| asset at 50 connections | 388 req/s [370–392], p99 290 ms | 12604 req/s [12328–13011], p99 54.3 ms |
| asset at 1 connection | 378 req/s, p50 1.06 ms, p99 54.0 ms | 12126 req/s, p50 0.05 ms, p99 0.16 ms |
| gzip bytes per asset / page response | 20614 / 3350 | 19855 / 3299 |
| image size | 156.9 MB | 93.5 MB |
| idle RSS (all processes) | 45.2 MiB | 10.3 MiB |
| cgroup memory, idle / after load | 10.7 / ~18 MiB | 2.9 / 2.9 MiB |

No run had an error beyond the in-flight requests `oha` aborts at its deadline. Without precompression (gzip level 5
per request) nginx measured 1159 req/s on `/` but only 210 req/s on the asset at 50 connections, half of Caddy, which
is why the build precompresses.
