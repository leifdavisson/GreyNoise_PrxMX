#!/usr/bin/env bash

# Copyright (C) 2026 Leif Davisson
# Licensed under the GNU Affero General Public License v3.0
# Cloud-Init Utilities for GreyNoise Proxmox Plugin

set -Eeuo pipefail

apply_cloudinit() {
  local vmid=$1
  local ip=$2
  local cidr=$3
  local gateway=$4
  local user=$5
  local ssh_key_path=$6
  local storage=$7

  msg_info "Configuring Cloud-Init for VM $vmid"
  
  # Create a basic user-data snippet for packages and SSH keys
  local userdata
  userdata=$(mktemp)
  cat > "$userdata" <<EOF
#cloud-config
users:
  - name: $user
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - $(cat "$ssh_key_path")
package_update: true
packages:
  - qemu-guest-agent
  - curl
runcmd:
  - systemctl enable --now qemu-guest-agent
EOF

  mkdir -p /var/lib/vz/snippets >&2
  local snippet_name="gn-sensor-${vmid}.yaml"
  mv "$userdata" "/var/lib/vz/snippets/$snippet_name" >&2

  qm set "$vmid" \
    --ide2 "$storage:cloudinit" \
    --ipconfig0 "ip=${ip}/${cidr},gw=$gateway" \
    --cicustom "user=local:snippets/$snippet_name" >&2
  
  msg_ok "Cloud-Init configured"
}

wait_for_ssh() {
  local ip=$1
  local user=$2
  msg_info "Waiting for SSH connection at $ip"
  local count=0
  local max_retries=60
  until ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$user@$ip" "echo ok" &>/dev/null; do
    sleep 5
    count=$((count + 1))
    if [ $count -ge $max_retries ]; then
      msg_error "SSH timeout after 5 minutes"
      return 1
    fi
  done
  msg_ok "SSH connection established"
}
