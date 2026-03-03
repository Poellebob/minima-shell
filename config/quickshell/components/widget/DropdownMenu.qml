import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.DBusMenu
import qs.components.text
import qs

DropdownWindow {
  id: menu
  color: "transparent"

  implicitWidth: 200
  implicitHeight: items.height + Global.format.spacing_large + Global.format.spacing_small

  required property var model
  signal itemTriggered()

  Timer {
    id: hideTimer
    interval: Global.format.interval_short
    running: false
    repeat: false
    onTriggered: menu.visible = false
  }

  Menu {
    anchors.fill: parent
    model: menu.model
  }
}
