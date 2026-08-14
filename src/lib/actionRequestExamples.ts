export type ActionRequestExample = {
  id: string;
  label: string;
  kicker: string;
  title: string;
  description: string;
  action: string;
  request: Record<string, unknown>;
  primaryLabel: string;
  caption: string;
};

const option = (value: string, label: string, description?: string) => ({ value, label, description });

export const approvalExamples: ActionRequestExample[] = [
  {
    id: "approval",
    label: "Approval",
    kicker: "Action // approval",
    title: "Publish the reviewed DNS change",
    description: "Create the approved records in example.com.",
    action: "publish-dns",
    request: { kind: "approval" },
    primaryLabel: "Approve action",
    caption: "Approval presents the exact consequence before the human makes a one-use decision.",
  },
];

export const inputExamples: ActionRequestExample[] = [
  {
    id: "input-text",
    label: "Text",
    kicker: "Action // input:text",
    title: "Identify the resource",
    description: "Enter the exact resource name to inspect.",
    action: "inspect-resource",
    request: {
      kind: "input:text",
      label: "Resource name",
      placeholder: "api.example.com",
      min_length: 3,
      max_length: 253,
      required: true,
    },
    primaryLabel: "Send response",
    caption: "text uses one bounded single-line field.",
  },
  {
    id: "input-textarea",
    label: "Textarea",
    kicker: "Action // input:textarea",
    title: "Describe the incident",
    description: "Add the context needed to prepare the response.",
    action: "prepare-response",
    request: {
      kind: "input:textarea",
      label: "Incident context",
      placeholder: "Describe what happened and who is affected.",
      min_length: 20,
      max_length: 2000,
      required: true,
    },
    primaryLabel: "Send response",
    caption: "textarea preserves the same bounded contract in a multiline editor.",
  },
  {
    id: "input-password",
    label: "Password input",
    kicker: "Action // input:password",
    title: "Connect the provider",
    description: "Provide the third-party API secret for this connection.",
    action: "connect-provider",
    request: {
      kind: "input:password",
      label: "Provider API secret",
      min_length: 1,
      max_length: 256,
      required: true,
    },
    primaryLabel: "Send response",
    caption: "password masks an arbitrary third-party secret; it is not a Shimpz authentication ceremony.",
  },
  {
    id: "input-phone",
    label: "Phone",
    kicker: "Action // input:phone",
    title: "Choose an escalation contact",
    description: "Enter the phone number that should receive this escalation.",
    action: "set-escalation-contact",
    request: {
      kind: "input:phone",
      label: "Escalation phone",
      placeholder: "+1 415 555 0100",
      min_length: 7,
      max_length: 32,
      required: true,
    },
    primaryLabel: "Send response",
    caption: "phone provides telephone-aware entry while returning one bounded string.",
  },
  {
    id: "input-select",
    label: "Select",
    kicker: "Action // input:select",
    title: "Choose the environment",
    description: "Select the one environment this read should inspect.",
    action: "inspect-environment",
    request: {
      kind: "input:select",
      label: "Environment",
      options: [option("production", "Production"), option("staging", "Staging")],
      required: true,
    },
    primaryLabel: "Send response",
    caption: "select returns the chosen option value, not its display label.",
  },
  {
    id: "input-choice",
    label: "Choice",
    kicker: "Action // input:choice",
    title: "Choose the DNS mode",
    description: "Select exactly one routing behavior.",
    action: "configure-dns",
    request: {
      kind: "input:choice",
      label: "Mode",
      options: [
        option("proxied", "Proxied", "Route traffic through Cloudflare."),
        option("dns-only", "DNS only", "Publish only the DNS answer."),
      ],
      required: true,
    },
    primaryLabel: "Send response",
    caption: "choice exposes mutually exclusive options as an accessible radio group.",
  },
  {
    id: "input-choices",
    label: "Choices",
    kicker: "Action // input:choices",
    title: "Choose notification channels",
    description: "Select one or two channels for this incident.",
    action: "configure-notifications",
    request: {
      kind: "input:choices",
      label: "Channels",
      options: [option("email", "Email"), option("sms", "SMS"), option("voice", "Voice call")],
      min_selections: 1,
      max_selections: 2,
      required: true,
    },
    primaryLabel: "Send response",
    caption: "choices states its selection bounds and returns values in display order.",
  },
];

export const authExamples: ActionRequestExample[] = [
  {
    id: "auth-password",
    label: "Password",
    kicker: "Action // auth:password",
    title: "Confirm the DNS change",
    description: "Re-enter your platform password before publishing this change.",
    action: "publish-dns",
    request: { kind: "auth:password" },
    primaryLabel: "Confirm authorization",
    caption: "The platform verifies the password and gives the Action no credential or factor metadata.",
  },
  {
    id: "auth-totp",
    label: "Authenticator code",
    kicker: "Action // auth:totp",
    title: "Confirm the credential rotation",
    description: "Use your configured second factor before rotating this credential.",
    action: "rotate-credential",
    request: { kind: "auth:totp" },
    primaryLabel: "Confirm authorization",
    caption: "The authenticator code remains inside the Account ceremony.",
  },
  {
    id: "auth-passkey",
    label: "Passkey",
    kicker: "Action // auth:passkey",
    title: "Confirm the production release",
    description: "Use a registered passkey before releasing to production.",
    action: "release-production",
    request: { kind: "auth:passkey" },
    primaryLabel: "Use passkey",
    caption: "The browser and Account perform WebAuthn; the Action receives no assertion.",
  },
];
