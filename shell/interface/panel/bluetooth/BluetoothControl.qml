import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.components.text
import qs

Item {
    id: root

    implicitHeight: 250

    property int adapterIndex: 0
    property BluetoothAdapter currentAdapter: Bluetooth.adapters.values[adapterIndex] ?? Bluetooth.defaultAdapter

    readonly property var devices: {
        const adapter = currentAdapter;
        if (!adapter)
            return [];
        const devs = [];
        for (const key in adapter.devices.values) {
            const dev = adapter.devices.values[key];
            if (dev && dev.name)
                devs.push(dev);
        }
        return devs;
    }

    readonly property var sortedDevices: {
        return devices.slice().sort((a, b) => {
            const aConnected = a.state === BluetoothDeviceState.Connected;
            const bConnected = b.state === BluetoothDeviceState.Connected;
            if (aConnected !== bConnected)
                return aConnected ? -1 : 1;

            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;

            return (a.name || a.address).localeCompare(b.name || b.address);
        });
    }

    function adapterStateText(): string {
        if (!currentAdapter)
            return "";
        switch (currentAdapter.state) {
        case BluetoothAdapterState.Enabled:
            return "On";
        case BluetoothAdapterState.Disabled:
            return "Off";
        case BluetoothAdapterState.Enabling:
            return "Enabling…";
        case BluetoothAdapterState.Disabling:
            return "Disabling…";
        case BluetoothAdapterState.Blocked:
            return "Blocked";
        default:
            return "";
        }
    }

    function adapterStateColor(): color {
        if (!currentAdapter)
            return Global.colors.outline;
        switch (currentAdapter.state) {
        case BluetoothAdapterState.Enabled:
            return Global.colors.primary;
        case BluetoothAdapterState.Disabled:
            return Global.colors.outline;
        case BluetoothAdapterState.Enabling:
        case BluetoothAdapterState.Disabling:
            return Global.colors.secondary;
        case BluetoothAdapterState.Blocked:
            return Global.colors.error;
        default:
            return Global.colors.outline;
        }
    }

    function deviceStateIcon(dev): string {
        if (!dev)
            return "";
        if (dev.blocked)
            return "󱘖";
        switch (dev.state) {
        case BluetoothDeviceState.Connected:
            return "󰂱";
        case BluetoothDeviceState.Connecting:
            return "󰂴";
        case BluetoothDeviceState.Disconnecting:
            return "󰂴";
        default:
            return dev.paired ? "󰂲" : "󰂳";
        }
    }

    function deviceActionText(dev): string {
        if (!dev)
            return "";
        if (dev.state === BluetoothDeviceState.Connecting)
            return "Connecting…";
        if (dev.state === BluetoothDeviceState.Disconnecting)
            return "Disconnecting…";
        return dev.state === BluetoothDeviceState.Connected ? "Disconnect" : "Connect";
    }

    // Only the things the icon/buttons elsewhere in the row can't already tell you:
    // connection state is the icon, trusted/blocked are their own toggle buttons.
    function deviceMiddleInfo(dev): string {
        if (!dev)
            return "";
        let parts = [];
        if (dev.batteryAvailable)
            parts.push("Battery " + Math.round(dev.battery * 100) + "%");
        if (dev.bonded)
            parts.push("Bonded");
        return parts.join(" · ") || "—";
    }

    function emptyStateText(): string {
        if (!currentAdapter)
            return "No adapter";
        switch (currentAdapter.state) {
        case BluetoothAdapterState.Blocked:
            return "Adapter blocked by rfkill";
        case BluetoothAdapterState.Enabling:
            return "Enabling adapter…";
        case BluetoothAdapterState.Disabling:
            return "Disabling adapter…";
        }
        if (!currentAdapter.enabled)
            return "Bluetooth is off";
        if (currentAdapter.discovering)
            return "Scanning for devices…";
        return "No devices found";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Global.format.spacing_medium

        // Adapter header row
        RowLayout {
            Layout.fillWidth: true
            spacing: Global.format.spacing_medium

            Row {
                spacing: Global.format.spacing_small

                Repeater {
                    model: Bluetooth.adapters
                    delegate: Text {
                        required property var modelData
                        required property int index
                        text: modelData.name + " " + modelData.adapterId
                        color: root.adapterIndex === index ? Global.colors.primary : Global.colors.on_surface_variant
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Global.format.text_size
                        font.bold: root.adapterIndex === index

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.adapterIndex = index
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                visible: root.currentAdapter?.enabled
                text: root.currentAdapter?.discoverable ? "  Discoverable" : "  Undiscoverable"
                color: root.currentAdapter?.discoverable ? Global.colors.primary : Global.colors.on_surface_variant
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.currentAdapter)
                            root.currentAdapter.discoverable = !root.currentAdapter.discoverable;
                    }
                }
            }

            Text {
                visible: root.currentAdapter?.enabled
                text: root.currentAdapter?.pairable ? "  Pairable" : "  Unpairable"
                color: root.currentAdapter?.pairable ? Global.colors.primary : Global.colors.on_surface_variant
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.currentAdapter)
                            root.currentAdapter.pairable = !root.currentAdapter.pairable;
                    }
                }
            }

            Text {
                visible: root.currentAdapter?.enabled
                text: root.currentAdapter?.discovering ? "  Scanning…" : "  Scan"
                color: root.currentAdapter?.discovering ? Global.colors.primary : Global.colors.on_surface_variant
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.currentAdapter)
                            root.currentAdapter.discovering = !root.currentAdapter.discovering;
                    }
                }
            }

            Text {
                text: root.adapterStateText()
                color: root.adapterStateColor()
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.currentAdapter)
                            root.currentAdapter.enabled = !root.currentAdapter.enabled;
                    }
                }
            }
        }

        // Device card
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            border.color: Global.colors.outline
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Global.format.spacing_small
                spacing: Global.format.spacing_small

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    StyledText {
                        anchors.centerIn: parent
                        visible: deviceList.count === 0
                        text: root.emptyStateText()
                        color: Global.colors.outline
                    }

                    ListView {
                        id: deviceList
                        anchors.fill: parent
                        clip: true
                        spacing: Global.format.spacing_tiny
                        model: root.sortedDevices

                        delegate: Item {
                            id: row
                            required property BluetoothDevice modelData
                            width: deviceList.width
                            height: Global.format.module_height + Global.format.spacing_small

                            property bool isTransitioning: modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting

                            RowLayout {
                                anchors.fill: parent
                                spacing: Global.format.spacing_small

                                // Name (left)
                                RowLayout {
                                    Layout.preferredWidth: parent.width * 0.35
                                    spacing: Global.format.spacing_small

                                    Text {
                                        text: root.deviceStateIcon(row.modelData)
                                        color: row.modelData.state === BluetoothDeviceState.Connected ? Global.colors.primary : row.modelData.blocked ? Global.colors.error : Global.colors.outline
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Global.format.text_size
                                    }

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: row.modelData.name || row.modelData.address
                                        color: row.modelData.state === BluetoothDeviceState.Connected ? Global.colors.primary : Global.colors.on_surface_variant
                                        font.bold: row.modelData.state === BluetoothDeviceState.Connected
                                        elide: Text.ElideRight
                                    }
                                }

                                // Light info (middle) — whatever the icon/buttons can't tell you
                                StyledText {
                                    Layout.fillWidth: true
                                    text: root.deviceMiddleInfo(row.modelData)
                                    color: Global.colors.outline
                                    font.pixelSize: Global.format.font_size_small
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }

                                // Controls (right)
                                RowLayout {
                                    spacing: Global.format.spacing_medium

                                    Text {
                                        text: root.deviceActionText(row.modelData)
                                        color: row.isTransitioning ? Global.colors.outline : (connectMouse.containsMouse ? (row.modelData.state === BluetoothDeviceState.Connected ? Global.colors.error : Global.colors.primary) : (row.modelData.state === BluetoothDeviceState.Connected ? Global.colors.error : Global.colors.on_surface_variant))
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Global.format.text_size
                                        MouseArea {
                                            id: connectMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            enabled: !row.isTransitioning
                                            onClicked: {
                                                if (row.modelData.state === BluetoothDeviceState.Connected)
                                                    row.modelData.disconnect();
                                                else
                                                    row.modelData.connect();
                                            }
                                        }
                                    }

                                    Text {
                                        visible: !row.modelData.trusted
                                        text: "Trust"
                                        color: trustMouse.containsMouse ? Global.colors.primary : Global.colors.on_surface_variant
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Global.format.text_size
                                        MouseArea {
                                            id: trustMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: row.modelData.trusted = true
                                        }
                                    }

                                    Text {
                                        visible: row.modelData.trusted
                                        text: "Untrust"
                                        color: trustMouse2.containsMouse ? Global.colors.primary : Global.colors.on_surface_variant
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Global.format.text_size
                                        MouseArea {
                                            id: trustMouse2
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: row.modelData.trusted = false
                                        }
                                    }

                                    Text {
                                        // forget() is the only way to unpair a device (Quickshell docs:
                                        // pair() pairs, but you must forget() to undo it).
                                        visible: row.modelData.paired
                                        text: "Forget"
                                        color: forgetMouse.containsMouse ? Global.colors.error : Global.colors.on_surface_variant
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Global.format.text_size
                                        MouseArea {
                                            id: forgetMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: row.modelData.forget()
                                        }
                                    }

                                    Text {
                                        visible: !row.modelData.blocked
                                        text: "Block"
                                        color: blockMouse.containsMouse ? Global.colors.error : Global.colors.on_surface_variant
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Global.format.text_size
                                        MouseArea {
                                            id: blockMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: row.modelData.blocked = true
                                        }
                                    }

                                    Text {
                                        visible: row.modelData.blocked
                                        text: "Unblock"
                                        color: blockMouse2.containsMouse ? Global.colors.error : Global.colors.on_surface_variant
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Global.format.text_size
                                        MouseArea {
                                            id: blockMouse2
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: row.modelData.blocked = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
