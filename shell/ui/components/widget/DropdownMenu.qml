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
  implicitHeight: items.implicitHeight + Global.format.radius_medium * 2

  required property var model
  signal itemTriggered

  Timer {
    id: hideTimer
    interval: Global.format.interval_short
    running: false
    repeat: false
    onTriggered: menu.visible = false
  }
  
  Menu {
    id: items
    anchors.margins: Global.format.radius_medium
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width
    height: parent.height - Global.format.radius_medium * 2
    model: menu.model
  }
}
