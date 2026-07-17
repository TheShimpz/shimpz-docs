import { highlightCode } from "$lib/server/highlight";

import type { PageServerLoad } from "./$types";

const developmentArtifact = `[artifact]
mode = "development"
source = "."
port = 8080
health_path = "/health"
architectures = ["linux/amd64", "linux/arm64"]`;

const releaseArtifact = `[artifact]
mode = "release"
image = "ghcr.io/acme/hello-pulse@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
port = 8080
health_path = "/health"
architectures = ["linux/amd64", "linux/arm64"]`;

export const load: PageServerLoad = async () => ({
  developmentArtifact: await highlightCode(developmentArtifact, "toml"),
  releaseArtifact: await highlightCode(releaseArtifact, "toml"),
});
