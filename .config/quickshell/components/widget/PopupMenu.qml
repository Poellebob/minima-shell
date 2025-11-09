import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.DBusMenu
import qs.components.text
import qs

DropdownWindow {
  id: menu
  color: "transparent"

  implicitWidth: 200
  implicitHeight: items.height + Global.format.spacing_large + Global.format.spacing_small

  required property var model
  signal itemTriggered()

  Timer {
    id: hideTimer
    interval: Global.format.interval_short
    running: false
    repeat: false
    onTriggered: menu.visible = false
  }

  ColumnLayout {
    id: items
    spacing: Global.format.radius_medium
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    Repeater {
      model: menu.model
      anchors.verticalCenter: parent.verticalCenter

      Rectangle {
        required property QsMenuEntry modelData
        color: mouseArea.containsMouse && !modelData.isSeparator ? Global.colors.surface_container_high : Global.colors.surface_variant
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: menu.width - Global.format.spacing_large
        implicitHeight: modelData.isSeparator ? 2 : Global.format.icon_size
        radius: Global.format.radius_large

        Behavior on color {
          ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }

        StyledText {
          visible: !modelData.isSeparator
          anchors.fill: parent
          color: Global.colors.on_background
          text: modelData.text
          anchors.left: parent.left
          anchors.leftMargin: Global.format.font_size_small
          verticalAlignment: Text.AlignVCenter
              horizontalAlignment: Text.AlignLeft
            }

            MouseArea {
              id: mouseArea
              anchors.fill: parent
              hoverEnabled: true

              onClicked: (event) => {
                if (event.button == Qt.LeftButton) {
                  modelData.triggered()
                  menu.itemTriggered()
                }
              }
            }
          }
        }
      }
}
