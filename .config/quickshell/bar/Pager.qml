import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import qs.components.bar
import qs.components.text
import qs

ModuleBase {
  id: pagerRoot
  implicitWidth: row.implicitWidth + Global.format.spacing_medium

  // TODO: This component is dependent on the panel because of the screen property.
  // This needs to be refactored to be able to use it without a panel.
  property var screen: panel.screen

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.margins: Global.format.spacing_small
    spacing: Global.format.spacing_small

    Repeater {
      model: Hyprland.workspaces
      delegate: Rectangle {
        visible: (pagerRoot.screen.name === modelData.monitor.name) && modelData.id >= 1
        color: modelData.active ? Global.colors.primary : Global.colors.secondary
        
        implicitHeight: Global.format.module_height - Global.format.spacing_small
        implicitWidth: implicitHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: Global.format.module_radius

        StyledText{
          text: modelData.id
          color: Global.colors.on_primary
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