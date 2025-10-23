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
  implicitWidth: row.implicitWidth + format.spacing_medium

  // TODO: This component is dependent on the panel because of the screen property.
  // This needs to be refactored to be able to use it without a panel.
  property var screen: panel.screen

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.margins: format.spacing_small
    spacing: format.spacing_small

    Repeater {
      model: Hyprland.workspaces
      delegate: Rectangle {
        visible: (pagerRoot.screen.name === modelData.monitor.name) && modelData.id >= 1
        color: modelData.active ? colors.primary : colors.secondary
        
        implicitHeight: format.module_height - format.spacing_small
        implicitWidth: implicitHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: format.module_radius

        StyledText{
          text: modelData.id
          color: colors.on_primary
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