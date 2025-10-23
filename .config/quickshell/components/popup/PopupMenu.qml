import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.DBusMenu
import qs.components.text
import qs.colors
import qs.format

PopupWindow {
  id: menu
  color: "transparent"

  readonly property Format format: Format {}
  // TODO: The color theme is hardcoded to dark.
  // This should be made dynamic.
  readonly property Colors colors: ColorsDark {}

  implicitWidth: 200
  implicitHeight: items.height + format.spacing_large + format.spacing_small

  property var model
  signal itemTriggered()

  Timer {
    id: hideTimer
    interval: format.interval_short
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
      color: colors.background
      implicitWidth: parent.width
      implicitHeight: parent.height
      bottomLeftRadius: format.radius_xlarge
      bottomRightRadius: format.radius_xlarge
      anchors.fill: parent

      ColumnLayout {
        id: items
        spacing: format.radius_medium
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
          model: menu.model
          anchors.verticalCenter: parent.verticalCenter

          Rectangle {
            required property QsMenuEntry modelData
            color: mouseArea.containsMouse && !modelData.isSeparator ? colors.surface_container_high : colors.surface_variant
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: menu.width - format.spacing_large
            implicitHeight: modelData.isSeparator ? 2 : format.icon_size
            radius: format.radius_large

            Behavior on color {
              ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
              }
            }

            StyledText {
              visible: !modelData.isSeparator
              anchors.fill: parent
              color: colors.on_background
              text: modelData.text
              anchors.left: parent.left
              anchors.leftMargin: format.font_size_small
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