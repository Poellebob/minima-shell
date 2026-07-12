import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ExpandedPanel {
  id: bluetoothExpanded

  property var devices: []
  property int selectedIndex: 0
  property bool scanning: false

  function activate() {}
  function navigateUp() { selectedIndex = Math.max(0, selectedIndex - 1) }
  function navigateDown() { selectedIndex = Math.min(devices.length - 1, selectedIndex + 1) }

  ColumnLayout {
    Layout.fillWidth: true
    spacing: Global.format.spacing_small

    RowLayout {
      Layout.fillWidth: true

      Text {
        text: "Bluetooth"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.font_size_medium
        font.bold: true
        color: Global.colors.on_surface
        Layout.fillWidth: true
      }

      Text {
        text: scanning ? "Scanning..." : "Scan"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        color: Global.colors.primary
      }
    }

    Repeater {
      model: bluetoothExpanded.devices

      Rectangle {
        Layout.fillWidth: true
        height: 28
        radius: Global.format.radius_small
        color: index === bluetoothExpanded.selectedIndex ? Global.colors.primary_container : "transparent"

        RowLayout {
          anchors.fill: parent
          anchors.margins: Global.format.spacing_small

          Text {
            text: modelData.connected ? "󰂱" : "󰂲"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            color: modelData.connected ? Global.colors.primary : Global.colors.on_surface
          }

          Text {
            text: modelData.name
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            color: Global.colors.on_surface
            Layout.fillWidth: true
          }
        }
      }
    }

    Text {
      visible: bluetoothExpanded.devices.length === 0
      text: "No devices found"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      color: Global.colors.on_surface_variant
      Layout.alignment: Qt.AlignCenter
    }
  }
}
