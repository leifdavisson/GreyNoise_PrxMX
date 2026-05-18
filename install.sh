#!/usr/bin/env bash

# GreyNoise Proxmox Plugin Installer
# Support: https://github.com/leifdavisson/GreyNoise_PrxMX
#
# Copyright (C) 2026 Leif Davisson
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Source Libraries
DIR=$(dirname "$(readlink -f "$0")")
source "$DIR/lib/common.sh"
source "$DIR/lib/network.sh"
source "$DIR/lib/vm.sh"
source "$DIR/lib/cloudinit.sh"
source "$DIR/lib/greynoise.sh"
source "$DIR/lib/storage.sh"

# Initialization
color
catch_errors
shell_check
root_check
pve_check

# Header Info
function header_info {
  clear
  cat <<"EOF"
  ____                      _   _       _         
 / ___|_ __ ___ _   _      | \ | | ___ (_)___  ___ 
| |  _| '__/ _ \ | | |_____|  \| |/ _ \| / __|/ _ \
| |_| | | |  __/ |_| |_____| |\  | (_) | \__ \  __/
 \____|_|  \___|\__, |     |_| \_|\___/|_|___/\___|
                |___/                              
                   PROXMOX PLUGIN
EOF
}

# Load Defaults
source "$DIR/config/defaults.conf"

header_info
echo -e "\nLoading GreyNoise Installer..."

# Whiptail TUI
if ! whiptail --title "GreyNoise Proxmox Plugin" --yesno "This script will create a GreyNoise sensor VM on your Proxmox host. Proceed?" 10 60; then
  msg_error "Installation cancelled by user."
  exit 0
fi

# API Key
GN_API_KEY=$(whiptail --passwordbox "Enter your GreyNoise API Key:" 10 60 3>&1 1>&2 2>&3 | xargs)
if [[ -z "$GN_API_KEY" ]]; then msg_error "API Key is required."; exit 1; fi

# Workspace ID
GN_WORKSPACE=$(whiptail --inputbox "Enter your GreyNoise Workspace ID:" 10 60 3>&1 1>&2 2>&3 | xargs)
if [[ -z "$GN_WORKSPACE" ]]; then msg_error "Workspace ID is required."; exit 1; fi

# VM Settings
VM_NAME=$(whiptail --inputbox "Enter VM Name:" 10 60 "$VM_NAME" 3>&1 1>&2 2>&3 | xargs)
if [[ ! "$VM_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then msg_error "Invalid VM Name. Only alphanumeric characters, dashes, and underscores are allowed."; exit 1; fi

# Storage Selection
msg_info "Discovering available storage..."
mapfile -t STORAGE_ARRAY < <(get_storage_list)
stop_spinner
if [[ ${#STORAGE_ARRAY[@]} -eq 0 ]]; then
  msg_error "No active storage found for VM images."
  exit 1
fi
STORAGE=$(whiptail --title "Storage Selection" --menu "Select storage for VM disk (Sorted by free space):" 15 60 5 "${STORAGE_ARRAY[@]}" 3>&1 1>&2 2>&3)
if [[ -z "$STORAGE" ]]; then msg_error "Storage selection is required."; exit 1; fi

VLAN=$(whiptail --inputbox "Enter DMZ VLAN ID (0 for none):" 10 60 "0" 3>&1 1>&2 2>&3 | xargs)
if [[ ! "$VLAN" =~ ^[0-9]+$ ]]; then msg_error "Invalid VLAN ID. Must be a number."; exit 1; fi

# Network Settings
SUBNET=$(whiptail --inputbox "Enter Subnet CIDR (e.g., 192.168.1.0/24):" 10 60 3>&1 1>&2 2>&3 | xargs)
if [[ -z "$SUBNET" ]]; then msg_error "Subnet is required."; exit 1; fi
if [[ ! "$SUBNET" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then msg_error "Invalid Subnet format."; exit 1; fi

GATEWAY=$(whiptail --inputbox "Enter Gateway IP:" 10 60 3>&1 1>&2 2>&3 | xargs)
if [[ -z "$GATEWAY" ]]; then msg_error "Gateway is required."; exit 1; fi
if [[ ! "$GATEWAY" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then msg_error "Invalid Gateway IP format."; exit 1; fi

# IP Allocation Mode
IP_MODE=$(whiptail --title "IP Allocation" --menu "Choose IP range scanning mode:" 15 60 4 \
  "DEFAULT" "Scan standard range (.20 to .250)" \
  "FULL" "Scan entire subnet (.1 to .254)" \
  "CUSTOM" "Define custom host range" 3>&1 1>&2 2>&3)

case "$IP_MODE" in
  DEFAULT)
    S_HOST=20; E_HOST=250 ;;
  FULL)
    S_HOST=1; E_HOST=254 ;;
  CUSTOM)
    S_HOST=$(whiptail --inputbox "Start host octet (e.g., 50):" 10 60 "50" 3>&1 1>&2 2>&3 | xargs)
    if [[ ! "$S_HOST" =~ ^[0-9]+$ ]]; then msg_error "Invalid Start host octet. Must be a number."; exit 1; fi
    E_HOST=$(whiptail --inputbox "End host octet (e.g., 100):" 10 60 "100" 3>&1 1>&2 2>&3 | xargs)
    if [[ ! "$E_HOST" =~ ^[0-9]+$ ]]; then msg_error "Invalid End host octet. Must be a number."; exit 1; fi
    ;;
  *)
    msg_error "Invalid selection."; exit 1 ;;
esac

# Start Implementation
header_info

msg_info "Searching for a free IP in $SUBNET"
HOST_IP=$(allocate_ip "$SUBNET" "$GATEWAY" "$S_HOST" "$E_HOST")
if [[ -z "$HOST_IP" ]]; then
  msg_error "No free IP found in range $S_HOST-$E_HOST of $SUBNET"
  exit 1
fi
msg_ok "Selected IP: $HOST_IP"

# Check for SSH Key
SSH_KEY="${HOME}/.ssh/id_rsa.pub"
if [[ ! -f "$SSH_KEY" ]]; then
  msg_info "Generating SSH key pair"
  ssh-keygen -t rsa -b 4096 -f "${HOME}/.ssh/id_rsa" -N "" &>/dev/null
  msg_ok "SSH key generated"
fi

download_image "$IMAGE_URL" "$IMAGE_PATH"

VMID=$(create_vm "$VM_NAME" "$MEMORY" "$CORES" "$BRIDGE" "$VLAN" "$STORAGE" "$IMAGE_PATH")

apply_cloudinit "$VMID" "$HOST_IP" "$(echo "$SUBNET" | cut -d/ -f2)" "$GATEWAY" "$SSH_USER" "$SSH_KEY" "$STORAGE"

start_vm "$VMID"

wait_for_ssh "$HOST_IP" "$SSH_USER"

install_greynoise "$HOST_IP" "$SSH_USER" "$GN_API_KEY" "$GN_WORKSPACE"

header_info
echo -e "\n${GN}=== INSTALLATION COMPLETE ===${CL}"
echo -e "VMID: ${BL}$VMID${CL}"
echo -e "IP Address: ${BL}$HOST_IP${CL}"
echo -e "SSH User: ${BL}$SSH_USER${CL}"
echo -e "\nYour GreyNoise sensor is now booting and will register shortly."
echo -e "Check your workspace dashboard at: https://visualizer.greynoise.io/"
echo -e "=============================="
