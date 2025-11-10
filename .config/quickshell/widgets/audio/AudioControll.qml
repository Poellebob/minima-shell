import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.components.widget
import qs

DropdownWindow {
  id: menuRoot

  implicitWidth: 400
  color: "transparent"

  Timer {
    id: hideTimer
    interval: Global.format.interval_short
    running: false
    repeat: false
    onTriggered: {
      menuRoot.visible = false
    }
  }
  Rectangle {
    anchors.margins: Global.format.spacing_large
    anchors.topMargin: Global.format.spacing_medium
    anchors.fill: parent
    radius: Global.format.radius_large
    color: Global.colors.on_surface
    ColumnLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Global.format.spaceing_large
        height: Global.format.big_icon_size + Global.format.radius_small

        Rectangle {
          color: Global.colors.inverse_on_surface
          implicitHeight: parent.height
          Layout.fillWidth: true
          radius: Global.format.radius_large
        }

        
      }
    }
  }
}

