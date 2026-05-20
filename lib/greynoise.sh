#!/usr/bin/env bash

# Copyright (C) 2026 Leif Davisson
# Licensed under the GNU Affero General Public License v3.0
# GreyNoise Sensor Logic for GreyNoise Proxmox Plugin

set -Eeuo pipefail

install_greynoise() {
  local ip=$1
  local user=$2
  local api_key=$3
  local workspace_id=$4

  msg_info "Installing GreyNoise Sensor on $ip"
  
  local api_key_b64
  local workspace_id_b64
  api_key_b64=$(printf '%s' "$api_key" | base64 -w0)
  workspace_id_b64=$(printf '%s' "$workspace_id" | base64 -w0)

  # Execute the bootstrap script on the guest via SSH
  # Base64 encode variables to prevent command injection when interpolating into the heredoc
  ssh -o StrictHostKeyChecking=no "$user@$ip" <<EOF
export GREYNOISE_API_KEY="\$(echo "$api_key_b64" | base64 -d)"
WORKSPACE_ID="\$(echo "$workspace_id_b64" | base64 -d)"
curl -H "key: \${GREYNOISE_API_KEY}" -L \
"https://api.greynoise.io/v1/workspaces/\${WORKSPACE_ID}/sensors/bootstrap/script" \
| sudo bash -s -- -k "\${GREYNOISE_API_KEY}"
EOF

  msg_ok "GreyNoise Sensor installation triggered"
}
