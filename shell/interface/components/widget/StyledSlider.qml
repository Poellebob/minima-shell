import QtQuick
import QtQuick.Layouts
import qs

Item {
  id: root
  implicitWidth: 150
  implicitHeight: 18

  property real from: 0
  property real to: 100
  property real value: 0

  signal moved(real value)

  property real _ratio: (value - from) / (to - from)

  Rectangle {
    id: track
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.right: parent.right
    height: 2
    color: Global.colors.surface_container_highest

    Rectangle {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: parent.width * root._ratio
      color: Global.colors.primary
    }
  }

  Rectangle {
    id: handle
    anchors.verticalCenter: parent.verticalCenter
    x: (parent.width - width) * root._ratio
    width: 10
    height: 14
    color: Global.colors.primary

    Behavior on x {
      NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: (mouse) => {
      const ratio = Math.max(0, Math.min(1, mouse.x / width))
      const newVal = from + ratio * (to - from)
      root.value = newVal
      root.moved(newVal)
    }

    onPositionChanged: (mouse) => {
      if (pressed) {
        const ratio = Math.max(0, Math.min(1, mouse.x / width))
        const newVal = from + ratio * (to - from)
        root.value = newVal
        root.moved(newVal)
      }
    }
  }
}
