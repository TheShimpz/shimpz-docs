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
    commit: "62baa183c053143bea47ce128cfcab8884b9555d",
    path: "protocol/source-package/v1",
    tree: "a9840a62a671be7fd7cff9cb24d89529e4404bd1",
    contract_files_sha256:
      "c1f83364fc9b1b07e7bc014d48637dffd0c1d61eb7cdfe46063e1497aa869a43",
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
