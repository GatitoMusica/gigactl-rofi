#!/usr/bin/env bash

settings_menu() {
    local choice
    local status

    while true; do
        if choice=$(menu_select \
            "Settings" \
            "Application preferences · Preview only" \
            "Appearance" \
            "Startup behavior" \
            "Back"
        ); then
            case "$choice" in
                "Appearance")
                    show_notice $'Appearance settings are planned.\n\nThe initial theme is Tokyo Midnight.'
                    ;;
                "Startup behavior")
                    show_notice $'Startup behavior settings are planned.\n\nThe application does not currently register any autostart entry.'
                    ;;
                "Back")
                    return 0
                    ;;
                *)
                    show_notice "Unknown menu option."
                    ;;
            esac
        else
            status=$?

            # Escape in a submenu returns to the main menu.
            if (( status == 1 )); then
                return 0
            fi

            return "$status"
        fi
    done
}
