#!/usr/bin/env bash

set -euo pipefail

# Allow toggling verbose output
[[ -n ${VERBOSE:-} ]] && set -x

source .env || (
  echo "No .env file found. Please copy env.example to .env, customize it and re-run." && exit 1
)

mkdir -p "${PWD}/keycloak-data"
CODER_ACCESS_URL="${CODER_ACCESS_URL}" envsubst <realm-template.json >keycloak-data/example-realm.json

echo "Starting deployment"

docker-compose up -d

echo "Waiting for ${CODER_ACCESS_URL} to become ready..."

timeout 60s bash -c "until curl -s --fail ${CODER_ACCESS_URL}/healthz > /dev/null 2>&1; do sleep 0.5; done" ||
  fatal 'Coder did not become ready in time' &
wait $!
set -o pipefail

CONFIG_DIR="${PWD}/.coderv2"
ARCH="$(arch)"
if [[ "$ARCH" == "x86_64" ]]; then
  ARCH="amd64"
fi
PLATFORM="$(uname | tr '[:upper:]' '[:lower:]')"

mkdir -p "${CONFIG_DIR}"
echo "Fetching Coder CLI for first-time setup!"
curl -fsSLk "${CODER_ACCESS_URL}/bin/coder-${PLATFORM}-${ARCH}" -o "${CONFIG_DIR}/coder"
chmod +x "${CONFIG_DIR}/coder"

set +o pipefail
set -o pipefail
CODER_FIRST_USER_EMAIL="admin@coder.com"
CODER_FIRST_USER_USERNAME="coder"
CODER_FIRST_USER_PASSWORD="SomeSecurePassword!"
echo "Running login command!"
${CONFIG_DIR}/coder login "${CODER_ACCESS_URL}" \
  --global-config="${CONFIG_DIR}" \
  --first-user-username="${CODER_FIRST_USER_USERNAME}" \
  --first-user-email="${CODER_FIRST_USER_EMAIL}" \
  --first-user-password="${CODER_FIRST_USER_PASSWORD}" \
  --first-user-trial=false

echo "Temporary deployment is up!"
echo "Access URL: ${CODER_ACCESS_URL}"
echo "Username: ${CODER_FIRST_USER_USERNAME}"
echo "Password: ${CODER_FIRST_USER_PASSWORD}"
echo "OIDC user: keycloak"
echo "OIDC password: password"
