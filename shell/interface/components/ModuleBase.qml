import QtQuick
import qs

Rectangle {
  id: moduleBase

  property bool isActive: false
  property bool isFocused: false
  property string label: ""
  property string icon: ""

  implicitHeight: Global.format.module_height
  implicitWidth: row.implicitWidth + Global.format.module_padding * 2
  radius: Global.format.radius_small
  color: isFocused ? Global.colors.primary_container : Global.colors.surface_variant
  border.width: isFocused ? Global.format.focus_border_width : 0
  border.color: Global.colors.primary

  signal activated()
  signal wheel(var wheel)

  Behavior on color {
    ColorAnimation { duration: 150 }
  }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Global.format.spacing_small

    Text {
      visible: moduleBase.icon !== ""
      text: moduleBase.icon
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      color: moduleBase.isFocused ? Global.colors.on_primary : Global.colors.on_surface_variant
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      visible: moduleBase.label !== ""
      text: moduleBase.label
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      color: moduleBase.isFocused ? Global.colors.on_primary : Global.colors.on_surface_variant
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    onClicked: moduleBase.activated()
    onWheel: (wheel) => moduleBase.wheel(wheel)
  }

  Keys.onReturnPressed: moduleBase.activated()
  Keys.onEnterPressed: moduleBase.activated()
}
