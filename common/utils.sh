#!/usr/bin/env bash
set -euo pipefail

[[ "${BASH_SOURCE[0]}" != "$0" ]] || {
    echo "This file must be sourced, not executed"
    exit 1
}

UTIL_RED='\033[31m'
UTIL_GREEN='\033[32m'
UTIL_BLUE='\033[34m'
UTIL_NC='\033[0m'

readonly UTIL_RED UTIL_GREEN UTIL_BLUE UTIL_NC

util::log() {
    local msg="${1:-}"
    local color="${2:-$UTIL_BLUE}"

    [[ -z "$msg" ]] && { printf '\n'; return; }
    printf '%b>>> %s%b\n' "$color" "$msg" "$UTIL_NC"
}

util::confirm() {
    local prompt="${1:-Are you sure? [y/N]: }"
    local choice

    read -r -n 1 -p "$prompt" choice
    printf '\n'

    [[ "$choice" =~ ^[yY]$ ]]
}

util::switchToDir() {
    local target="${1:-}"

    [[ -z "$target" ]] && {
        util::log "util::switchToDir requires an argument" "$UTIL_RED"
        return 1
    }

    if [[ "$target" == "root" ]]; then
        : "${ROOT_DIR:?ROOT_DIR not set}"
        util::log "switching to root directory..."
        cd "$ROOT_DIR" || return 1
    else
        util::log "switching to '$target' directory..."
        cd "$target" || return 1
    fi

    util::log "current directory: $PWD"
}
