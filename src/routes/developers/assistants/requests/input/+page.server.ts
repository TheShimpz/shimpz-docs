import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const examples = {
  text: `resource = ctx.request_input(
    InputRequest(
        kind="text",
        title=text("Identify the resource"),
        description=text("Enter the exact resource name to inspect."),
        label=text("Resource name"),
        placeholder=text("api.example.com"),
        min_length=3,
        max_length=253,
    )
)`,
  textarea: `note = ctx.request_input(
    InputRequest(
        kind="textarea",
        title=text("Describe the incident"),
        description=text("Add the context needed to prepare the response."),
        label=text("Incident context"),
        min_length=20,
        max_length=2000,
    )
)`,
  password: `provider_secret = ctx.request_input(
    InputRequest(
        kind="password",
        title=text("Connect the provider"),
        description=text("Provide the third-party API secret for this connection."),
        label=text("Provider API secret"),
        min_length=1,
        max_length=256,
    )
)

# Password input is the final human request. Never return provider_secret.
return await connect_provider(provider_secret)`,
  phone: `phone = ctx.request_input(
    InputRequest(
        kind="phone",
        title=text("Choose an escalation contact"),
        description=text("Enter the phone number that should receive this escalation."),
        label=text("Escalation phone"),
        placeholder=text("+1 415 555 0100"),
        min_length=7,
        max_length=32,
    )
)`,
  select: `environment = ctx.request_input(
    InputRequest(
        kind="select",
        title=text("Choose the environment"),
        description=text("Select the one environment this read should inspect."),
        label=text("Environment"),
        options=(
            InputOption("production", text("Production")),
            InputOption("staging", text("Staging")),
        ),
    )
)`,
  choice: `mode = ctx.request_input(
    InputRequest(
        kind="choice",
        title=text("Choose the DNS mode"),
        description=text("Select exactly one routing behavior."),
        label=text("Mode"),
        options=(
            InputOption("proxied", text("Proxied"), text("Route traffic through Cloudflare.")),
            InputOption("dns-only", text("DNS only"), text("Publish only the DNS answer.")),
        ),
    )
)`,
  choices: `channels = ctx.request_input(
    InputRequest(
        kind="choices",
        title=text("Choose notification channels"),
        description=text("Select one or two channels for this incident."),
        label=text("Channels"),
        options=(
            InputOption("email", text("Email")),
            InputOption("sms", text("SMS")),
            InputOption("voice", text("Voice call")),
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
