import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.components.bar

ModuleBase {
  id: systray
  implicitWidth: rowLayout.implicitWidth + panel.format.spacing_medium

  RowLayout {
    id: rowLayout
    anchors.margins: panel.format.spacing_small
    anchors.fill: parent
    spacing: panel.format.spacing_small

    Repeater {
      model: SystemTray.items
      delegate: SysTrayItem {
        required property SystemTrayItem modelData
        item: modelData
        bar: panel
      }
    }
  }
}