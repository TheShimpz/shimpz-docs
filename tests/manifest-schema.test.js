import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const schema = JSON.parse(
  await readFile(new URL('../static/specs/assistant/manifest.schema.json', import.meta.url), 'utf8'),
);

test('published shimpz.toml schema is closed and uses JSON Schema 2020-12', () => {
  assert.equal(schema.$schema, 'https://json-schema.org/draft/2020-12/schema');
  assert.equal(schema.type, 'object');
  assert.equal(schema.additionalProperties, false);
  assert.deepEqual(schema.required, ['name', 'summary', 'creators', 'github', 'allowed_hosts']);
});

test('published shimpz.toml schema exposes only the v3 authored surface', () => {
  assert.deepEqual(Object.keys(schema.properties).sort(), [
    'accounts',
    'allowed_hosts',
    'creators',
    'github',
    'name',
    'summary',
  ]);
  assert.deepEqual(schema.properties.accounts.propertyNames.enum, ['cloudflare']);
  assert.match(schema.properties.accounts.description, /release-pinned snapshot/);
  assert.match(schema.properties.accounts.description, /must be regenerated/);
  assert.deepEqual(schema.$defs.account.required, ['scopes']);
  assert.equal(schema.$defs.account.additionalProperties, false);
  assert.equal('provider' in schema.$defs.account.properties, false);
});
