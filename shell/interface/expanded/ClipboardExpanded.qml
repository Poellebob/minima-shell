import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ExpandedPanel {
  id: clipboardExpanded

  property var entries: []
  property int selectedIndex: 0

  function activate() {}
  function navigateUp() { selectedIndex = Math.max(0, selectedIndex - 1) }
  function navigateDown() { selectedIndex = Math.min(entries.length - 1, selectedIndex + 1) }

  ColumnLayout {
    anchors.fill: parent
    spacing: Global.format.spacing_small

    Text {
      text: "Clipboard"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.font_size_medium
      font.bold: true
      color: Global.colors.on_surface
    }

    ListView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      model: clipboardExpanded.entries

      delegate: Rectangle {
        width: ListView.view.width
        height: 32
        radius: Global.format.radius_small
        color: index === clipboardExpanded.selectedIndex ? Global.colors.primary_container : "transparent"

        RowLayout {
          anchors.fill: parent
          anchors.margins: Global.format.spacing_small

          Text {
            text: modelData.isImage ? "󰈈" : "󰆏"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            color: Global.colors.on_surface
          }

          Text {
            text: modelData.preview
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            color: Global.colors.on_surface
            Layout.fillWidth: true
            elide: Text.ElideRight
            maximumLineCount: 1
          }
        }
      }
    }

    Text {
      visible: clipboardExpanded.entries.length === 0
      text: "No clipboard entries"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      color: Global.colors.on_surface_variant
      Layout.alignment: Qt.AlignCenter
    }
  }
}
