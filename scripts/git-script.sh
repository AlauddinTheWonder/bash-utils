#!/usr/bin/env bash
set -euo pipefail

UTIL_RED='\033[31m'
UTIL_GREEN='\033[32m'
UTIL_BLUE='\033[34m'
UTIL_NC='\033[0m'

readonly UTIL_RED UTIL_GREEN UTIL_BLUE UTIL_NC

log() {
    local msg="${1:-}"
    local color="${2:-$UTIL_BLUE}"
    local with_prefix="${3:-true}"

    [[ -z "$msg" ]] && { printf '\n'; return; }

    if [[ "$with_prefix" == "false" ]]; then
        printf '%b%s%b\n' "$color" "$msg" "$UTIL_NC"
    else
        printf '%b>>> %s%b\n' "$color" "$msg" "$UTIL_NC"
    fi
}

confirm() {
    local prompt="${1:-Are you sure? [y/N]: }"
    local choice

    read -r -n 1 -p "$prompt" choice
    printf '\n'

    [[ "$choice" =~ ^[yY]$ ]]
}


# ----------------------------------------------------------------------
# Pull latest changes for multiple git repositories
# ----------------------------------------------------------------------
# Usage:
#   git::pullAll <dir_prefix> [--interactive]
# ----------------------------------------------------------------------

git::pullAll() {
    local prefix="${1:-}"
    local interactive="${2:-}"
    local base_dir="$PWD"

    # if [[ -z "$prefix" ]]; then
    #     log "Usage: git::pullAll <dir_prefix> [--interactive]" "$UTIL_RED"
    #     return 1
    # fi

    log "Scanning '$base_dir' for directories starting with '$prefix*'"

    for dir in "$base_dir"/"$prefix"*; do
        [[ -d "$dir" ]] || continue

        if [[ ! -d "$dir/.git" ]]; then
            log "$(basename "$dir") is not a git repository" "$UTIL_RED"
            continue
        fi

        log
        log "Repository: $(basename "$dir")"

        cd "$dir" || {
            log "Failed to enter $dir" "$UTIL_RED"
            continue
        }

        local branch
        branch="$(git rev-parse --abbrev-ref HEAD)"

        log "Branch: $branch" "$UTIL_GREEN"

        if [[ -n "$(git status --porcelain)" ]]; then
            log "Uncommitted changes detected" "$UTIL_RED"
            git status --short

            if [[ "$interactive" == "--interactive" ]] &&
               confirm "Commit changes before pull? [y/N]: "; then

                local commit_msg
                read -r -p "Enter commit message: " commit_msg

                if [[ -z "$commit_msg" ]]; then
                    log "Empty commit message. Skipping repository." "$UTIL_RED"
                    cd "$base_dir"
                    continue
                fi

                git add .
                git commit -m "$commit_msg"
                log "Changes committed" "$UTIL_GREEN"
                log "Pushing changes..."
                git push origin "$branch"
                log "Changes are pushed to remote" "$UTIL_GREEN"
            else
                log "Skipping pull to avoid conflicts" "$UTIL_RED"
                cd "$base_dir"
                continue
            fi
        fi

        log "Pulling latest changes..."
        git pull

        cd "$base_dir" || return 1
    done

    log "Git pull completed" "$UTIL_GREEN"
}

# ----------------------------------------------------------------------
# Show git status for multiple repositories
# ----------------------------------------------------------------------
# Usage:
#   git::statusAll <dir_prefix>
# ----------------------------------------------------------------------

git::statusAll() {
    local base_dir="$PWD"
    local prefix="${1:-}"

    # if [[ -z "$prefix" ]]; then
    #     log "Usage: git::statusAll <dir_prefix>" "$UTIL_RED"
    #     return 1
    # fi

    log "Checking git status in '$base_dir' for '$prefix*' directories"

    for dir in "$base_dir"/"$prefix"*; do
        [[ -d "$dir" ]] || continue

        if [[ ! -d "$dir/.git" ]]; then
            log "$(basename "$dir") is not a git repository" "$UTIL_RED"
            continue
        fi

        log
        log "Repository: $(basename "$dir")"

        cd "$dir" || {
            log "Failed to enter $dir" "$UTIL_RED"
            continue
        }

        local branch
        branch="$(git rev-parse --abbrev-ref HEAD)"

        log "Branch: $branch" "$UTIL_GREEN"

        if [[ -n "$(git status --porcelain)" ]]; then
            git status --short
        else
            log "Working tree clean" "$UTIL_GREEN"
        fi

        cd "$base_dir" || return 1
    done
}

log "----------------------------------------------------------------------" $UTIL_BLUE false
log "Git Script Menu" $UTIL_BLUE false
log "----------------------------------------------------------------------" $UTIL_BLUE false

log "Select an option:"
echo "1) Git Pull"
echo "2) Git Status"
echo

read -n 1 -p "Enter choice (1 or 2): " choice

case "$choice" in
    1) action="pull" ;;
    2) action="status" ;;
    *)
        log "Invalid option selected" "$UTIL_RED"
        exit 1
        ;;
esac

echo
read -r -p "Enter directory prefix (e.g. SIG-): " prefix

[[ -z "$prefix" ]] && {
    prefix="SIG-"
}

echo
read -n 1 -p "Enable interactive mode? [y/N]: " interactive_choice

interactive_flag=""
if [[ "$interactive_choice" =~ ^[yY]$ ]]; then
    interactive_flag="--interactive"
fi

# ----------------------------------------------------------------------
# Execute
# ----------------------------------------------------------------------

case "$action" in
    pull)
        git::pullAll "$prefix" $interactive_flag
        ;;
    status)
        git::statusAll "$prefix"
        ;;
esac
# ----------------------------------------------------------------------