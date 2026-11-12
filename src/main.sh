#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

export PROJECT_ROOT

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/modules/cooling.sh"
source "$SCRIPT_DIR/modules/keyboard.sh"
source "$SCRIPT_DIR/modules/settings.sh"

if ! command -v rofi >/dev/null 2>&1; then
    printf 'Error: Rofi is required but was not found in PATH.\n' >&2
    exit 127
fi

if [[ ! -r "$ROFI_THEME" ]]; then
    printf 'Error: Rofi theme not found or not readable: %s\n' "$ROFI_THEME" >&2
    exit 1
fi

main_menu() {
    local choice
    local status

    while true; do
        if choice=$(menu_select \
            "GigaControl" \
            "GIGABYTE G5 KF · System control" \
            "Cooling" \
            "RGB Keyboard" \
            "Settings" \
            "Exit"
        ); then
            case "$choice" in
                "Cooling")
                    cooling_menu
                    status=$?
                    (( status == 0 )) || return "$status"
                    ;;
                "RGB Keyboard")
                    keyboard_menu
                    status=$?
                    (( status == 0 )) || return "$status"
                    ;;
                "Settings")
                    settings_menu
                    status=$?
                    (( status == 0 )) || return "$status"
                    ;;
                "Exit")
                    return 0
                    ;;
                *)
                    show_notice "Unknown menu option."
                    ;;
            esac
        else
            status=$?

            # Escape from the main menu exits the application.
            if (( status == 1 )); then
                return 0
            fi

            return "$status"
        fi
    done
}

main_menu
