
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

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

        // Background
        Rectangle {
            anchors.fill: parent
            color: "#1a1b26"
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
                    color: "#bb9af7"
                    font.pixelSize: 23
                    font.bold: true
                }

                Text {
                    text: "GIGABYTE G5 KF · SYSTEM CONTROL"
                    color: "#7982a9"
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
                               ? "#292e42"
                               : "transparent"

                        border.width: root.currentSection === index
                                      ? 1 : 0

                        border.color: "#414868"

                        Text {
                            anchors.centerIn: parent

                            text: modelData

                            color: root.currentSection === index
                                   ? "#7aa2f7"
                                   : "#a9b1d6"

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
                            color: "#7aa2f7"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            text: "Monitor and manage your cooling system."
                            color: "#7982a9"
                            font.pixelSize: 11
                        }

                        Text {
                            text: "CPU Temperature: — °C"
                            color: "#bb9af7"
                            font.pixelSize: 15
                        }

                        Text {
                            text: "GPU Temperature: — °C"
                            color: "#bb9af7"
                            font.pixelSize: 15
                        }

                        Text {
                            text: "CPU Fan: — RPM"
                            color: "#c0caf5"
                        }

                        Text {
                            text: "GPU Fan: — RPM"
                            color: "#c0caf5"
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
                            color: "#7aa2f7"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            text: "Manage your keyboard backlight."
                            color: "#7982a9"
                            font.pixelSize: 11
                        }

                        Text {
                            text: "Keyboard controls will appear here."
                            color: "#c0caf5"
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
                            color: "#7aa2f7"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            text: "Application preferences."
                            color: "#7982a9"
                            font.pixelSize: 11
                        }

                        Text {
                            text: "Appearance"
                            color: "#c0caf5"
                        }

                        Text {
                            text: "Monitoring"
                            color: "#c0caf5"
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
            }

            // Footer
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#343a55"
            }

            Text {
                Layout.fillWidth: true

                text: "GIGACONTROL · DEVELOPMENT BUILD"
                color: "#565f89"
                font.pixelSize: 9
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
