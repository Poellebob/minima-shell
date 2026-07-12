import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ExpandedPanel {
  id: wallpaperExpanded

  property var wallpapers: []
  property int selectedIndex: 0
  property int columns: 4

  function activate() {}
  function navigateUp() { selectedIndex = Math.max(0, selectedIndex - columns) }
  function navigateDown() { selectedIndex = Math.min(wallpapers.length - 1, selectedIndex + columns) }

  ColumnLayout {
    anchors.fill: parent
    spacing: Global.format.spacing_small

    Text {
      text: "Wallpapers"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.font_size_medium
      font.bold: true
      color: Global.colors.on_surface
    }

    GridView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      cellWidth: (width - Global.format.spacing_small * (columns - 1)) / columns
      cellHeight: cellWidth * 0.6
      model: wallpaperExpanded.wallpapers

      delegate: Rectangle {
        width: GridView.view.cellWidth
        height: GridView.view.cellHeight
        radius: Global.format.radius_small
        color: index === wallpaperExpanded.selectedIndex ? Global.colors.primary_container : Global.colors.surface_variant

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: Global.format.spacing_small

          Text {
            text: "󰸉"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.font_size_large
            color: Global.colors.on_surface
            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: true
          }

          Text {
            text: modelData.name
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.font_size_small
            color: Global.colors.on_surface_variant
            Layout.alignment: Qt.AlignCenter
            elide: Text.ElideRight
            maximumLineCount: 1
          }
        }
      }
    }

    Text {
      visible: wallpaperExpanded.wallpapers.length === 0
      text: "No wallpapers found"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      color: Global.colors.on_surface_variant
      Layout.alignment: Qt.AlignCenter
    }
  }
}
