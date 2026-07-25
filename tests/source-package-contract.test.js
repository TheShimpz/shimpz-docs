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
const expectedChecksums = new Map(
  checksumFile
    .trim()
    .split("\n")
    .map((line) => {
      const [checksum, filename] = line.split("  ");
      return [filename, checksum];
    }),
);

test("published source-package authority contains only the pinned contract files", async () => {
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

test("published source-package files match their authority checksums", async () => {
  for (const [filename, expected] of expectedChecksums) {
    const contents = await readFile(new URL(filename, contractDirectory));
    const actual = createHash("sha256").update(contents).digest("hex");

    assert.equal(actual, expected, filename);
  }
});
