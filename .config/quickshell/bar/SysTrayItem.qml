import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.DBusMenu
import Qt5Compat.GraphicalEffects
import qs.components.popup
import qs.format

MouseArea {
  id: sysTrayItem

  readonly property Format format: Format {}

  required property var bar
  required property SystemTrayItem item
  property bool targetMenuOpen: false
  property int trayItemWidth: format.systray_icon_size

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
          menu.visible = !menu.visible;
          menu.hideTimer.restart();
        }
      break;
    }
    event.accepted = true;
  }

  QsMenuOpener {
    id: menuOpen
    menu: sysTrayItem.item.menu
  }

  PopupMenu {
    id: menu
    anchor.window: bar
    anchor.rect.x: sysTrayItem.x
    anchor.rect.y: bar.implicitHeight
    anchor.edges: Edges.Top
    model: menuOpen.children
    onItemTriggered: menu.visible = false
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
