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
  
  # Execute the bootstrap script on the guest via SSH
  ssh -o StrictHostKeyChecking=no "$user@$ip" <<EOF
export GREYNOISE_API_KEY="$api_key"
curl -H "key: \${GREYNOISE_API_KEY}" -L \
"https://api.greynoise.io/v1/workspaces/$workspace_id/sensors/bootstrap/script" \
| sudo bash -s -- -k \${GREYNOISE_API_KEY}
EOF

  msg_ok "GreyNoise Sensor installation triggered"
}
