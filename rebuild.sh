#!/usr/bin/env bash
set -euo pipefail

# Script directory is repository root
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Get current system hostname
CURRENT_HOSTNAME="$(hostname -s 2>/dev/null || cat /etc/hostname 2>/dev/null || uname -n)"

# Check and resolve host configuration directory
HOST_DIR=""
HOST_CONFIG_NAME=""

if [[ -d "${SCRIPT_DIR}/modules/hosts/${CURRENT_HOSTNAME}" ]]; then
  HOST_DIR="${SCRIPT_DIR}/modules/hosts/${CURRENT_HOSTNAME}"
  HOST_CONFIG_NAME="${CURRENT_HOSTNAME}"
else
  # Case-insensitive search fallback
  for dir in "${SCRIPT_DIR}/modules/hosts"/*; do
    if [[ -d "$dir" ]] && [[ "${dir##*/}" =~ ^${CURRENT_HOSTNAME}$ ]]; then
      HOST_DIR="$dir"
      HOST_CONFIG_NAME="${dir##*/}"
      break
    fi
  done
fi

show_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Rebuild and manage NixOS configuration using nh for the current host.

Host: ${CURRENT_HOSTNAME}
Flake Directory: ${SCRIPT_DIR}

Options:
  (no options)          Rebuild and switch to the new NixOS generation (default)
  -u, --update          Update flake inputs and rebuild (nh os switch --update)
  -l, --list            List all NixOS generations
  -g, --garbage,        Clean up old generations, keeping only the latest 1 generation
      --garbarge
  -h, --help            Show this help message
EOF
}

validate_host() {
  if [[ -z "$HOST_DIR" || ! -d "$HOST_DIR" ]]; then
    echo "Error: Host configuration for '${CURRENT_HOSTNAME}' not found in '${SCRIPT_DIR}/modules/hosts/'" >&2
    echo "Available hosts:" >&2
    for d in "${SCRIPT_DIR}/modules/hosts"/*; do
      if [[ -d "$d" ]]; then
        echo "  - $(basename "$d")" >&2
      fi
    done
    exit 1
  fi
}

run_rebuild() {
  local update_flag="$1"
  validate_host
  echo "==> Rebuilding NixOS configuration for host '${HOST_CONFIG_NAME}'..."
  if [[ "$update_flag" == "true" ]]; then
    nh os switch "${SCRIPT_DIR}" -H "${HOST_CONFIG_NAME}" --update
  else
    nh os switch "${SCRIPT_DIR}" -H "${HOST_CONFIG_NAME}"
  fi
}

run_list() {
  echo "==> Listing NixOS generations:"
  nixos-rebuild list-generations
}

run_garbage_collection() {
  echo "==> Running garbage collection (keeping last 1 generation)..."
  if command -v nh &>/dev/null; then
    nh clean all --keep 1
  else
    sudo nix-env --delete-generations +1 -p /nix/var/nix/profiles/system
    sudo nix-collect-garbage
  fi
}

# Parse command-line arguments
if [[ $# -eq 0 ]]; then
  run_rebuild "false"
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--update)
      run_rebuild "true"
      shift
      ;;
    -l|--list)
      run_list
      shift
      ;;
    -g|--garbage|--garbarge)
      run_garbage_collection
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Error: Unknown option '$1'" >&2
      show_help
      exit 1
      ;;
  esac
done
