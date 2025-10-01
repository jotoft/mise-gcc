#!/bin/bash
set -e

# Check for required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo "ERROR: GITHUB_TOKEN is required"
    exit 1
fi

if [ -z "$GITHUB_REPO" ]; then
    echo "ERROR: GITHUB_REPO is required (format: owner/repo)"
    exit 1
fi

RUNNER_NAME="${RUNNER_NAME:-debian-runner-$(hostname)}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,debian,glibc-2.31}"

echo "Configuring GitHub Actions runner..."
echo "Repository: $GITHUB_REPO"
echo "Runner name: $RUNNER_NAME"
echo "Labels: $RUNNER_LABELS"

# Get registration token
echo "Requesting registration token from GitHub API..."
RESPONSE=$(curl -sX POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/${GITHUB_REPO}/actions/runners/registration-token)

echo "API Response: $RESPONSE"

REGISTRATION_TOKEN=$(echo "$RESPONSE" | jq -r .token)

if [ -z "$REGISTRATION_TOKEN" ] || [ "$REGISTRATION_TOKEN" = "null" ]; then
    echo "ERROR: Failed to get registration token"
    echo "Full response: $RESPONSE"
    ERROR_MSG=$(echo "$RESPONSE" | jq -r .message)
    echo "Error message: $ERROR_MSG"
    exit 1
fi

# Configure the runner
./config.sh \
    --url "https://github.com/${GITHUB_REPO}" \
    --token "${REGISTRATION_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "${RUNNER_LABELS}" \
    --unattended \
    --replace

# Cleanup function
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token "${REGISTRATION_TOKEN}"
}
trap cleanup EXIT

# Start the runner
echo "Starting runner..."
./run.sh
