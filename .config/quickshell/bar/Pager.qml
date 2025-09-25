import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects

Item {
  id: pagerRoot
  implicitHeight: rect.implicitHeight
  implicitWidth: rect.implicitWidth

  Rectangle {
    id: rect
    color: panel.colors.dark_surface_variant
    radius: panel.format.radius_small
    implicitWidth: row.implicitWidth + panel.format.spacing_medium
    implicitHeight: panel.format.module_height

    RowLayout {
      id: row
      anchors.fill: parent
      anchors.margins: panel.format.spacing_small
      spacing: panel.format.spacing_small

      Repeater {
        model: Hyprland.workspaces
        delegate: Rectangle {
          visible: (panel.screen.name === modelData.monitor.name) && modelData.id >= 1
          color: modelData.active ? panel.colors.dark_primary : panel.colors.dark_secondary
          
          implicitHeight: panel.format.module_height - panel.format.spacing_small
          implicitWidth: implicitHeight
          anchors.verticalCenter: parent.verticalCenter
          radius: panel.format.module_radius

          Text{
            font.pixelSize: panel.format.text_size
            text: modelData.id
            color: panel.colors.dark_on_primary
            anchors.horizontalCenter: parent.horizontalCenter
          }
          
          MouseArea {
            anchors.fill: parent
            onClicked: modelData.activate()
          }
        }
      }
    }
  }
}
