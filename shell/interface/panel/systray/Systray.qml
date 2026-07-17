import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs

Item {
  id: systray

  implicitHeight: Global.format.module_height
  implicitWidth: rowLayout.implicitWidth + Global.format.spacing_medium

  RowLayout {
    id: rowLayout
    anchors.margins: Global.format.spacing_small
    anchors.fill: parent
    spacing: Global.format.spacing_small

    Repeater {
      model: SystemTray.items
      delegate: SysTrayItem {
        required property SystemTrayItem modelData
        item: modelData
      }
    }
  }
}
