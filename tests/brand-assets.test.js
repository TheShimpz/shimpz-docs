import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const brand = new URL('../static/brand/', import.meta.url);
const layout = readFileSync(new URL('../src/routes/+layout.svelte', import.meta.url), 'utf8');
const home = readFileSync(new URL('../src/routes/+page.svelte', import.meta.url), 'utf8');
/** @type {Array<[string, number]>} */
const assets = [
  ['shimpz-cyberchimp-friendly-v2-40.png', 40],
  ['shimpz-cyberchimp-friendly-v2-80.png', 80],
  ['shimpz-cyberchimp-friendly-v2-144.png', 144],
  ['shimpz-cyberchimp-friendly-v2-288.png', 288],
];

test('brand marks ship only their exact 1x and 2x raster sizes', async () => {
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

test('navigation and hero select their matching density variants', () => {
  assert.match(layout, /friendly-v2-40\.png 1x/);
  assert.match(layout, /friendly-v2-80\.png 2x/);
  assert.match(layout, /width="40"\s+height="40"/);
  assert.match(home, /friendly-v2-144\.png 1x/);
  assert.match(home, /friendly-v2-288\.png 2x/);
  assert.match(home, /width="144"\s+height="144"/);
});
