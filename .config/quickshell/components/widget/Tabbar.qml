import QtQuick
import QtQuick.Layouts
import qs
import qs.components.widget

RowLayout {
  id: tabBarRoot

  property var model
  property int currentIndex: 0
  property alias delegate: repeater.delegate

  signal tabClicked(int index)

  spacing: Global.format.spacing_medium
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.top: parent.top
  height: Global.format.big_icon_size + Global.format.radius_small

  Repeater {
    id: repeater
    model: tabBarRoot.model
  }
}