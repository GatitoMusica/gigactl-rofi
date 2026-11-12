#!/usr/bin/env bash

: "${PROJECT_ROOT:?PROJECT_ROOT must be defined before sourcing common.sh}"

ROFI_THEME="${GIGACTL_ROFI_THEME:-$PROJECT_ROOT/src/themes/tokyo-midnight.rasi}"
ROFI_LINES="${GIGACTL_ROFI_LINES:-8}"

menu_select() {
    local prompt="${1:?A menu prompt is required}"
    local message="${2:-}"
    shift 2

    local selection
    local status

    if ! command -v rofi >/dev/null 2>&1; then
        printf 'Error: Rofi is not installed or not in PATH.\n' >&2
        return 127
    fi

    selection=$(
        printf '%s\n' "$@" |
            rofi -dmenu \
                -no-custom \
                -mesg "<b>${prompt}</b>\n${message}" \
                -l "$ROFI_LINES" \
                -window-title "GigaControl" \
                -theme "$ROFI_THEME"
    )
    status=$?

    if (( status != 0 )); then
        return "$status"
    fi

    printf '%s\n' "$selection"
}

show_notice() {
    local message="${1:?A notice message is required}"

    rofi \
        -theme "$ROFI_THEME" \
        -window-title "GigaControl" \
        -e "$message"
}
