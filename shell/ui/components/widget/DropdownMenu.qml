import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.DBusMenu
import qs.components.text
import qs

DropdownWindow {
  id: menu
  padding: Global.format.radius_medium
  contentItem: items

  required property var model
  signal itemTriggered

  Menu {
    id: items
    model: menu.model
    onItemTriggered: menu.itemTriggered()
  }
}
