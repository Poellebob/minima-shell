import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ExpandedPanel {
  id: launcherExpanded

  property string query: ""
  property var results: []
  property int selectedIndex: 0

  function activate() {}
  function navigateUp() { selectedIndex = Math.max(0, selectedIndex - 1) }
  function navigateDown() { selectedIndex = Math.min(results.length - 1, selectedIndex + 1) }

  ColumnLayout {
    anchors.fill: parent
    spacing: Global.format.spacing_small

    Rectangle {
      Layout.fillWidth: true
      height: 32
      radius: Global.format.radius_small
      color: Global.colors.surface_variant

      TextInput {
        id: searchInput
        anchors.fill: parent
        anchors.margins: Global.format.spacing_small
        color: Global.colors.on_surface
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        clip: true
        focus: true

        Text {
          visible: !searchInput.text && !searchInput.activeFocus
          text: "Search apps... (type > for commands, = for calc)"
          font: searchInput.font
          color: Global.colors.on_surface_variant
        }
      }
    }

    ListView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      model: launcherExpanded.results

      delegate: Rectangle {
        width: ListView.view.width
        height: 28
        radius: Global.format.radius_small
        color: index === launcherExpanded.selectedIndex ? Global.colors.primary_container : "transparent"

        RowLayout {
          anchors.fill: parent
          anchors.margins: Global.format.spacing_small

          Text {
            text: modelData.icon || "󰀻"
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
  }
}
