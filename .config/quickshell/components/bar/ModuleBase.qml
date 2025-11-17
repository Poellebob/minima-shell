import QtQuick
import qs

Rectangle {
  id: moduleBase
  implicitHeight: Global.format.module_height
  color: Global.colors.surface_variant
  radius: Global.format.radius_small
  
  signal clicked(var mouse)
  signal wheel(var wheel)

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.MiddleButton | Qt.RightButton
    onClicked: (mouse) => moduleBase.clicked(mouse)
    onWheel: (wheel) => moduleBase.wheel(wheel)
  }
}
