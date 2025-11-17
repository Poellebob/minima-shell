import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs
import qs.components.widget

RowLayout {
  id: tabBarRoot

  property var model
  property int selected: 0
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
      text: modelData.text
      iconSource: modelData.iconSource
       
      isSelected: tabBarRoot.selected == index ? true : false
      onClicked: {
        tabBarRoot.selected = index
      }
    }
  }
}
