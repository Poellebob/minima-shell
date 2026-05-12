import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.components.widget
import qs.components.text
import qs

DropdownWindow {
  id: menuRoot
  implicitWidth: 600
  implicitHeight: 400
  color: "transparent"

  property BluetoothAdapter currentAdapter: Bluetooth.adapters.values[tabs.index] ?? Bluetooth.defaultAdapter

  Rectangle {
    anchors.fill: parent
    anchors.margins: Global.format.spacing_large
    radius: Global.format.radius_large
    color: Global.colors.inverse_on_surface

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Global.format.spacing_large
      spacing: Global.format.spacing_medium

      RowLayout {
        Layout.fillWidth: true
        spacing: Global.format.spacing_medium

        Tabbar {
          id: tabs
          visible: count > 1
          Layout.fillWidth: true
          model: Bluetooth.adapters
          delegate: Tab {
            required property var modelData
            required property int index
            text: modelData.name
            isSelected: tabs.index === index
            onClicked: tabs.index = index
          }
        }

        Item { Layout.fillWidth: true; visible: tabs.count <= 1 }

        StyledButton {
          implicitHeight: Global.format.module_height
          visible: menuRoot.currentAdapter?.enabled ?? false
          text: menuRoot.currentAdapter?.discovering ? "󰑎  Scanning…" : "󰐷  Scan"
          colorDefault: menuRoot.currentAdapter?.discovering
            ? Global.colors.primary_container
            : Global.colors.surface_container
          colorHovered: menuRoot.currentAdapter?.discovering
            ? Global.colors.primary_container
            : Global.colors.surface_container_high
          colorText: menuRoot.currentAdapter?.discovering
            ? Global.colors.on_primary_container
            : Global.colors.on_surface_variant
          onClicked: {
            if (menuRoot.currentAdapter)
              menuRoot.currentAdapter.discovering = !menuRoot.currentAdapter.discovering
          }
        }

        Toggle {
          checked: menuRoot.currentAdapter?.enabled ?? false
          onToggled: {
            if (menuRoot.currentAdapter)
              menuRoot.currentAdapter.enabled = !menuRoot.currentAdapter.enabled
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Global.format.radius_large
        color: Global.colors.surface_variant
        clip: true

        StyledText {
          anchors.centerIn: parent
          visible: deviceList.count === 0
          color: Global.colors.outline
          text: {
            if (!menuRoot.currentAdapter) return "No adapter"
            if (!menuRoot.currentAdapter.enabled) return "Bluetooth is off"
            if (menuRoot.currentAdapter.discovering) return "Scanning for devices…"
            return "No devices found"
          }
        }

        ListView {
          id: deviceList
          anchors.fill: parent
          anchors.margins: Global.format.spacing_small
          spacing: Global.format.spacing_tiny
          clip: true

          populate: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
          }

          model: menuRoot.currentAdapter?.devices ?? []

          delegate: Rectangle {
            required property BluetoothDevice modelData

            width: deviceList.width - scrollBar.width
            height: Global.format.module_height + Global.format.spacing_medium * 2
            radius: Global.format.radius_medium
            color: rowHover.containsMouse
              ? Global.colors.surface_container_high
              : "transparent"
            visible: modelData.name

            Behavior on color {
              ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: Global.format.spacing_medium
              anchors.rightMargin: Global.format.spacing_small
              anchors.topMargin: Global.format.spacing_small
              anchors.bottomMargin: Global.format.spacing_small
              spacing: Global.format.spacing_medium

              StyledText {
                text: {
                  switch (modelData.state) {
                    case BluetoothDeviceState.Connected:     return "󰂱"
                    case BluetoothDeviceState.Connecting:    return "󰂴"
                    case BluetoothDeviceState.Disconnecting: return "󰂴"
                    default: return modelData.paired ? "󰂲" : "󰂳"
                  }
                }
                color: modelData.state === BluetoothDeviceState.Connected
                  ? Global.colors.primary
                  : Global.colors.outline
              }

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                  Layout.fillWidth: true
                  text: modelData.name || modelData.address
                  color: modelData.connected
                    ? Global.colors.on_surface
                    : Global.colors.on_surface_variant
                  font.bold: true
                  elide: Text.ElideRight
                }

                StyledText {
                  Layout.fillWidth: true
                  font.pixelSize: Global.format.font_size_small
                  color: Global.colors.outline
                  elide: Text.ElideRight
                  text: {
                    let parts = []
                    if (modelData.paired)  parts.push("Paired")
                    if (modelData.bonded)  parts.push("Bonded")
                    if (modelData.trusted) parts.push("Trusted")
                    if (modelData.blocked) parts.push("Blocked")
                    return parts.join(" · ") || modelData.address
                  }
                }
              }

              StyledText {
                visible: modelData.batteryAvailable && modelData.connected
                text: Math.round(modelData.battery * 100) + "%"
                color: Global.colors.on_surface_variant
                font.pixelSize: Global.format.font_size_small
              }

              StyledButton {
                implicitHeight: Global.format.module_height

                property bool transitioning:
                  modelData.state === BluetoothDeviceState.Connecting ||
                  modelData.state === BluetoothDeviceState.Disconnecting

                enabled: !transitioning
                text: {
                  switch (modelData.state) {
                    case BluetoothDeviceState.Connecting:    return "Connecting…"
                    case BluetoothDeviceState.Disconnecting: return "Disconnecting…"
                    case BluetoothDeviceState.Connected:     return "Disconnect"
                    default:                                 return "Connect"
                  }
                }
                colorDefault: modelData.connected
                  ? Global.colors.error_container
                  : Global.colors.surface_container
                colorHovered: modelData.connected
                  ? Qt.lighter(Global.colors.error_container, 1.1)
                  : Global.colors.surface_container_high
                colorText: modelData.connected
                  ? Global.colors.on_error_container
                  : Global.colors.on_surface_variant
                colorDisabled: Global.colors.surface_container_low

                onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
              }
            }

            MouseArea {
              id: rowHover
              anchors.fill: parent
              hoverEnabled: true
              acceptedButtons: Qt.NoButton
              propagateComposedEvents: true
            }
          }

          ScrollBar.vertical: ScrollBar {
            id: scrollBar
            policy: ScrollBar.AsNeeded
          }
        }
      }
    }
  }
}
