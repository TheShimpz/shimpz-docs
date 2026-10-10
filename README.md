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

Measured on identical prerendered bytes (same `/srv` tree hash) with the Compose limits (0.5 CPU, 256 MB), each
server alone on a disposable network, `oha` 1.16.0 for 10 s per run with `Accept-Encoding: gzip`, 5 interleaved
runs each; medians with the run range. The asset is the largest immutable chunk (53 KB, compressed on the fly).

| Metric | Caddy 2.11.4 | nginx 1.30.5 |
| --- | --- | --- |
| `/` at 50 connections | 1120 req/s [1102–1142], p99 97.1 ms | 1159 req/s [1152–1160], p99 79.5 ms |
| `/` at 1 connection | 1030 req/s, p50 0.42 ms, p99 2.25 ms | 1157 req/s, p50 0.40 ms, p99 1.45 ms |
| asset at 50 connections | 394 req/s [391–397], p99 289 ms | 210 req/s [207–212], p99 1879 ms |
| asset at 1 connection | 377 req/s, p50 1.06 ms | 209 req/s, p50 2.13 ms |
| gzip bytes per asset response | 20614 | 20038 |
| image size | 156.9 MB | 92.7 MB |
| idle RSS (all processes) | 46.0 MiB | 10.1 MiB |
| cgroup memory, idle / after load | 11.1 / ~18 MiB | 2.9 / 2.9 MiB |

No run had an error beyond the in-flight requests `oha` aborts at its deadline. nginx is lighter and faster on
pages; at gzip level 5 its zlib compresses large assets more tightly but more slowly than Caddy's encoder, so
on-the-fly asset throughput is about half of Caddy's at 0.5 CPU.
