import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.DBusMenu
import qs.components.text

PopupWindow {
  id: menu
  color: "transparent"
  implicitWidth: 200
  implicitHeight: items.height + panel.format.spacing_large + panel.format.spacing_small

  property var model
  signal itemTriggered()

  Timer {
    id: hideTimer
    interval: panel.format.interval_short
    running: false
    repeat: false
    onTriggered: menu.visible = false
  }

  MouseArea {
    id: menuMouseArea
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    propagateComposedEvents: true

    onEntered: hideTimer.stop()
    onExited: hideTimer.restart()

    Rectangle {
      id: rect
      color: panel.colors.background
      implicitWidth: parent.width
      implicitHeight: parent.height
      bottomLeftRadius: panel.format.radius_xlarge
      bottomRightRadius: panel.format.radius_xlarge
      anchors.fill: parent

      ColumnLayout {
        id: items
        spacing: panel.format.radius_medium
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
          model: menu.model
          anchors.verticalCenter: parent.verticalCenter

          Rectangle {
            required property QsMenuEntry modelData
            color: mouseArea.containsMouse && !modelData.isSeparator ? panel.colors.surface_container_high : panel.colors.surface_variant
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: menu.width - panel.format.spacing_large
            implicitHeight: modelData.isSeparator ? 2 : panel.format.icon_size
            radius: panel.format.radius_large

            Behavior on color {
              ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
              }
            }

            StyledText {
              visible: !modelData.isSeparator
              anchors.fill: parent
              color: panel.colors.on_background
              text: modelData.text
              anchors.left: parent.left
              anchors.leftMargin: panel.format.font_size_small
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
  }
}
