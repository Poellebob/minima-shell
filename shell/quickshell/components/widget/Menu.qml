import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.DBusMenu
import qs.components.text
import qs

ColumnLayout {
  id: items
  required property var model
  signal itemTriggered

  spacing: Global.format.spacing_small

  onModelChanged: {
    visible = false
    itemRepeater.model = items.model
    visible = true
  }

  Repeater {
    model: items.model

    Rectangle {
      required property QsMenuEntry modelData
      Layout.fillWidth: true
      color: mouseArea.containsMouse && !modelData.isSeparator
        ? Global.colors.surface_container_high
        : Global.colors.surface_variant
      radius: Global.format.radius_large
      implicitWidth: modelData.isSeparator
        ? 0
        : Math.max(200, label.implicitWidth + Global.format.spacing_large * 2)
      implicitHeight: modelData.isSeparator
        ? 2
        : Global.format.icon_size

      Behavior on color {
        ColorAnimation {
          duration: 150
          easing.type: Easing.OutCubic
        }
      }

      StyledText {
        id: label
        visible: !modelData.isSeparator
        anchors.left: parent.left
        anchors.leftMargin: Global.format.font_size_small
        anchors.right: parent.right
        anchors.rightMargin: Global.format.font_size_small
        anchors.verticalCenter: parent.verticalCenter
        color: Global.colors.on_background
        text: modelData.text
        verticalAlignment: Text.AlignVCenter
      }

      MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: (event) => {
          if (event.button == Qt.LeftButton) {
            modelData.triggered()
            items.itemTriggered()
          }
        }
      }
    }
  }
}
