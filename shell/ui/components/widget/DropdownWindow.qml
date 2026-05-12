import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

PopupWindow {
  id: menuRoot
  default property alias content: menuMouseArea.data

  required property var window
  anchor.window: window
  anchor.edges: Edges.Top
  required property real x
  property real dist: 0
  anchor.rect.x: x
  anchor.rect.y: window.height + dist
  color: "transparent"

  property alias topLeftRadius: rect.topLeftRadius
  property alias topRightRadius: rect.topRightRadius
  property alias bottomLeftRadius: rect.bottomLeftRadius
  property alias bottomRightRadius: rect.bottomRightRadius

  onVisibleChanged: {
    if (visible) {
      menuRoot.raise()
      menuRoot.requestActivate()
    }
  }

  Timer {
    id: hideTimer
    interval: Global.format.interval_short
    running: false
    repeat: false
    onTriggered: {
      menuRoot.visible = false;
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
      id: rect
      anchors.fill: parent
      color: Global.colors.surface
      topLeftRadius: Global.format.radius_xlarge
      topRightRadius: Global.format.radius_xlarge
      bottomLeftRadius: Global.format.radius_xlarge
      bottomRightRadius: Global.format.radius_xlarge
    }
  }
}
