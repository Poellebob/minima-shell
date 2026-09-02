import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.components.widget
import qs.components.text
import qs

Rectangle {
  id: itemRoot

  required property Notification notification

  readonly property color urgencyColor: {
    switch (notification.urgency) {
      case NotificationUrgency.Critical: return Global.colors.error
      case NotificationUrgency.Low:      return Global.colors.outline
      default:                           return Global.colors.primary
    }
  }

  implicitHeight: contentRow.implicitHeight + Global.format.spacing_medium * 2
  radius: Global.format.radius_medium
  color: hoverArea.containsMouse
    ? Global.colors.surface_container_high
    : Global.colors.surface_container

  Behavior on color {
    ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
  }

  // Left urgency stripe
  Rectangle {
    anchors {
      left:         parent.left
      top:          parent.top
      bottom:       parent.bottom
      topMargin:    Global.format.radius_medium
      bottomMargin: Global.format.radius_medium
    }
    width:  3
    radius: 2
    color:  itemRoot.urgencyColor
    opacity: 0.8
  }

  RowLayout {
    id: contentRow
    anchors {
      left:    parent.left
      right:   parent.right
      top:     parent.top
      margins: Global.format.spacing_medium
    }
    anchors.leftMargin: Global.format.spacing_medium + 6
    spacing: Global.format.spacing_medium

    // App icon
    Item {
      Layout.preferredWidth:  Global.format.big_icon_size
      Layout.preferredHeight: Global.format.big_icon_size
      Layout.alignment: Qt.AlignTop

      IconImage {
        id: appIcon
        anchors.fill: parent
        source: {
          if (itemRoot.notification.image && itemRoot.notification.image !== "")
            return itemRoot.notification.image
          if (itemRoot.notification.appIcon && itemRoot.notification.appIcon !== "")
            return Quickshell.iconPath(itemRoot.notification.appIcon, "dialog-information")
          return Quickshell.iconPath("dialog-information")
        }
        visible: status !== Image.Error
      }

      Text {
        anchors.centerIn: parent
        text: "󰂚"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.font_size_large
        color: itemRoot.urgencyColor
        visible: appIcon.status === Image.Error
      }
    }

    // Text block
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Global.format.spacing_tiny

      RowLayout {
        Layout.fillWidth: true
        spacing: Global.format.spacing_small

        Text {
          text: itemRoot.notification.appName || "Unknown"
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: Global.format.font_size_small
          font.bold: true
          color: itemRoot.urgencyColor
          elide: Text.ElideRight
          Layout.fillWidth: true
        }

        Text {
          text: {
            let d = new Date(itemRoot.notification.time * 1000)
            return Qt.formatDateTime(d, "HH:mm")
          }
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: Global.format.font_size_small
          color: Global.colors.outline
        }
      }

      Text {
        visible: (itemRoot.notification.summary ?? "") !== ""
        Layout.fillWidth: true
        text: itemRoot.notification.summary ?? ""
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        font.bold: true
        color: Global.colors.on_surface_variant
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
      }

      Text {
        visible: (itemRoot.notification.body ?? "") !== ""
        Layout.fillWidth: true
        text: itemRoot.notification.body ?? ""
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        color: Global.colors.outline
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight
      }

      // Action buttons
      Flow {
        visible: (itemRoot.notification.actions?.length ?? 0) > 0
        Layout.fillWidth: true
        spacing: Global.format.spacing_small

        Repeater {
          model: itemRoot.notification.actions ?? []

          StyledButton {
            required property var modelData

            implicitHeight: Global.format.module_height

            onClicked: {
              modelData.invoke()
              itemRoot.notification.dismiss()
            }

            text: modelData.text
            colorDefault: Global.colors.surface_container_highest
            colorHovered: Global.colors.primary_container
            colorPressed: Global.colors.primary
            colorText: Global.colors.on_surface_variant
          }
        }
      }
    }

    // Dismiss button
    StyledButton {
      Layout.preferredWidth:  Global.format.icon_size
      Layout.preferredHeight: Global.format.icon_size
      Layout.alignment: Qt.AlignTop
      text: "󰅖"

      onClicked: itemRoot.notification.dismiss()

      colorDefault: "transparent"
      colorHovered: Global.colors.error_container
      colorPressed: Global.colors.error
      colorText: Global.colors.outline
    }
  }

  MouseArea {
    id: hoverArea
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    propagateComposedEvents: true
  }
}
