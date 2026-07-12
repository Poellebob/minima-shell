import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ExpandedPanel {
  id: notificationExpanded

  property var notifications: []
  property int selectedIndex: 0

  function activate() {}
  function navigateUp() { selectedIndex = Math.max(0, selectedIndex - 1) }
  function navigateDown() { selectedIndex = Math.min(notifications.length - 1, selectedIndex + 1) }

  ColumnLayout {
    anchors.fill: parent
    spacing: Global.format.spacing_small

    RowLayout {
      Layout.fillWidth: true

      Text {
        text: "Notifications"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.font_size_medium
        font.bold: true
        color: Global.colors.on_surface
        Layout.fillWidth: true
      }

      Text {
        text: notifications.length + " unread"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        color: Global.colors.on_surface_variant
      }
    }

    ListView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      model: notificationExpanded.notifications

      delegate: Rectangle {
        width: ListView.view.width
        height: 48
        radius: Global.format.radius_small
        color: index === notificationExpanded.selectedIndex ? Global.colors.primary_container : "transparent"

        RowLayout {
          anchors.fill: parent
          anchors.margins: Global.format.spacing_small

          Rectangle {
            width: 4
            height: parent.height
            radius: 2
            color: modelData.urgency === "critical" ? Global.colors.error : Global.colors.primary
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
              text: modelData.appName
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: Global.format.font_size_small
              color: Global.colors.primary
            }

            Text {
              text: modelData.summary
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: Global.format.text_size
              color: Global.colors.on_surface
              elide: Text.ElideRight
              maximumLineCount: 1
              Layout.fillWidth: true
            }
          }
        }
      }
    }

    Text {
      visible: notificationExpanded.notifications.length === 0
      text: "No notifications"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      color: Global.colors.on_surface_variant
      Layout.alignment: Qt.AlignCenter
    }
  }
}
