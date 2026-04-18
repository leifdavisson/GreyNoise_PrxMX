#!/usr/bin/env bash

# Copyright (C) 2026 Leif Davisson
# Licensed under the GNU Affero General Public License v3.0
# VM Management for GreyNoise Proxmox Plugin

set -Eeuo pipefail

create_vm() {
  local name=$1
  local memory=$2
  local cores=$3
  local bridge=$4
  local vlan=$5
  local storage=$6
  local image_path=$7

  local vmid
  vmid=$(pvesh get /cluster/nextid)

  local NET0_OPTS="virtio,bridge=$bridge"
  if [[ "$vlan" -gt 0 ]]; then
    NET0_OPTS+=",tag=$vlan"
  fi

  msg_info "Creating VM $vmid ($name)"
  qm create "$vmid" \
    --name "$name" \
    --memory "$memory" \
    --cores "$cores" \
    --net0 "$NET0_OPTS" \
    --onboot 1 >&2
  msg_ok "VM $vmid created"

  msg_info "Importing disk to $storage"
  qm importdisk "$vmid" "$image_path" "$storage" >&2
  
  # Dynamically find the imported volume ID (supports LVM, ZFS, directory, etc.)
  local DISK_ID
  DISK_ID=$(qm config "$vmid" | grep "^unused" | awk '{print $2}' | head -n 1)
  
  if [[ -z "$DISK_ID" ]]; then
    msg_error "Imported disk not found in VM configuration."
    exit 1
  fi

  qm set "$vmid" \
    --scsihw virtio-scsi-pci \
    --scsi0 "$DISK_ID" \
    --boot order=scsi0 >&2
  msg_ok "Disk imported and configured"

  echo "$vmid"
}

start_vm() {
  local vmid=$1
  msg_info "Starting VM $vmid"
  qm start "$vmid" >&2
  msg_ok "VM $vmid started"
}

download_image() {
  local url=$1
  local path=$2
  if [[ ! -f "$path" ]]; then
    msg_info "Downloading cloud image"
    wget -q -O "$path" "$url" >&2
    msg_ok "Image downloaded"
  fi
}
