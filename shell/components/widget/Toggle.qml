import QtQuick
import qs

Rectangle {
  id: toggleRoot

  property bool checked: false
  signal toggled()

  implicitWidth: Global.format.module_height * 2
  implicitHeight: Global.format.module_height
  radius: height / 2
  color: checked ? Global.colors.primary : Global.colors.surface_container_high

  Behavior on color {
    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
  }

  Rectangle {
    width: parent.height - 4
    height: parent.height - 4
    radius: height / 2
    anchors.verticalCenter: parent.verticalCenter
    x: toggleRoot.checked ? parent.width - width - 2 : 2
    color: toggleRoot.checked ? Global.colors.on_primary : Global.colors.on_surface_variant

    Behavior on x {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    Behavior on color {
      ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: toggleRoot.toggled()
  }
}
