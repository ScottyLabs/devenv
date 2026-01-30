#!/usr/bin/env bash
set -euo pipefail

TEAM="$1"
BAO_ADDR="$2"

if [ -z "$BAO_TOKEN" ]; then
  export BAO_ADDR="$BAO_ADDR"
  echo "Authenticating to OpenBao..."
  BAO_TOKEN=$(bao login -method=oidc -token-only 2>/dev/null) || true

  if [ -z "$BAO_TOKEN" ]; then
    echo "Warning: OpenBao authentication failed. Secrets not loaded."
    exit 0
  fi

  export BAO_TOKEN
  echo "Loading secrets for team: $TEAM"
  eval $(bao kv get -format=json "secret/$TEAM/dev/env" 2>/dev/null | jq -r '.data.data | to_entries[] | "export \(.key)=\"\(.value)\""')
fi
