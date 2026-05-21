import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs

PopupWindow {
  id: root
  default property alias content: contentArea.data
  required property var window
  anchor.window: window
  anchor.edges: Edges.Top
  required property real x
  property real dist: 0
  anchor.rect.x: x
  anchor.rect.y: window.height + dist
  property Item contentItem: null
  property real padding: 0
  property real leftOffset: 0
  property real rightOffset: 0
  property bool showLeftCorner: false
  property bool showRightCorner: false
  property alias topLeftRadius: background.topLeftRadius
  property alias topRightRadius: background.topRightRadius
  property alias bottomLeftRadius: background.bottomLeftRadius
  property alias bottomRightRadius: background.bottomRightRadius
  property alias radius: background.radius
  property alias backgroundColor: background.color
  property alias hideTimer: hideTimer
  implicitWidth: contentItem
    ? (contentItem.implicitWidth + padding * 2 + leftOffset + rightOffset)
    : 1
  implicitHeight: contentItem ? (contentItem.implicitHeight + padding * 2) : 1
  color: "transparent"

  onVisibleChanged: {
    if (visible) { 
      hideTimer.running = true
      root.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
    }
  }

  Timer {
    id: hideTimer
    interval: Global.format.interval_short
    running: false
    repeat: false
    onTriggered: root.visible = false
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

    InnerCorner {
      visible: root.showLeftCorner && root.leftOffset > 0
      x: 0
      y: 0
      width: root.leftOffset
      height: root.leftOffset
      corner: "topRight"
      fillColor: background.color
    }

    Rectangle {
      id: background
      x: root.leftOffset
      y: 0
      width: parent.width - root.leftOffset - root.rightOffset
      height: parent.height
      radius: Global.format.radius_xlarge
      color: Global.colors.surface

      Item {
        id: contentArea
        x: root.padding
        y: root.padding
        width: parent.width - root.padding * 2
        height: parent.height - root.padding * 2
      }
    }

    InnerCorner {
      visible: root.showRightCorner && root.rightOffset > 0
      x: root.leftOffset + background.width
      y: 0
      width: root.rightOffset
      height: root.rightOffset
      corner: "topLeft"
      fillColor: background.color
    }
  }
}
