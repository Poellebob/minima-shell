//@ pragma UseQApplication
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.components.widget
import qs.components.text
import qs
pragma Singleton
MenuPanel {
  id: notifRoot
  implicitWidth: 380
  implicitHeight: 550
  WlrLayershell.layer: WlrLayer.Overlay
  anchors {
    bottom: true
    right: true
  }
  onVisibleChanged: {
    if (visible) {
      notifRoot.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
      panelItem.forceActiveFocus()
    } else {
      notifRoot.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
    }
  }
  function open(): void {
    notifRoot.visible = !notifRoot.visible
  }
  NotificationServer {
    id: notifServer
    keepOnReload: true
    actionsSupported: true
    imageSupported:   true
    bodySupported:    true
    onNotification: (notif) => {
      notif.tracked = true
      console.log(notifServer.trackedNotifications.values.length)
    }
  }
  Item {
    id: panelItem
    anchors.fill: parent
    focus: true
    activeFocusOnTab: true
    Keys.onEscapePressed: notifRoot.visible = false
    Rectangle {
      anchors.fill: parent
      topLeftRadius:  Global.format.radius_xlarge + Global.format.spacing_small
      topRightRadius: Global.format.radius_xlarge + Global.format.spacing_small
      color: Global.colors.surface_variant
      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Global.format.spacing_large
        spacing: Global.format.spacing_medium
        RowLayout {
          Layout.fillWidth: true
          spacing: Global.format.spacing_medium
          Text {
            text: "󰂚"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.font_size_large
            color: Global.colors.primary
          }
          Text {
            text: "Notifications"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.font_size_large
            font.bold: true
            color: Global.colors.on_surface_variant
          }
          Text {
            visible: notifServer.trackedNotifications.values.length > 0
            text: notifServer.trackedNotifications.values.length + " unread"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            color: Global.colors.outline
          }
          Item { Layout.fillWidth: true }
          StyledButton {
            visible: notifServer.trackedNotifications.values.length > 0
            implicitHeight: Global.format.module_height
            onClicked: {
              for (let i = notifServer.trackedNotifications.values.length - 1; i >= 0; i--) {
                notifServer.trackedNotifications[i].dismiss()
              }
            }
            text: "Clear All"
            colorDefault: Global.colors.error_container
            colorHovered: Global.colors.error
            colorPressed: Global.colors.error
            colorText: Global.colors.on_error_container
          }
        }
        Rectangle {
          Layout.fillWidth:  true
          Layout.fillHeight: true
          radius: Global.format.radius_large
          color:  Global.colors.surface
          Text {
            anchors.centerIn: parent
            visible: notifServer.trackedNotifications.values.length === 0
            text: "No notifications"
            color: Global.colors.outline
            font.pixelSize: Global.format.text_size
            font.family: "JetBrainsMono Nerd Font"
          }
          ListView {
            id: notifList
            anchors.fill: parent
            anchors.margins: Global.format.spacing_small
            spacing: Global.format.spacing_tiny
            clip: true
            model: {
              let arr = notifServer.trackedNotifications.values.slice()
              arr.reverse()
              return arr
            }
            populate: Transition {
              NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
            }
            add: Transition {
              NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
              NumberAnimation { property: "height";  from: 0;        duration: 150 }
            }
            remove: Transition {
              NumberAnimation { property: "opacity"; to: 0; duration: 100 }
            }
            delegate: NotificationItem {
              required property var modelData
              notification: modelData
              width: notifList.width - scrollBar.width
            }
            ScrollBar.vertical: ScrollBar {
              id: scrollBar
              policy: ScrollBar.AsNeeded
            }
          }
        }
      }
    }
  }
}
