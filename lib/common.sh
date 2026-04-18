#!/usr/bin/env bash

# UI Helpers for GreyNoise Proxmox Plugin
# Copyright (C) 2026 Leif Davisson
# Licensed under the GNU Affero General Public License v3.0

set -Eeuo pipefail

# Colors
color() {
  YW=$(echo "\033[33m")
  BL=$(echo "\033[36m")
  RD=$(echo "\033[01;31m")
  BGN=$(echo "\033[4;92m")
  GN=$(echo "\033[1;92m")
  DGN=$(echo "\033[32m")
  CL=$(echo "\033[m")
  CM="${GN}✓${CL}"
  CROSS="${RD}✗${CL}"
  BFR="\\r\\033[K"
  HOLD=" "
}

# Error Handling
catch_errors() {
  set -Eeuo pipefail
  trap 'error_handler $LINENO "$BASH_COMMAND"' ERR
}

error_handler() {
  local exit_code="$?"
  if [ -n "${SPINNER_PID:-}" ] && ps -p "$SPINNER_PID" > /dev/null; then kill "$SPINNER_PID" > /dev/null; fi
  printf "\e[?25h" >&2
  local line_number="$1"
  local command="$2"
  local error_message="${RD}[ERROR]${CL} in line ${RD}$line_number${CL}: exit code ${RD}$exit_code${CL}: while executing command ${YW}$command${CL}"
  echo -e "\n$error_message\n" >&2
}

# Spinner
spinner() {
  local chars="/-\|"
  local spin_i=0
  printf "\e[?25l" >&2
  while true; do
    printf "\r \e[36m%s\e[0m" "${chars:spin_i++%${#chars}:1}" >&2
    sleep 0.1
  done
}

# Messages
msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}   " >&2
  spinner &
  SPINNER_PID=$!
}

msg_ok() {
  if [ -n "${SPINNER_PID:-}" ] && ps -p "$SPINNER_PID" > /dev/null; then kill "$SPINNER_PID" > /dev/null; fi
  printf "\e[?25h" >&2
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}" >&2
}

msg_error() {
  if [ -n "${SPINNER_PID:-}" ] && ps -p "$SPINNER_PID" > /dev/null; then kill "$SPINNER_PID" > /dev/null; fi
  printf "\e[?25h" >&2
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}" >&2
}

# Silent Spinner Stopper
stop_spinner() {
  if [ -n "${SPINNER_PID:-}" ] && ps -p "$SPINNER_PID" > /dev/null; then kill "$SPINNER_PID" > /dev/null; fi
  printf "\e[?25h" >&2
}

# Environment Checks
shell_check() {
  if [[ "$(basename "$SHELL")" != "bash" ]]; then
    msg_error "Your default shell is currently not set to Bash. To use these scripts, please switch to the Bash shell."
    exit 1
  fi
}

root_check() {
  if [[ "$(id -u)" -ne 0 ]]; then
    msg_error "Please run this script as root."
    exit 1
  fi
}

pve_check() {
  if ! pveversion &>/dev/null; then
    msg_error "Proxmox Virtual Environment not detected."
    exit 1
  fi
}
