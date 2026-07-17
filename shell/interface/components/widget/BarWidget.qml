import QtQuick
import QtQuick.Layouts
import qs
import qs.components.text

Item {
  id: root
  implicitHeight: Global.format.module_height
  implicitWidth: contentArea.children.length > 0
    ? contentArea.implicitWidth + Global.format.spacing_medium * 2
    : label.implicitWidth + Global.format.spacing_medium * 2

  property string text: ""
  default property alias content: contentArea.data

  signal clicked(var mouse)
  signal wheel(var wheel)

  StyledText {
    id: label
    visible: root.text !== ""
    text: root.text
    anchors.centerIn: parent
  }

  Item {
    id: contentArea
    anchors.centerIn: parent
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height
    visible: root.text === ""
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    propagateComposedEvents: true

    onClicked: (mouse) => {
      mouse.accepted = false
      root.clicked(mouse)
    }

    onWheel: (wheel) => {
      wheel.accepted = false
      root.wheel(wheel)
    }
  }
}
