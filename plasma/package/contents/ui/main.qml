import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property int currentSection: 0

    // Widget identity
    Plasmoid.title: "GigaControl"
    Plasmoid.icon: "utilities-system-monitor"

    // Tooltip
    toolTipMainText: "GigaControl"
    toolTipSubText: "Fan monitoring and RGB keyboard controls"

    // Main popup
    fullRepresentation: Item {
        Layout.minimumWidth: 360
        Layout.minimumHeight: 400
        Layout.preferredWidth: 390
        Layout.preferredHeight: 430

        // Inherit the active KDE window color scheme
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false

        // Background
        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor
            radius: 12
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            // Header
            ColumnLayout {
                spacing: 3

                Text {
                    text: "GigaControl"
                    color: Kirigami.Theme.textColor
                    font.pixelSize: 23
                    font.bold: true
                }

                Text {
                    text: "GIGABYTE G5 KF · SYSTEM CONTROL"
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: 9
                }
            }

            // Navigation
            RowLayout {
                spacing: 6

                Repeater {
                    model: ["Cooling", "RGB Keyboard", "Settings"]

                    delegate: Rectangle {
                        required property int index
                        required property string modelData

                        Layout.fillWidth: true
                        implicitHeight: 36

                        radius: 7

                        color: root.currentSection === index
                               ? Kirigami.Theme.highlightColor
                               : "transparent"

                        border.width: root.currentSection === index
                                      ? 1 : 0

                        border.color: Kirigami.Theme.focusColor

                        Text {
                            anchors.centerIn: parent

                            text: modelData

                            color: root.currentSection === index
                                   ? Kirigami.Theme.highlightedTextColor
                                   : Kirigami.Theme.textColor

                            font.pixelSize: 10
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.currentSection = index
                            }
                        }
                    }
                }
            }

            // Section content
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                currentIndex: root.currentSection

                // Cooling
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Text {
                            text: "Cooling"
                            color: Kirigami.Theme.textColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            text: "Monitor and manage your cooling system."
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: 11
                        }

                        Text {
                            text: "CPU Temperature: — °C"
                            color: Kirigami.Theme.textColor
                            font.pixelSize: 15
                        }

                        Text {
                            text: "GPU Temperature: — °C"
                            color: Kirigami.Theme.textColor
                            font.pixelSize: 15
                        }

                        Text {
                            text: "CPU Fan: — RPM"
                            color: Kirigami.Theme.textColor
                        }

                        Text {
                            text: "GPU Fan: — RPM"
                            color: Kirigami.Theme.textColor
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }

                // RGB Keyboard
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Text {
                            text: "RGB Keyboard"
                            color: Kirigami.Theme.textColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            text: "Manage your keyboard backlight."
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: 11
                        }

                        Text {
                            text: "Keyboard controls will appear here."
                            color: Kirigami.Theme.textColor
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }

                // Settings
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Text {
                            text: "Settings"
                            color: Kirigami.Theme.textColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            text: "Application preferences."
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: 11
                        }

                        Text {
                            text: "Appearance"
                            color: Kirigami.Theme.textColor
                        }

                        Text {
                            text: "Monitoring"
                            color: Kirigami.Theme.textColor
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
            }

            // Footer separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Kirigami.Theme.alternateBackgroundColor
            }

            // Footer
            Text {
                Layout.fillWidth: true

                text: "GIGACONTROL · DEVELOPMENT BUILD"
                color: Kirigami.Theme.disabledTextColor
                font.pixelSize: 9
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
