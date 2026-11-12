#!/usr/bin/env bash

cooling_menu() {
    local choice
    local status

    while true; do
        if choice=$(menu_select \
            "Cooling" \
            "Fan controls · Preview only · No hardware changes" \
            "Monitor fan status" \
            "Restore automatic mode" \
            "Silent profile" \
            "Balanced profile" \
            "Performance profile" \
            "Manual control" \
            "Back"
        ); then
            case "$choice" in
                "Monitor fan status")
                    show_notice $'Not implemented yet.\n\nThis option will eventually use gfan to display temperatures, fan duty and RPM.\n\nNo hardware command was executed.'
                    ;;
                "Restore automatic mode")
                    show_notice $'Not connected yet.\n\nThis option will eventually restore firmware automatic fan control.\n\nNo hardware command was executed.'
                    ;;
                "Silent profile"|"Balanced profile"|"Performance profile")
                    show_notice $'Fan profiles are planned for a later version.\n\nNo fan speed was changed.'
                    ;;
                "Manual control")
                    show_notice $'Manual fan control is not connected yet.\n\nNo fan speed was changed.'
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
