import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs

Item {
  id: systray

  implicitHeight: Global.format.module_height
  implicitWidth: rowLayout.implicitWidth + Global.format.spacing_medium

  property var trayItems: []

  signal showMenu(items: ObjectModel)

  function triggerItem(index: int) {
    if (index >= 0 && index < trayItems.length) {
      trayItems[index].triggerMenu();
    }
  }

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
        Component.onCompleted: systray.trayItems.push(this)
        Component.onDestruction: {
          const idx = systray.trayItems.indexOf(this);
          if (idx >= 0)
            systray.trayItems.splice(idx, 1);
        }
        onShowMenu: items => systray.showMenu(items)
      }
    }
  }
}
