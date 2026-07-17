import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.components.widget
import qs

MouseArea {
  id: sysTrayItem

  required property SystemTrayItem item
  property bool targetMenuOpen: false
  property int trayItemWidth: Global.format.systray_icon_size

  signal showMenu(items: ObjectModel)

  anchors {
    verticalCenter: parent.verticalCenter
  }

  acceptedButtons: Qt.LeftButton | Qt.RightButton
  Layout.fillHeight: true
  implicitWidth: trayItemWidth

  onClicked: (event) => {
    switch (event.button) {
      case Qt.LeftButton:
        item.activate();
      break;

      case Qt.RightButton:
        if (item.hasMenu) {
          showMenu(menuOpen.children)
        }
      break;
    }
    event.accepted = true;
  }

  QsMenuOpener {
    id: menuOpen
    menu: sysTrayItem.item.menu
  }

  IconImage {
    id: trayIcon
    visible: true
    source: sysTrayItem.item.icon
    anchors.centerIn: parent
    width: parent.width
    height: parent.height
  }
}
