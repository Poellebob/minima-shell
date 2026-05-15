import QtQuick
import QtQuick.Controls
import qs

Slider {
  id: root

  background: Item {
    implicitWidth: 200
    implicitHeight: 24

    x: root.leftPadding
    y: root.topPadding
    width: root.availableWidth
    height: implicitHeight

    MouseArea {
      anchors.fill: parent
      onPressed: (mouse) => {
        let pos = Math.max(0, Math.min(1, mouse.x / width))
        root.value = root.from + pos * (root.to - root.from)
      }
    }

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width
      height: 4
      radius: 2
      color: Global.colors.surface_container_highest

      Rectangle {
        width: root.visualPosition * parent.width
        height: parent.height
        radius: 2
        color: Global.colors.primary
      }
    }
  }

  handle: Rectangle {
    implicitWidth: 16
    implicitHeight: 16

    x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
    y: root.topPadding + root.availableHeight / 2 - height / 2

    radius: 8
    color: Global.colors.secondary
  }
}
