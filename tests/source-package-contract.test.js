import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile, readdir } from "node:fs/promises";
import test from "node:test";

const contractDirectory = new URL(
  "../static/specs/source-package/v1/",
  import.meta.url,
);
const checksumFile = await readFile(
  new URL("contract-files.sha256", contractDirectory),
  "utf8",
);
const upstream = JSON.parse(
  await readFile(
    new URL("../static/specs/source-package/upstream.json", import.meta.url),
    "utf8",
  ),
);
const expectedChecksums = new Map(
  checksumFile
    .trim()
    .split("\n")
    .map((line) => {
      const [checksum, filename] = line.split("  ");
      return [filename, checksum];
    }),
);

test("published source-package projection contains only the pinned protocol files", async () => {
  const files = (await readdir(contractDirectory)).sort();

  assert.deepEqual(files, [
    "README.md",
    "contract-files.sha256",
    "contract.json",
    "vectors.json",
    "verify.py",
  ]);
  assert.deepEqual([...expectedChecksums.keys()].sort(), [
    "README.md",
    "contract.json",
    "vectors.json",
    "verify.py",
  ]);
});

test("published source-package projection pins Developers authority", () => {
  assert.deepEqual(upstream, {
    repository: "https://github.com/TheShimpz/shimpz-developers",
    commit: "38966a38c41712ecf68383541bc007a801a514cc",
    path: "protocol/source-package/v1",
    tree: "6f1937d5c1785f0c79892f1efa873761acb45d1a",
    contract_files_sha256:
      "5ee3ad0c7d53f56304528861585b702c87e0c83a2bd11c6c9b4feb3ab2ffb3cf",
  });
  assert.equal(
    createHash("sha256").update(checksumFile).digest("hex"),
    upstream.contract_files_sha256,
  );
});

test("published source-package files match their authority checksums", async () => {
  for (const [filename, expected] of expectedChecksums) {
    const contents = await readFile(new URL(filename, contractDirectory));
    const actual = createHash("sha256").update(contents).digest("hex");

    assert.equal(actual, expected, filename);
  }
});
