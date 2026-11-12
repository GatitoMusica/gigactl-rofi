import QtQuick
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    // Widget identity
    Plasmoid.title: "GigaControl"
    Plasmoid.icon: "utilities-system-monitor"

    // Tooltip
    toolTipMainText: "GigaControl"
    toolTipSubText: "Fan monitoring and RGB keyboard controls"

    // Initial popup representation
    fullRepresentation: Item {
        implicitWidth: 320
        implicitHeight: 160

        Text {
            anchors.centerIn: parent

            text: "GigaControl"
            color: "#bb9af7"

            font.pixelSize: 22
            font.bold: true
        }
    }
}
