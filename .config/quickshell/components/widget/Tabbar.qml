import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.components.widget
import qs

RowLayout {
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.top: parent.top
  anchors.margins: Global.format.spaceing_large
  height: Global.format.big_icon_size + Global.format.radius_small

  Rectangle {
    color: Global.colors.inverse_on_surface
    implicitHeight: parent.height
    Layout.fillWidth: true
    radius: Global.format.radius_large
  }


}
