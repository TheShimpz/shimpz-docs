#!/usr/bin/env python3
"""Real-server contracts for the built Docs origin image (SHIMPZ_DOCS_TEST_IMAGE).

The image runs as the graph runs it: read-only, every capability dropped, no network, /tmp on a tmpfs. Requests are
raw HTTP/1.1 sent from inside the container to its own listener, so the test needs no published port.
"""

from __future__ import annotations

import gzip
import io
import os
import re
import secrets
import subprocess
import time
from http.client import HTTPResponse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = (ROOT / "static" / "install.sh").read_bytes()
DOCS_HOST = "docs.shimpz.com"
INSTALLER_HOST = "install.shimpz.com"
READY_SECONDS = 60
SECURITY_HEADERS = {
    "strict-transport-security": "max-age=31536000; includeSubDomains",
    "x-content-type-options": "nosniff",
    "x-frame-options": "DENY",
    "referrer-policy": "strict-origin-when-cross-origin",
    "permissions-policy": "camera=(), microphone=(), geolocation=(), payment=(), usb=()",
}
CSP = re.compile(
    re.escape(
        "default-src 'self'; base-uri 'self'; object-src 'none'; frame-ancestors 'none'; form-action 'self'; "
        "script-src 'self'"
    )
    + r"(?: 'sha256-[A-Za-z0-9+/]{43}=')+"
    + re.escape(
        "; require-trusted-types-for 'script'; trusted-types svelte-trusted-html; style-src 'self' 'unsafe-inline'; "
        "img-src 'self'; font-src 'self' data:; connect-src 'self'; worker-src 'self' blob:; manifest-src 'self'; "
        "upgrade-insecure-requests"
    )
)
VERSION = re.compile(r"\d+\.\d+")


class Response:
    def __init__(self, raw: bytes) -> None:
        reader = HTTPResponse(_Socket(raw))
        reader.begin()
        self.status = reader.status
        self.headers = [(name.lower(), value) for name, value in reader.getheaders()]
        self.body = reader.read()

    def values(self, name: str) -> list[str]:
        return [value for header, value in self.headers if header == name]

    def header(self, name: str) -> str | None:
        found = self.values(name)
        check(len(found) <= 1, f"at most one {name} header: {found}")
        return found[0] if found else None


class _Socket:
    def __init__(self, raw: bytes) -> None:
        self.raw = raw

    def makefile(self, _mode: str) -> io.BytesIO:
        return io.BytesIO(self.raw)


def check(condition: object, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def docker(*arguments: str, stdin: bytes | None = None) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(["docker", *arguments], input=stdin, capture_output=True, check=False, timeout=60)


def request(container: str, host: str, path: str, *extra: str) -> Response:
    lines = [f"GET {path} HTTP/1.1", f"Host: {host}", *extra, "Connection: close", "", ""]
    result = docker("exec", "-i", container, "nc", "127.0.0.1", "8080", stdin="\r\n".join(lines).encode())
    check(result.returncode == 0 and result.stdout, f"{host}{path} answered: {result.stderr!r}")
    response = Response(result.stdout)
    check_policy(response, f"{host}{path}")
    return response


def check_policy(response: Response, label: str) -> None:
    """Every response, redirects and errors included, carries one complete policy and no version."""
    for name, value in SECURITY_HEADERS.items():
        check(response.values(name) == [value], f"{label} {name}: {response.values(name)}")
    policies = response.values("content-security-policy")
    check(len(policies) == 1 and CSP.fullmatch(policies[0]), f"{label} carries exactly one CSP: {policies}")
    check(response.values("server") == ["nginx"], f"{label} names no server version: {response.values('server')}")
    if response.status >= 300:
        check(not VERSION.search(response.body.decode("latin-1")), f"{label} body discloses no version")


def start(image: str) -> str:
    container = f"shimpz-docs-origin-{secrets.token_hex(4)}"
    started = docker(
        "run",
        "--detach",
        "--name",
        container,
        "--network",
        "none",
        "--read-only",
        "--cap-drop",
        "ALL",
        "--security-opt",
        "no-new-privileges:true",
        "--tmpfs",
        "/tmp:size=8m,mode=1777",
        image,
    )
    check(started.returncode == 0, f"hardened Docs origin starts: {started.stderr!r}")
    deadline = time.monotonic() + READY_SECONDS
    while time.monotonic() < deadline:
        if docker("exec", container, "wget", "-q", "-O", "/dev/null", "http://127.0.0.1:8080/").returncode == 0:
            return container
        time.sleep(0.2)
    logs = docker("logs", container)
    docker("rm", "-f", container)
    raise AssertionError(f"Docs origin never answered: {logs.stderr!r}")


def served_file(container: str, pattern: str) -> tuple[str, bytes]:
    # Larger than the 512-byte compression threshold, so the asset must compress when asked.
    listed = docker("exec", container, "find", "/srv/_app/immutable", "-type", "f", "-name", pattern, "-size", "+1k")
    files = sorted(listed.stdout.decode().split())
    check(files, f"the build has a compressible immutable {pattern} asset")
    content = docker("exec", container, "cat", files[0])
    check(content.returncode == 0, f"{files[0]} is readable")
    return files[0].removeprefix("/srv"), content.stdout


def test_image_runs_as_the_graph_identity(image: str, _container: str) -> None:
    user = docker("image", "inspect", "--format", "{{.Config.User}}", image).stdout.decode().strip()
    check(user == "65532:65532", f"the image ends on the graph's non-root identity: {user}")


def test_installer_host_serves_only_the_uncached_bootstrap(_image: str, container: str) -> None:
    for path in ("/", "/install.sh", "/?channel=stable"):
        response = request(container, INSTALLER_HOST, path)
        check(response.status == 200, f"installer {path} is served: {response.status}")
        check(response.body == INSTALLER, f"installer {path} is the committed bootstrap")
        check(response.header("content-type") == "text/plain; charset=utf-8", f"installer {path} is plain text")
        check(response.header("cache-control") == "no-store", f"installer {path} is never cached")
    for path in ("/index.html", "/admin/", "/install.sh/", "/robots.txt"):
        response = request(container, INSTALLER_HOST, path)
        check(response.status == 404, f"installer host refuses {path}: {response.status}")
        check(response.header("cache-control") is None, f"installer {path} 404 has no installer cache policy")


def test_docs_is_the_default_host(_image: str, container: str) -> None:
    home = request(container, DOCS_HOST, "/")
    check(home.status == 200 and home.header("content-type") == "text/html; charset=utf-8", "Docs home is HTML")
    check(b"<!doctype html>" in home.body.lower(), "Docs home is the prerendered page")
    for host in ("unknown.example", "shimpz-docs:8080"):
        other = request(container, host, "/")
        check(other.status == 200 and other.body == home.body, f"{host} reaches the Docs default server")


def test_directories_redirect_to_their_canonical_slash(_image: str, container: str) -> None:
    page = request(container, DOCS_HOST, "/admin/")
    check(page.status == 200 and page.header("content-type") == "text/html; charset=utf-8", "a route is served")
    for path, location in (("/admin", "/admin/"), ("/admin?tab=one&x=2", "/admin/?tab=one&x=2")):
        response = request(container, DOCS_HOST, path)
        check(response.status == 301, f"{path} redirects: {response.status}")
        check(response.header("location") == location, f"{path} keeps its query: {response.header('location')}")
    for path in ("//admin/", "/admin//"):
        merged = request(container, DOCS_HOST, path)
        check(merged.status == 200 and merged.body == page.body, f"{path} merges its slashes")


def test_missing_urls_are_real_404s(_image: str, container: str) -> None:
    home = request(container, DOCS_HOST, "/").body
    for path in ("/missing", "/missing/", "/missing.html", "/_app/", "/a//b"):
        response = request(container, DOCS_HOST, path)
        check(response.status == 404, f"{path} is a 404: {response.status}")
        check(response.body != home and b"<html" not in response.body.lower(), f"{path} never falls back")


def test_assets_have_their_type_and_compress(_image: str, container: str) -> None:
    for pattern, content_type in (("*.js", "application/javascript"), ("*.css", "text/css")):
        path, content = served_file(container, pattern)
        plain = request(container, DOCS_HOST, path)
        check(plain.status == 200 and plain.body == content, f"{path} is served byte for byte")
        check(plain.header("content-type") == f"{content_type}; charset=utf-8", f"{path} has its type")
        check(plain.header("content-encoding") is None, f"{path} is not compressed unasked")
        packed = request(container, DOCS_HOST, path, "Accept-Encoding: gzip")
        check(packed.header("content-encoding") == "gzip", f"{path} compresses when asked")
        check(packed.header("vary") == "Accept-Encoding", f"{path} varies by encoding")
        check(gzip.decompress(packed.body) == content, f"{path} decompresses to the file")


def main() -> None:
    image = os.environ.get("SHIMPZ_DOCS_TEST_IMAGE", "")
    check(image, "SHIMPZ_DOCS_TEST_IMAGE names the built Docs image")
    tests = [value for name, value in sorted(globals().items()) if name.startswith("test_") and callable(value)]
    container = start(image)
    try:
        for test in tests:
            test(image, container)
    finally:
        docker("rm", "-f", container)
    print(f"{len(tests)} Docs origin contracts passed")


if __name__ == "__main__":
    main()
