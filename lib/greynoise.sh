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
  
  # Base64 encode variables to prevent command injection during SSH heredoc execution
  local b64_api_key
  b64_api_key=$(printf '%s' "$api_key" | base64 -w 0)

  local b64_workspace_id
  b64_workspace_id=$(printf '%s' "$workspace_id" | base64 -w 0)

  # Execute the bootstrap script on the guest via SSH
  ssh -o StrictHostKeyChecking=no "$user@$ip" <<INNER_EOF
export GREYNOISE_API_KEY="\$(echo "${b64_api_key}" | base64 -d)"
WORKSPACE_ID="\$(echo "${b64_workspace_id}" | base64 -d)"
curl -H "key: \${GREYNOISE_API_KEY}" -L \
"https://api.greynoise.io/v1/workspaces/\${WORKSPACE_ID}/sensors/bootstrap/script" \
| sudo bash -s -- -k "\${GREYNOISE_API_KEY}"
INNER_EOF

  msg_ok "GreyNoise Sensor installation triggered"
}
