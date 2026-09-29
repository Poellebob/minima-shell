import QtQuick
import QtQuick.Layouts
import qs
import qs.components.text

Item {
  id: root

  implicitWidth: Global.format.action_width
  implicitHeight: Global.format.action_height

  property string icon: ""
  property string text: ""
  property color baseColor: Global.colors.surface
  property color hoverColor: Global.colors.surface_container_high
  property color pressColor: Global.colors.surface_container_highest

  signal clicked(var mouse)

  Rectangle {
    id: background
    anchors.fill: parent
    color: mouseArea.containsPress ? root.pressColor : mouseArea.containsMouse ?
           root.hoverColor : root.baseColor

    Behavior on color {
      ColorAnimation {
        duration: 100
        easing.type: Easing.OutCubic
      }
    }

    ColumnLayout {
      anchors.centerIn: parent
      spacing: Global.format.spacing_tiny

      StyledText {
        text: root.icon
        font.pixelSize: Global.format.font_size_large
        Layout.alignment: Qt.AlignHCenter
      }

      StyledText {
        text: root.text
        font.pixelSize: Global.format.font_size_small
        Layout.alignment: Qt.AlignHCenter
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => root.clicked(mouse)
  }
}
