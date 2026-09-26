import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const brand = new URL('../static/brand/', import.meta.url);
/** @type {Array<[string, number]>} */
const assets = [
  ['shimpz-cyberchimp-friendly-v2-40.png', 40],
  ['shimpz-cyberchimp-friendly-v2-80.png', 80],
  ['shimpz-cyberchimp-friendly-v2-144.png', 144],
  ['shimpz-cyberchimp-friendly-v2-288.png', 288],
];

test('static brand marks ship only their exact 1x and 2x raster sizes', async () => {
  let totalBytes = 0;
  for (const [name, size] of assets) {
    const image = await readFile(new URL(name, brand));
    assert.deepEqual([...image.subarray(1, 4)], [80, 78, 71], `${name} is a PNG`);
    assert.equal(image.readUInt32BE(16), size, `${name} width`);
    assert.equal(image.readUInt32BE(20), size, `${name} height`);
    totalBytes += image.byteLength;
  }
  assert.ok(totalBytes < 60 * 1024, `presized brand assets use ${totalBytes} bytes`);
});
