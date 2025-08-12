#!/usr/bin/env bash
set -euo pipefail

COMP_FILE="ci/components.yaml"

# PR vs push diff range
if [[ "${GITHUB_EVENT_NAME:-}" == "pull_request" ]]; then
  BASE_SHA="${GITHUB_BASE_SHA:-${GITHUB_EVENT_PULL_REQUEST_BASE_SHA:-${GITHUB_SHA}}}"
  HEAD_SHA="${GITHUB_HEAD_SHA:-${GITHUB_EVENT_PULL_REQUEST_HEAD_SHA:-${GITHUB_SHA}}}"
else
  BASE_SHA="${GITHUB_EVENT_BEFORE:-${GITHUB_SHA}}"
  HEAD_SHA="${GITHUB_SHA}"
fi

if [[ -z "${BASE_SHA:-}" || "${BASE_SHA}" == "0000000000000000000000000000000000000000" ]]; then
  CHANGED_FILES=$(git ls-tree -r --name-only "$HEAD_SHA")
else
  CHANGED_FILES=$(git diff --name-only "$BASE_SHA" "$HEAD_SHA")
fi

MAP_JSON=$(yq -o=json '.components | map({id: .id, path: .path, type: .type, chart: .chart, port: .port})' "${COMP_FILE}")

FILTERED=$(echo "${MAP_JSON}" | jq --argfiles files <(printf '%s\n' "${CHANGED_FILES}" | jq -R . | jq -s .) '
  map(select( any($files[]; startswith(.path)) ))
')

echo "components=$(echo "${FILTERED}" | jq -c .)" >> "$GITHUB_OUTPUT"
echo "ids=$(echo "${FILTERED}" | jq -c 'map(.id)')" >> "$GITHUB_OUTPUT"
