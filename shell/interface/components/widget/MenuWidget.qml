import QtQuick
import QtQuick.Layouts
import qs
import qs.components.text

Item {
  id: root
  default property alias content: contentArea.data
  property real padding: Global.format.spacing_large
  property alias backgroundColor: background.color
  signal closed()

  implicitWidth: contentArea.implicitWidth + padding * 2
  implicitHeight: contentArea.implicitHeight + padding * 2

  Rectangle {
    id: background
    anchors.fill: parent
    color: Global.colors.background

    Item {
      id: contentArea
      x: root.padding
      y: root.padding
      width: parent.width - root.padding * 2
      height: parent.height - root.padding * 2
    }
  }
}
