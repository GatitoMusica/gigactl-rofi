#!/usr/bin/env bash

keyboard_menu() {
    local choice
    local status

    while true; do
        if choice=$(menu_select \
            "RGB Keyboard" \
            "Keyboard backlight · Preview only · No hardware changes" \
            "Keyboard ON" \
            "Keyboard OFF" \
            "Brightness" \
            "Preset colors" \
            "Custom RGB color" \
            "Restore saved color" \
            "Back"
        ); then
            case "$choice" in
                "Keyboard ON"|"Keyboard OFF")
                    show_notice $'Keyboard power control is not connected yet.\n\nNo hardware command was executed.'
                    ;;
                "Brightness")
                    show_notice $'Brightness control is planned.\n\nNo brightness value was changed.'
                    ;;
                "Preset colors")
                    show_notice $'Color presets are not connected yet.\n\nThis section will eventually use gkbd.\n\nNo keyboard color was changed.'
                    ;;
                "Custom RGB color")
                    show_notice $'Custom RGB input is planned.\n\nNo keyboard color was changed.'
                    ;;
                "Restore saved color")
                    show_notice $'Saved color restoration is not connected yet.\n\nNo keyboard color was changed.'
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
