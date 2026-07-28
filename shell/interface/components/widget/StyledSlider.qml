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
  signal doneMoving(real value)

  readonly property real _ratio: {
    if (to === from)
      return 0

    return Math.max(0, Math.min(1, (value - from) / (to - from)))
  }

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
      NumberAnimation {
        duration: 80
        easing.type: Easing.OutCubic
      }
    }
  }

  MouseArea {
    anchors.fill: parent

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    function updateValue(mouseX) {
      const ratio = Math.max(0, Math.min(1, mouseX / width))
      const newValue = from + ratio * (to - from)

      root.value = Math.max(from, Math.min(to, newValue))
      root.moved(root.value)
    }

    onClicked: (mouse) => {
      updateValue(mouse.x)
      root.doneMoving(root.value)
    }

    onPositionChanged: (mouse) => {
      if (!pressed)
        return

      updateValue(mouse.x)
    }

    onReleased: {
      root.doneMoving(root.value)
    }
  }
}
