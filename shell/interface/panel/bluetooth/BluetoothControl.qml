import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.components.widget
import qs.components.text
import qs

Item {
  id: root
  implicitWidth: 360

  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property bool powered: adapter?.state
                                  === BluetoothAdapterState.Enabled

  function stateText(dev): string {
    if (dev.pairing)
      return "Pairing";
    switch (dev.state) {
    case BluetoothDeviceState.Connected:
      return "Connected";
    case BluetoothDeviceState.Connecting:
      return "Connecting";
    case BluetoothDeviceState.Disconnecting:
      return "Disconnecting";
    default:
      return dev.paired ? "Paired" : "Not paired";
    }
  }

  function stateColor(dev): color {
    if (dev.pairing)
      return Global.colors.on_surface;
    if (dev.connected)
      return Global.colors.primary;
    switch (dev.state) {
    case BluetoothDeviceState.Connecting:
    case BluetoothDeviceState.Disconnecting:
      return Global.colors.on_surface;
    default:
      return dev.paired ? Global.colors.on_surface_variant :
                          Global.colors.outline;
    }
  }

  ColumnLayout {
    id: contentCol
    anchors.fill: parent
    spacing: Global.format.spacing_large

    RowLayout {
      Layout.fillWidth: true
      spacing: Global.format.spacing_medium

      StyledText {
        text: root.powered ? "󰂯" : "󰂲"
        color: root.powered ? Global.colors.primary : Global.colors.outline
      }

      StyledText {
        Layout.fillWidth: true
        text: root.adapter ? (root.adapter.name || root.adapter.adapterId) :
                             "No adapter"

        color: Global.colors.on_surface_variant
        font.bold: true
        elide: Text.ElideRight
      }

      StyledText {
        visible: root.adapter && root.adapter.state
                 !== BluetoothAdapterState.Enabled && root.adapter.state
                 !== BluetoothAdapterState.Disabled
        text: root.adapter ? BluetoothAdapterState.toString(root.adapter.state) :
                             ""
        color: root.adapter?.state === BluetoothAdapterState.Blocked
               ? Global.colors.error : Global.colors.outline
      }

      ClickableText {
        visible: root.powered
        text: root.adapter?.discovering ? "Scanning" : "Scan"
        baseColor: root.adapter?.discovering ? Global.colors.primary :
                                               Global.colors.on_surface_variant
        hoverColor: Global.colors.on_background

        onClicked: root.adapter.discovering = !root.adapter.discovering
      }

      ClickableText {
        visible: root.powered
        text: root.adapter?.discoverable ? "Visible" : "Hidden"
        baseColor: root.adapter?.discoverable ? Global.colors.primary :
                                                Global.colors.on_surface_variant
        hoverColor: Global.colors.on_background

        onClicked: root.adapter.discoverable = !root.adapter.discoverable
      }

      ClickableText {
        visible: root.adapter
        text: root.powered ? "On" : "Off"
        baseColor: root.powered ? Global.colors.primary : Global.colors.outline
        hoverColor: Global.colors.error

        onClicked: root.adapter.enabled = !root.powered
      }
    }

    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: 200
      color: "transparent"
      border.color: Global.colors.outline
      border.width: 1

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Global.format.spacing_small
        spacing: Global.format.spacing_small

        ListView {
          id: deviceList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: Global.format.spacing_tiny

          model: root.adapter?.devices

          StyledText {
            anchors.centerIn: parent
            text: root.adapter?.discovering ? "Scanning..." : "No devices"
            color: Global.colors.outline
            visible: deviceList.count <= 0
          }

          delegate: Item {
            id: deviceItem
            required property BluetoothDevice modelData
            width: deviceList.width
            height: Global.format.module_height + Global.format.spacing_small

            MouseArea {
              id: deviceRowMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              propagateComposedEvents: true

              onClicked: {
                if (deviceItem.modelData.pairing)
                  deviceItem.modelData.cancelPair();
                else if (!deviceItem.modelData.paired)
                  deviceItem.modelData.pair();
                else
                  deviceItem.modelData.connected =
                      !deviceItem.modelData.connected;
              }

              RowLayout {
                anchors.fill: parent
                spacing: Global.format.spacing_small

                ClickableText {
                  Layout.fillWidth: true
                  text: "󰂱 " + (deviceItem.modelData.name
                                || deviceItem.modelData.address)
                  baseColor: deviceItem.modelData.connected
                             ? Global.colors.primary :
                               Global.colors.on_surface_variant
                  elide: Text.ElideRight
                  mouseEnabled: false
                  hoverOverride: deviceRowMouse.containsMouse
                }

                StyledText {
                  visible: deviceItem.modelData.batteryAvailable
                  text: "󰁹 " + Math.round(deviceItem.modelData.battery * 100)
                        + "%"
                  color: Global.colors.on_surface_variant
                }

                StyledText {
                  text: root.stateText(deviceItem.modelData)
                  color: root.stateColor(deviceItem.modelData)
                }

                ClickableText {
                  visible: deviceItem.modelData.paired
                  text: deviceItem.modelData.trusted ? "Trusted" : "Trust"
                  baseColor: deviceItem.modelData.trusted
                             ? Global.colors.primary : Global.colors.outline
                  hoverColor: Global.colors.on_background

                  onClicked: deviceItem.modelData.trusted =
                             !deviceItem.modelData.trusted
                }

                ClickableText {
                  visible: deviceItem.modelData.paired
                  text: "󰅖"
                  baseColor: Global.colors.on_surface_variant
                  hoverColor: Global.colors.error

                  onClicked: deviceItem.modelData.forget()
                }
              }
            }
          }
        }
      }
    }
  }

  implicitHeight: contentCol.implicitHeight
}
