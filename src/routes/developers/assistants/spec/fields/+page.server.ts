import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const fields = `from typing import Annotated

from shimpz import choice, choices, field, power


@power()
async def plan_release(
    project=field(
        Annotated[str, {"minLength": 1, "maxLength": 80}],
        prompt="The project to release.",
    ),
    retries=field(
        Annotated[int, {"minimum": 0, "maximum": 5}],
        prompt="How many times a failed step may be retried.",
    ),
    environment=field(
        choice("staging", "production"),
        prompt="The target environment.",
    ),
    checks=field(
        choices("tests", "security", "smoke"),
        prompt="The checks to require.",
    ),
    ctx=None,
):
    ...`;

const schema = `{
  "type": "object",
  "properties": {
    "environment": {
      "type": "string",
      "enum": ["staging", "production"],
      "description": "The target environment."
    },
    "checks": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": ["tests", "security", "smoke"]
      },
      "uniqueItems": true,
      "description": "The checks to require."
    }
  },
  "required": ["environment", "checks"],
  "additionalProperties": false
}`;

export const load: PageServerLoad = async () => ({
  fields: await highlightCode(fields, "python"),
  schema: await highlightCode(schema, "json"),
});
