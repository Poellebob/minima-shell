import QtQuick
import qs

StyledText {
  id: root

  property color baseColor: Global.colors.on_surface_variant
  property color hoverColor: Global.colors.on_background
  property bool hoverEnabled: true
  property bool mouseEnabled: true
  property bool hoverOverride: false

  readonly property bool hovered: mouseEnabled ? mouseArea.containsMouse :
                                                 hoverOverride

  signal clicked(var mouse)
  signal doubleClicked(var mouse)
  signal wheel(var wheel)

  color: hovered ? hoverColor : baseColor

  Behavior on color {
    ColorAnimation {
      duration: 100
      easing.type: Easing.OutCubic
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    enabled: root.mouseEnabled
    hoverEnabled: root.hoverEnabled
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton

    onClicked: mouse => root.clicked(mouse)
    onDoubleClicked: mouse => root.doubleClicked(mouse)
    onWheel: wheel => root.wheel(wheel)
  }
}
