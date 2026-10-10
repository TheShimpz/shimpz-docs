#!/usr/bin/env python3
"""Contracts of the running Docs origin, driven by tests/test-origin.sh.

Usage: check_origin.py ADDRESS IMMUTABLE USER — the origin's address on its test network, a copy of the served
/srv/_app/immutable directory, and the image's configured user.
"""

from __future__ import annotations

import gzip
import re
import sys
from http.client import HTTPConnection
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = (ROOT / "static" / "install.sh").read_bytes()
DOCS_HOST = "docs.shimpz.com"
INSTALLER_HOST = "install.shimpz.com"
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
# Larger than the 512-byte compression threshold, so the asset must compress when asked.
COMPRESSIBLE_BYTES = 1024


class Response:
    def __init__(self, status: int, headers: list[tuple[str, str]], body: bytes) -> None:
        self.status = status
        self.headers = [(name.lower(), value) for name, value in headers]
        self.body = body

    def values(self, name: str) -> list[str]:
        return [value for header, value in self.headers if header == name]

    def header(self, name: str) -> str | None:
        found = self.values(name)
        check(len(found) <= 1, f"at most one {name} header: {found}")
        return found[0] if found else None


class Origin:
    def __init__(self, address: str) -> None:
        self.address = address

    def get(self, host: str, path: str, headers: dict[str, str] | None = None) -> Response:
        connection = HTTPConnection(self.address, 8080, timeout=10)
        try:
            connection.request("GET", path, headers={"Host": host, **(headers or {})})
            reply = connection.getresponse()
            response = Response(reply.status, reply.getheaders(), reply.read())
        finally:
            connection.close()
        check_policy(response, f"{host}{path}")
        return response


def check(condition: object, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def check_policy(response: Response, label: str) -> None:
    """Every response, redirects and errors included, carries one complete policy and no version."""
    for name, value in SECURITY_HEADERS.items():
        check(response.values(name) == [value], f"{label} {name}: {response.values(name)}")
    policies = response.values("content-security-policy")
    check(len(policies) == 1 and CSP.fullmatch(policies[0]), f"{label} carries exactly one CSP: {policies}")
    check(response.values("server") == ["nginx"], f"{label} names no server version: {response.values('server')}")
    if response.status >= 300:
        check(not VERSION.search(response.body.decode("latin-1")), f"{label} body discloses no version")


def test_installer_host_serves_only_the_uncached_bootstrap(origin: Origin, _immutable: Path) -> None:
    for path in ("/", "/install.sh", "/?channel=stable"):
        response = origin.get(INSTALLER_HOST, path)
        check(response.status == 200, f"installer {path} is served: {response.status}")
        check(response.body == INSTALLER, f"installer {path} is the committed bootstrap")
        check(response.header("content-type") == "text/plain; charset=utf-8", f"installer {path} is plain text")
        check(response.header("cache-control") == "no-store", f"installer {path} is never cached")
    for path in ("/index.html", "/admin/", "/install.sh/", "/robots.txt"):
        response = origin.get(INSTALLER_HOST, path)
        check(response.status == 404, f"installer host refuses {path}: {response.status}")
        check(response.header("cache-control") is None, f"installer {path} 404 has no installer cache policy")


def test_docs_is_the_default_host(origin: Origin, _immutable: Path) -> None:
    home = origin.get(DOCS_HOST, "/")
    check(home.status == 200 and home.header("content-type") == "text/html; charset=utf-8", "Docs home is HTML")
    check(b"<!doctype html>" in home.body.lower(), "Docs home is the prerendered page")
    for host in ("unknown.example", "shimpz-docs:8080"):
        other = origin.get(host, "/")
        check(other.status == 200 and other.body == home.body, f"{host} reaches the Docs default server")


def test_directories_redirect_to_their_canonical_slash(origin: Origin, _immutable: Path) -> None:
    page = origin.get(DOCS_HOST, "/admin/")
    check(page.status == 200 and page.header("content-type") == "text/html; charset=utf-8", "a route is served")
    for path, location in (("/admin", "/admin/"), ("/admin?tab=one&x=2", "/admin/?tab=one&x=2")):
        response = origin.get(DOCS_HOST, path)
        check(response.status == 301, f"{path} redirects: {response.status}")
        check(response.header("location") == location, f"{path} keeps its query: {response.header('location')}")
    for path in ("//admin/", "/admin//"):
        merged = origin.get(DOCS_HOST, path)
        check(merged.status == 200 and merged.body == page.body, f"{path} merges its slashes")


def test_missing_urls_are_real_404s(origin: Origin, _immutable: Path) -> None:
    home = origin.get(DOCS_HOST, "/").body
    for path in ("/missing", "/missing/", "/missing.html", "/_app/", "/a//b"):
        response = origin.get(DOCS_HOST, path)
        check(response.status == 404, f"{path} is a 404: {response.status}")
        check(response.body != home and b"<html" not in response.body.lower(), f"{path} never falls back")


def test_assets_have_their_type_and_compress(origin: Origin, immutable: Path) -> None:
    for suffix, content_type in ((".js", "application/javascript"), (".css", "text/css")):
        files = sorted(path for path in immutable.rglob(f"*{suffix}") if path.stat().st_size > COMPRESSIBLE_BYTES)
        check(files, f"the build has a compressible immutable {suffix} asset")
        content = files[0].read_bytes()
        path = f"/_app/immutable/{files[0].relative_to(immutable).as_posix()}"
        plain = origin.get(DOCS_HOST, path)
        check(plain.status == 200 and plain.body == content, f"{path} is served byte for byte")
        check(plain.header("content-type") == f"{content_type}; charset=utf-8", f"{path} has its type")
        check(plain.header("content-encoding") is None, f"{path} is not compressed unasked")
        packed = origin.get(DOCS_HOST, path, {"Accept-Encoding": "gzip"})
        check(packed.header("content-encoding") == "gzip", f"{path} compresses when asked")
        check(packed.header("vary") == "Accept-Encoding", f"{path} varies by encoding")
        check(gzip.decompress(packed.body) == content, f"{path} decompresses to the file")
        precompressed = files[0].with_name(f"{files[0].name}.gz").read_bytes()
        check(packed.body == precompressed, f"{path} is the build's precompressed file")
        check(packed.header("content-length") == str(len(precompressed)), f"{path} has its precompressed length")


def main(arguments: list[str]) -> None:
    check(len(arguments) == 3, "usage: check_origin.py ADDRESS IMMUTABLE USER")
    address, immutable, user = arguments
    check(user == "65532:65532", f"the image ends on the graph's non-root identity: {user}")
    origin = Origin(address)
    tests = [value for name, value in sorted(globals().items()) if name.startswith("test_") and callable(value)]
    for test in tests:
        test(origin, Path(immutable))
    print(f"{len(tests) + 1} Docs origin contracts passed")


if __name__ == "__main__":
    main(sys.argv[1:])
