#!/usr/bin/env bash

# Copyright (C) 2026 Leif Davisson
# Licensed under the GNU Affero General Public License v3.0
# Network Utilities for GreyNoise Proxmox Plugin

set -Eeuo pipefail

allocate_ip() {
  local subnet=$1
  local gateway=$2
  local start_host=${3:-20}
  local end_host=${4:-250}

  IFS='/' read -r base cidr <<< "$subnet"
  IFS='.' read -r o1 o2 o3 o4 <<< "$base"
  local prefix="$o1.$o2.$o3"

  for i in $(seq "$start_host" "$end_host"); do
    local ip="${prefix}.${i}"

    # Skip gateway
    [[ "$ip" == "$gateway" ]] && continue

    # Ping check
    if ping -c 1 -W 1 "$ip" &>/dev/null; then
      continue
    fi

    # ARP check
    if ip neigh show | grep -w "$ip" | grep -qE "REACHABLE|DELAY|STALE|PROBE"; then
      continue
    fi

    echo "$ip"
    return 0
  done

  return 1
}

init_network() {
  # This function can be used to validate or set globals if needed
  local subnet=$1
  if [[ ! "$subnet" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
    msg_error "Invalid subnet format: $subnet"
    return 1
  fi
}
