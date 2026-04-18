#!/usr/bin/env bash

# Storage Discovery for GreyNoise Proxmox Plugin
# Copyright (C) 2026 Leif Davisson
# Licensed under the GNU Affero General Public License v3.0

set -Eeuo pipefail

get_storage_list() {
  # Get storage status
  # Filters for active storage that supports images
  # Format: "ID Size(GB) Type"
  
  pvesm status --content images | awk '
    NR > 1 && $3 == "active" {
      # Proxmox outputs space in KiB by default
      size_gb = int($6 / 1024 / 1024)
      print $1 "\t" size_gb "GB free (" $2 ")"
    }' | sort -k2 -hr | while IFS=$'\t' read -r id desc; do
    echo "$id"
    echo "$desc"
  done
}
