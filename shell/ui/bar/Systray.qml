import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.components.bar
import qs

ModuleBase {
  id: systray
  implicitWidth: rowLayout.implicitWidth + Global.format.spacing_medium
  
  visible: true // SystemTray.items.values.length > 0
  
  property var bar: panel

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
        bar: systray.bar
      }
    }
  }
}
