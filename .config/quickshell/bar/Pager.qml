import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import qs.components.bar
import qs.components.text

ModuleBase {
  id: pagerRoot
  implicitWidth: row.implicitWidth + panel.format.spacing_medium

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.margins: panel.format.spacing_small
    spacing: panel.format.spacing_small

    Repeater {
      model: Hyprland.workspaces
      delegate: Rectangle {
        visible: (panel.screen.name === modelData.monitor.name) && modelData.id >= 1
        color: modelData.active ? panel.colors.primary : panel.colors.secondary
        
        implicitHeight: panel.format.module_height - panel.format.spacing_small
        implicitWidth: implicitHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: panel.format.module_radius

        StyledText{
          text: modelData.id
          color: panel.colors.on_primary
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
