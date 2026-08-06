import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const examples = {
  text: `resource = ctx.request_input(
    InputRequest(
        kind="text",
        title="Identify the resource",
        description="Enter the exact resource name to inspect.",
        label="Resource name",
        placeholder="api.example.com",
        min_length=3,
        max_length=253,
    )
)`,
  textarea: `note = ctx.request_input(
    InputRequest(
        kind="textarea",
        title="Describe the incident",
        description="Add the context needed to prepare the response.",
        label="Incident context",
        min_length=20,
        max_length=2000,
    )
)`,
  password: `provider_secret = ctx.request_input(
    InputRequest(
        kind="password",
        title="Connect the provider",
        description="Provide the third-party API secret for this connection.",
        label="Provider API secret",
        min_length=1,
        max_length=256,
    )
)

# Password input is the final human request. Never return provider_secret.
return await connect_provider(provider_secret)`,
  phone: `phone = ctx.request_input(
    InputRequest(
        kind="phone",
        title="Choose an escalation contact",
        description="Enter the phone number that should receive this escalation.",
        label="Escalation phone",
        placeholder="+1 415 555 0100",
        min_length=7,
        max_length=32,
    )
)`,
  select: `environment = ctx.request_input(
    InputRequest(
        kind="select",
        title="Choose the environment",
        description="Select the one environment this read should inspect.",
        label="Environment",
        options=(
            InputOption("production", "Production"),
            InputOption("staging", "Staging"),
        ),
    )
)`,
  choice: `mode = ctx.request_input(
    InputRequest(
        kind="choice",
        title="Choose the DNS mode",
        description="Select exactly one routing behavior.",
        label="Mode",
        options=(
            InputOption("proxied", "Proxied", "Route traffic through Cloudflare."),
            InputOption("dns-only", "DNS only", "Publish only the DNS answer."),
        ),
    )
)`,
  choices: `channels = ctx.request_input(
    InputRequest(
        kind="choices",
        title="Choose notification channels",
        description="Select one or two channels for this incident.",
        label="Channels",
        options=(
            InputOption("email", "Email"),
            InputOption("sms", "SMS"),
            InputOption("voice", "Voice call"),
        ),
        min_selections=1,
        max_selections=2,
    )
)`,
};

export const load: PageServerLoad = async () => ({
  text: await highlightCode(examples.text, "python"),
  textarea: await highlightCode(examples.textarea, "python"),
  password: await highlightCode(examples.password, "python"),
  phone: await highlightCode(examples.phone, "python"),
  select: await highlightCode(examples.select, "python"),
  choice: await highlightCode(examples.choice, "python"),
  choices: await highlightCode(examples.choices, "python"),
});
