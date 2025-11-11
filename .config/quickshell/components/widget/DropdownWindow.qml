import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

PopupWindow {
  id: menuRoot

  required property var window
  anchor.window: window
  anchor.edges: Edges.Top
  required property real x
  anchor.rect.x: x 
  anchor.rect.y: window.height

  Timer {
    id: hideTimer
    interval: Global.format.interval_short
    running: false
    repeat: false
    onTriggered: {
      menuRoot.visible = false
    }
  }

  MouseArea {
    id: menuMouseArea
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    propagateComposedEvents: true
    preventStealing: true

    onEntered: hideTimer.stop()
    onExited: hideTimer.restart()
    
    Rectangle {
      anchors.fill: parent
      color: Global.colors.surface
      bottomLeftRadius: Global.format.radius_xlarge
      bottomRightRadius: Global.format.radius_xlarge 
    }
  }
}
