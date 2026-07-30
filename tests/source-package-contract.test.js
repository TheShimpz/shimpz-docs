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
    commit: "15608b2b1ff1237af636568011c1ff1bc73cf5bc",
    path: "protocol/source-package/v1",
    tree: "b6fa41e3d12486945100ac7de9a1382a227c9dcc",
    contract_files_sha256:
      "2f188eb7fe715d3a9750350d9271e69821153d1e00e1dcdcd0a0df02a8d20917",
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
