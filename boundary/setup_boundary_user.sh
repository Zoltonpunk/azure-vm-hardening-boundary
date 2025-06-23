#!/usr/bin/env bash
# setup_boundary_user.sh
# Creates a password-based auth method and demo user in Boundary

set -euo pipefail

BOUNDARY_ADDR="http://127.0.0.1:9200"
export BOUNDARY_ADDR

# Create password auth method if not exists
AUTH_ID=$(boundary auth-methods list -format json | jq -r '.items[] | select(.type=="password") | .id') || true

if [ -z "$AUTH_ID" ]; then
  AUTH_ID=$(boundary auth-methods create password \
    -name "PasswordAuth" \
    -description "Local user auth" \
    -format json | jq -r '.item.id')
  echo "[INFO] Created password auth method: $AUTH_ID"
else
  echo "[INFO] Password auth method already exists: $AUTH_ID"
fi

# Create user
USER_ID=$(boundary users create \
  -name "demo-user" \
  -description "Demo user with password auth" \
  -auth-method-id "$AUTH_ID" \
  -format json | jq -r '.item.id')

# Set password account
boundary accounts create password \
  -login-name "demo" \
  -password "demo123" \
  -auth-method-id "$AUTH_ID" \
  -user-id "$USER_ID"

echo "[INFO] Boundary user 'demo-user' created with login 'demo'"