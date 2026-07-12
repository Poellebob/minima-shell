import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ExpandedPanel {
  id: networkExpanded

  property var networks: []
  property int selectedIndex: 0

  function activate() {}
  function navigateUp() { selectedIndex = Math.max(0, selectedIndex - 1) }
  function navigateDown() { selectedIndex = Math.min(networks.length - 1, selectedIndex + 1) }

  ColumnLayout {
    Layout.fillWidth: true
    spacing: Global.format.spacing_small

    Text {
      text: "Networks"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.font_size_medium
      font.bold: true
      color: Global.colors.on_surface
    }

    Repeater {
      model: networkExpanded.networks

      Rectangle {
        Layout.fillWidth: true
        height: 28
        radius: Global.format.radius_small
        color: index === networkExpanded.selectedIndex ? Global.colors.primary_container : "transparent"

        RowLayout {
          anchors.fill: parent
          anchors.margins: Global.format.spacing_small

          Text {
            text: modelData.signal > 75 ? "󰤨" : (modelData.signal > 50 ? "󰤢" : (modelData.signal > 25 ? "󰤡" : "󰤟"))
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            color: Global.colors.on_surface
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
      visible: networkExpanded.networks.length === 0
      text: "No networks found"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      color: Global.colors.on_surface_variant
      Layout.alignment: Qt.AlignCenter
    }
  }
}
