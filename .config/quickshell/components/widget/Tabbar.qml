import QtQuick
import QtQuick.Layouts
import qs
import qs.components.widget

RowLayout {
  id: tabBarRoot

  property var model
  property var selected
  property alias delegate: repeater.delegate
  readonly property alias count: repeater.count

  signal clicked(var tab)

  spacing: Global.format.spacing_medium
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.top: parent.top
  height: Global.format.big_icon_size + Global.format.radius_small

  Repeater {
    id: repeater
    model: tabBarRoot.model
    delegate: Tab {
      text: model.text
      iconSource: model.iconSource

      onClicked: {
        tabBarRoot.selected = model
      }
    }
  }
}
