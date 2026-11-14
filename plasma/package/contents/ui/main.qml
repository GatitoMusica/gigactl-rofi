import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.ksvg 1.0 as KSvg
import org.gigactl.hardware 1.0

PlasmoidItem {
    id: root

    // Widget identity
    Plasmoid.title: "GigaControl"
    Plasmoid.icon: "io.github.smairio.gigactl-symbolic"

    readonly property string temperatureUnit:
        Plasmoid.configuration.temperatureUnit || "C"

    readonly property url userGuideUrl:
        Qt.resolvedUrl("../docs/user-guide.md")

    readonly property int monitoringIntervalSeconds: {
        const configured = Number(Plasmoid.configuration.monitoringIntervalSeconds)
        return configured === 5 || configured === 10 ? configured : 2
    }

    readonly property string temperatureUnitSymbol:
        temperatureUnit === "F" ? "°F" : "°C"

    // Tooltip
    toolTipMainText: "GigaControl"
    toolTipSubText: "Fan monitoring and RGB keyboard controls"

    // Hardware access is handled by the native C++ QML module.
    HardwareController {
        id: hardwareController
    }

    // Optional connection to the official gigactl system daemon.
    // Hardware monitoring through gfan remains available independently.
    GigactlDaemonClient {
        id: daemonClient
    }

    readonly property bool telemetryReady:
        daemonClient.available &&
        hardwareController.cpuTemperature >= 0

    readonly property color keyboardColor:
        Qt.rgba(daemonClient.keyboardRed / 255.0,
                daemonClient.keyboardGreen / 255.0,
                daemonClient.keyboardBlue / 255.0,
                1.0)

    function hexByte(value) {
        return value.toString(16).toUpperCase().padStart(2, "0")
    }

    function formatTemperature(celsius) {
        const degrees = temperatureUnit === "F"
            ? Math.round(celsius * 9 / 5 + 32)
            : Math.round(celsius)
        return degrees + " " + temperatureUnitSymbol
    }

    readonly property string keyboardColorHex:
        "#" + hexByte(daemonClient.keyboardRed) +
        hexByte(daemonClient.keyboardGreen) +
        hexByte(daemonClient.keyboardBlue)

    // Poll only while the popup is expanded and gigactld can serve the query.
    Timer {
        id: monitoringTimer

        interval: root.monitoringIntervalSeconds * 1000
        repeat: true
        running: root.expanded && daemonClient.available

        // Take the first reading immediately when the popup opens.
        onRunningChanged: {
            if (running) {
                hardwareController.refresh()
            }
        }

        onTriggered: hardwareController.refresh()
    }

    ColorDialog {
        id: keyboardColorDialog

        title: "Keyboard color"
        selectedColor: root.keyboardColor

        onAccepted: {
            if (!daemonClient.available) {
                return
            }

            daemonClient.setKeyboardColor(
                Math.round(selectedColor.r * 255),
                Math.round(selectedColor.g * 255),
                Math.round(selectedColor.b * 255)
            )
        }
    }

    // Main popup
    fullRepresentation: Item {
        Layout.minimumWidth: 420
        Layout.minimumHeight: 540
        Layout.preferredWidth: 560
        Layout.preferredHeight: 620

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

                PlasmaExtras.Heading {
                    text: "GigaControl"
                    level: 1
                    Layout.fillWidth: true
                }

                Text {
                    text: "GIGABYTE G5 KF · SYSTEM CONTROL"
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: 9
                }
            }

            // Navigation
            PlasmaComponents.TabBar {
                id: navigationBar

                Layout.fillWidth: true

                PlasmaComponents.TabButton {
                    id: coolingTab

                    bottomPadding: 10
                    topPadding: 10
                    text: "Cooling"
                    hoverEnabled: true

                    background: Item {
                        // Preserve Plasma's native TabButton margins
                        property var margins: frameMetrics.margins

                        implicitWidth: frameMetrics.implicitWidth
                        implicitHeight: frameMetrics.implicitHeight

                        KSvg.FrameSvgItem {
                            id: frameMetrics

                            anchors.fill: parent

                            imagePath: "widgets/tabbar"
                            prefix: "north-active-tab"

                            enabledBorders:
                                KSvg.FrameSvgItem.LeftBorder |
                                KSvg.FrameSvgItem.RightBorder |
                                KSvg.FrameSvgItem.TopBorder |
                                KSvg.FrameSvgItem.BottomBorder

                            visible: false
                        }

                        // Hover background
                        Rectangle {
                            anchors.fill: parent
                            radius: 5

                            color: Kirigami.Theme.hoverColor

                            opacity: coolingTab.hovered &&
                                     !coolingTab.checked ? 0.16 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                }
                            }
                        }
                    }
                }

                PlasmaComponents.TabButton {
                    id: keyboardTab

                    bottomPadding: 10
                    topPadding: 10
                    text: "RGB Keyboard"
                    hoverEnabled: true

                    background: Item {
                        property var margins: keyboardFrameMetrics.margins

                        implicitWidth: keyboardFrameMetrics.implicitWidth
                        implicitHeight: keyboardFrameMetrics.implicitHeight

                        KSvg.FrameSvgItem {
                            id: keyboardFrameMetrics

                            anchors.fill: parent

                            imagePath: "widgets/tabbar"
                            prefix: "north-active-tab"

                            enabledBorders:
                                KSvg.FrameSvgItem.LeftBorder |
                                KSvg.FrameSvgItem.RightBorder |
                                KSvg.FrameSvgItem.TopBorder |
                                KSvg.FrameSvgItem.BottomBorder

                            visible: false
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 5

                            color: Kirigami.Theme.hoverColor

                            opacity: keyboardTab.hovered &&
                                     !keyboardTab.checked ? 0.16 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                }
                            }
                        }
                    }
                }

                PlasmaComponents.TabButton {
                    id: settingsTab

                    bottomPadding: 10
                    topPadding: 10
                    text: "Settings"
                    hoverEnabled: true

                    background: Item {
                        property var margins: settingsFrameMetrics.margins

                        implicitWidth: settingsFrameMetrics.implicitWidth
                        implicitHeight: settingsFrameMetrics.implicitHeight

                        KSvg.FrameSvgItem {
                            id: settingsFrameMetrics

                            anchors.fill: parent

                            imagePath: "widgets/tabbar"
                            prefix: "north-active-tab"

                            enabledBorders:
                                KSvg.FrameSvgItem.LeftBorder |
                                KSvg.FrameSvgItem.RightBorder |
                                KSvg.FrameSvgItem.TopBorder |
                                KSvg.FrameSvgItem.BottomBorder

                            visible: false
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 5

                            color: Kirigami.Theme.hoverColor

                            opacity: settingsTab.hovered &&
                                     !settingsTab.checked ? 0.16 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                }
                            }
                        }
                    }
                }
            }

            // Section content
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                currentIndex: navigationBar.currentIndex

                // Cooling
                Item {
                    PlasmaComponents.ScrollView {
                        anchors.fill: parent
                        clip: true
                        padding: 0
                        contentWidth: availableWidth

                        ColumnLayout {
                            width: parent.availableWidth
                            spacing: 12

                            PlasmaExtras.Heading {
                                text: "Cooling"
                                level: 2
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Monitor and manage your cooling system."
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            Text {
                                text: "CPU Temperature: " +
                                      (root.telemetryReady
                                       ? root.formatTemperature(hardwareController.cpuTemperature)
                                       : "— " + root.temperatureUnitSymbol)
                                color: Kirigami.Theme.textColor
                                font.pixelSize: 15
                            }

                            Text {
                                text: "GPU Temperature: " +
                                      (root.telemetryReady
                                       ? root.formatTemperature(hardwareController.gpuTemperature)
                                       : "— " + root.temperatureUnitSymbol)
                                color: Kirigami.Theme.textColor
                                font.pixelSize: 15
                            }

                            Text {
                                text: "CPU Fan: " +
                                      (root.telemetryReady
                                       ? hardwareController.cpuFanRpm + " RPM"
                                       : "— RPM") +
                                      " · " +
                                      (root.telemetryReady
                                       ? hardwareController.cpuFanDuty + "%"
                                       : "—")
                                color: Kirigami.Theme.textColor
                            }

                            Text {
                                text: "GPU Fan: " +
                                      (root.telemetryReady
                                       ? hardwareController.gpuFanRpm + " RPM"
                                       : "— RPM") +
                                      " · " +
                                      (root.telemetryReady
                                       ? hardwareController.gpuFanDuty + "%"
                                       : "—")
                                color: Kirigami.Theme.textColor
                            }

                            // The profile selector reflects upstream state.
                            // It remains disabled until gigactld is available.
                            Text {
                                text: "Fan Profile"
                                color: Kirigami.Theme.textColor
                                Layout.fillWidth: true
                            }

                            PlasmaComponents.ComboBox {
                                id: fanProfileSelector

                                Layout.fillWidth: true

                                enabled: daemonClient.available &&
                                         daemonClient.activeProfile.length > 0

                                textRole: "text"
                                valueRole: "value"

                                model: [
                                    { text: "Silent", value: "quiet" },
                                    { text: "Balanced", value: "balanced" },
                                    { text: "Performance", value: "performance" },
                                    { text: "Maximum", value: "max" },
                                    { text: "Auto (firmware)", value: "firmware" }
                                ]

                                currentIndex: -1

                                function syncSelectedProfile() {
                                    const profiles = ["quiet", "balanced", "performance", "max", "firmware"]
                                    currentIndex = profiles.indexOf(daemonClient.activeProfile)
                                }

                                Component.onCompleted: syncSelectedProfile()

                                Connections {
                                    target: daemonClient

                                    function onAvailabilityChanged() {
                                        fanProfileSelector.syncSelectedProfile()
                                    }

                                    function onStateChanged() {
                                        fanProfileSelector.syncSelectedProfile()
                                    }
                                }

                                // Avoid a blank control when no profile is known.
                                displayText: {
                                    if (!daemonClient.available) {
                                        return "Daemon unavailable"
                                    }
                                    if (daemonClient.activeProfile.length === 0) {
                                        return "Loading profile…"
                                    }
                                    if (currentIndex < 0) {
                                        if (daemonClient.activeProfile === "manual") {
                                            return "Manual control"
                                        }
                                        if (daemonClient.activeProfile === "custom") {
                                            return "Custom curve"
                                        }
                                        return "Unsupported: " + daemonClient.activeProfile
                                    }
                                    return currentText
                                }

                                onActivated: {
                                    if (currentIndex < 0) {
                                        return
                                    }
                                    const selectedProfile = model[currentIndex].value
                                    if (selectedProfile !== daemonClient.activeProfile) {
                                        daemonClient.setProfile(selectedProfile)
                                    }
                                }
                            }

                            Text {
                                visible: !daemonClient.available
                                text: "Telemetry and fan profiles are unavailable until gigactld is running."
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Control Service: " +
                                      (daemonClient.available ? "Connected" : "Unavailable")
                                color: daemonClient.available
                                       ? Kirigami.Theme.textColor
                                       : Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                            }

                            Text {
                                visible: daemonClient.available && daemonClient.ecStatus.length > 0
                                text: "EC Status: " + daemonClient.ecStatus
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: daemonClient.error.length > 0
                                text: "Daemon error: " + daemonClient.error
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: daemonClient.available &&
                                         hardwareController.error.length > 0
                                text: "Monitoring error: " + hardwareController.error
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // RGB Keyboard
                Item {
                    PlasmaComponents.ScrollView {
                        anchors.fill: parent
                        clip: true
                        padding: 0
                        contentWidth: availableWidth

                        ColumnLayout {
                            width: parent.availableWidth
                            spacing: 12

                            PlasmaExtras.Heading {
                                text: "RGB Keyboard"
                                level: 2
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Single-zone RGB lighting for the whole keyboard. Changing color or brightness turns it on."
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            PlasmaComponents.Switch {
                                id: keyboardPowerSwitch

                                text: checked ? "Keyboard on" : "Keyboard off"
                                checked: daemonClient.keyboardEnabled
                                enabled: daemonClient.available

                                onClicked: {
                                    daemonClient.setKeyboardEnabled(checked)
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 4
                                    color: root.keyboardColor
                                    border.width: 1
                                    border.color: Kirigami.Theme.textColor
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "Keyboard color"
                                        color: Kirigami.Theme.textColor
                                    }

                                    Text {
                                        text: root.keyboardColorHex
                                        color: Kirigami.Theme.disabledTextColor
                                        font.pixelSize: 11
                                    }
                                }

                                PlasmaComponents.Button {
                                    text: "Choose color"
                                    enabled: daemonClient.available
                                    onClicked: keyboardColorDialog.open()
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "Brightness"
                                    color: Kirigami.Theme.textColor
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: Math.round(keyboardBrightnessSlider.value) + "%"
                                    color: Kirigami.Theme.textColor
                                }
                            }

                            PlasmaComponents.Slider {
                                id: keyboardBrightnessSlider

                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                stepSize: 1
                                value: daemonClient.keyboardBrightness
                                enabled: daemonClient.available

                                onPressedChanged: {
                                    if (!pressed && daemonClient.available &&
                                        Math.round(value) !== daemonClient.keyboardBrightness) {
                                        daemonClient.setKeyboardBrightness(Math.round(value))
                                    }
                                }
                            }

                            Connections {
                                target: daemonClient

                                function onKeyboardStateChanged() {
                                    keyboardPowerSwitch.checked = daemonClient.keyboardEnabled
                                    keyboardBrightnessSlider.value = daemonClient.keyboardBrightness
                                }
                            }

                            Text {
                                visible: !daemonClient.available
                                text: "Keyboard controls are unavailable until gigactld is running."
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: daemonClient.error.length > 0
                                text: "Control error: " + daemonClient.error
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Settings
                Item {
                    PlasmaComponents.ScrollView {
                        anchors.fill: parent
                        clip: true
                        padding: 0
                        contentWidth: availableWidth

                        ColumnLayout {
                            width: parent.availableWidth
                            spacing: 8

                            PlasmaExtras.Heading {
                                text: "Settings"
                                level: 2
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "General preferences and CPU performance."
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            PlasmaExtras.Heading {
                                text: "Performance"
                                level: 3
                                Layout.fillWidth: true
                            }

                            PlasmaComponents.Switch {
                                id: turboBoostSwitch

                                text: daemonClient.available && daemonClient.turboAvailable
                                      ? (daemonClient.turboBoost
                                         ? "Turbo Boost enabled"
                                         : "Turbo Boost disabled")
                                      : "Turbo Boost"
                                checked: daemonClient.turboBoost
                                enabled: daemonClient.available &&
                                         daemonClient.turboAvailable
                                onClicked: daemonClient.setTurboBoost(checked)
                            }

                            Text {
                                text: "Other system tools may also manage Turbo Boost, which can conflict with this setting or override it."
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            Text {
                                visible: !daemonClient.available
                                text: "Start gigactld to view and change Turbo Boost."
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            Text {
                                visible: daemonClient.available &&
                                         !daemonClient.turboAvailable
                                text: "Turbo Boost control is unavailable on this system."
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            Connections {
                                target: daemonClient

                                function onTurboStateChanged() {
                                    turboBoostSwitch.checked = daemonClient.turboBoost
                                }
                            }

                            PlasmaExtras.Heading {
                                text: "Monitoring"
                                level: 3
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "Temperature unit"
                                    color: Kirigami.Theme.textColor
                                    Layout.fillWidth: true
                                }

                                PlasmaComponents.ComboBox {
                                    id: temperatureUnitSelector

                                    Layout.preferredWidth: 180
                                    textRole: "text"
                                    valueRole: "value"
                                    model: [
                                        { text: "Celsius (°C)", value: "C" },
                                        { text: "Fahrenheit (°F)", value: "F" }
                                    ]
                                    currentIndex: root.temperatureUnit === "F" ? 1 : 0

                                    onActivated: function(index) {
                                        Plasmoid.configuration.temperatureUnit =
                                            model[index].value
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "Update interval"
                                    color: Kirigami.Theme.textColor
                                    Layout.fillWidth: true
                                }

                                PlasmaComponents.ComboBox {
                                    id: updateIntervalSelector

                                    Layout.preferredWidth: 180
                                    textRole: "text"
                                    valueRole: "value"
                                    model: [
                                        { text: "2 seconds", value: 2 },
                                        { text: "5 seconds", value: 5 },
                                        { text: "10 seconds", value: 10 }
                                    ]
                                    currentIndex: [2, 5, 10].indexOf(
                                        root.monitoringIntervalSeconds)

                                    onActivated: function(index) {
                                        Plasmoid.configuration.monitoringIntervalSeconds =
                                            model[index].value
                                    }
                                }
                            }

                            Text {
                                text: "The interval applies while GigaControl is open and gigactld is connected."
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            PlasmaExtras.Heading {
                                text: "Daemon and system status"
                                level: 3
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Control service: " +
                                      (daemonClient.available ? "Connected" : "Unavailable")
                                color: Kirigami.Theme.textColor
                                font.pixelSize: 11
                            }

                            Text {
                                visible: daemonClient.available &&
                                         daemonClient.daemonVersion.length > 0
                                text: "gigactld version: " + daemonClient.daemonVersion
                                color: Kirigami.Theme.textColor
                                font.pixelSize: 11
                            }

                            Text {
                                visible: daemonClient.available &&
                                         daemonClient.ecStatus.length === 0
                                text: "Embedded Controller: ready"
                                color: Kirigami.Theme.textColor
                                font.pixelSize: 11
                            }

                            Text {
                                visible: daemonClient.available &&
                                         daemonClient.ecStatus.length > 0
                                text: "Embedded Controller: " + daemonClient.ecStatus
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            Text {
                                visible: daemonClient.error.length > 0
                                text: "Daemon error: " + daemonClient.error
                                color: Kirigami.Theme.disabledTextColor
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }

                            PlasmaExtras.Heading {
                                text: "Help"
                                level: 3
                                Layout.fillWidth: true
                            }

                            Text {
                                textFormat: Text.RichText
                                text: "<a href=\"" + root.userGuideUrl.toString() +
                                      "\">Open the GigaControl user guide</a>"
                                color: Kirigami.Theme.textColor
                                linkColor: Kirigami.Theme.linkColor
                                font.pixelSize: 12
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap

                                onLinkActivated: function(link) {
                                    Qt.openUrlExternally(link)
                                }
                            }
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
