#!/usr/bin/env bash
set -euo pipefail

TEAM="$1"
BAO_ADDR="$2"

if [ -z "${BAO_TOKEN:-}" ]; then
  export BAO_ADDR="$BAO_ADDR"
  echo "Authenticating to OpenBao..." >&2
  BAO_TOKEN=$(bao login -method=oidc -token-only 2>/dev/null) || true

  if [ -z "${BAO_TOKEN:-}" ]; then
    echo "Warning: OpenBao authentication failed. Secrets not loaded." >&2
    exit 0
  fi

  echo "Loading secrets for team: $TEAM" >&2
  # shellcheck disable=SC2046
  bao kv get -format=json "secret/$TEAM/dev/env" 2>/dev/null | jq -r '.data.data | to_entries[] | "\(.key)=\"\(.value)\""' > .env
  echo "Secrets written to .env" >&2
fi
