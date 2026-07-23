import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs

Item {
  id: root

  implicitHeight: 150

  required property NotificationServer notifServer
  readonly property var notifications: {
    const arr = notifServer.trackedNotifications.values.slice()
    arr.reverse()
    return arr
  }

  function clearAll() {
    for (let i = notifServer.trackedNotifications.values.length - 1; i >= 0; i--) {
      notifServer.trackedNotifications[i].dismiss()
    }
  }

  function urgencyColor(notif): color {
    switch (notif.urgency) {
      case NotificationUrgency.Critical: return Global.colors.error
      case NotificationUrgency.Low: return Global.colors.outline
      default: return Global.colors.primary
    }
  }

  function urgencyIcon(notif): string {
    switch (notif.urgency) {
      case NotificationUrgency.Critical: return "󰀪"
      case NotificationUrgency.Low: return "󰍡"
      default: return "󰂚"
    }
  }

  function formatTime(timestamp): string {
    let d = new Date(timestamp * 1000)
    return Qt.formatDateTime(d, "HH:mm")
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: Global.format.spacing_medium

    RowLayout {
      Layout.fillWidth: true
      spacing: Global.format.spacing_medium

      Text {
        text: "󰂚"
        color: Global.colors.primary
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
      }

      Text {
        text: "Notifications"
        color: Global.colors.on_surface_variant
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        font.bold: true
      }

      Text {
        visible: root.notifications.length > 0
        text: root.notifications.length + " unread"
        color: Global.colors.outline
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
      }

      Item { Layout.fillWidth: true }

      Text {
        visible: root.notifications.length > 0
        text: "Clear All"
        color: clearMouse.containsMouse ? Global.colors.error : Global.colors.on_surface_variant
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size

        MouseArea {
          id: clearMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.clearAll()
        }
      }
    }

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      Text {
        anchors.centerIn: parent
        visible: root.notifications.length === 0
        text: "No notifications"
        color: Global.colors.outline
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
      }

      ListView {
        id: notifList
        anchors.fill: parent
        orientation: ListView.Horizontal
        clip: true
        spacing: Global.format.spacing_medium
        currentIndex: 0
        highlightMoveDuration: 200
        model: root.notifications

        onModelChanged: {
          currentIndex = Math.min(currentIndex, count - 1)
          if (currentIndex >= 0) positionViewAtIndex(currentIndex, ListView.Center)
        }

        delegate: Item {
          id: notifItem
          required property Notification modelData
          required property int index
          width: 280
          height: notifList.height

          property string replyText: ""

          Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: notifList.currentIndex === notifItem.index
              ? Global.colors.tertiary
              : notifItemMouse.containsMouse
                ? Global.colors.on_surface
                : root.urgencyColor(modelData)
            border.width: 1

            MouseArea {
              id: notifItemMouse
              anchors.fill: parent
              hoverEnabled: true
              propagateComposedEvents: true
              onWheel: (wheel) => {
                if (wheel.angleDelta.x < 0 || wheel.angleDelta.y < 0) {
                  if (notifList.currentIndex < notifList.count - 1)
                    notifList.currentIndex++
                } else {
                  if (notifList.currentIndex > 0)
                    notifList.currentIndex--
                }
              }
            }

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: Global.format.spacing_small
              spacing: Global.format.spacing_small

              // Header: urgency/app icon, app name, resident pin, time, dismiss
              RowLayout {
                Layout.fillWidth: true
                spacing: Global.format.spacing_small

                IconImage {
                  visible: modelData.image !== "" || modelData.appIcon !== ""
                  source: modelData.image !== ""
                    ? modelData.image
                    : Quickshell.iconPath(modelData.appIcon)
                  implicitWidth: Global.format.text_size
                  implicitHeight: Global.format.text_size
                }

                Text {
                  visible: modelData.image === "" && modelData.appIcon === ""
                  text: root.urgencyIcon(modelData)
                  color: root.urgencyColor(modelData)
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: Global.format.text_size
                }

                Text {
                  text: modelData.appName || "Unknown"
                  color: root.urgencyColor(modelData)
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: Global.format.text_size
                  font.bold: true
                  elide: Text.ElideRight
                  Layout.fillWidth: true
                }

                Text {
                  visible: modelData.resident
                  text: "󰐃"
                  color: Global.colors.outline
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: Global.format.text_size
                }

                Text {
                  text: root.formatTime(modelData.time)
                  color: Global.colors.outline
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: Global.format.text_size
                }

                Text {
                  text: "󰅖"
                  color: dismissMouse.containsMouse ? Global.colors.error : Global.colors.on_surface_variant
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: Global.format.text_size

                  MouseArea {
                    id: dismissMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: notifItem.modelData.dismiss()
                  }
                }
              }

              // Summary
              Text {
                text: modelData.summary
                color: Global.colors.on_surface
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                maximumLineCount: 2
                elide: Text.ElideRight
              }

              // Body
              Text {
                visible: modelData.body !== ""
                text: modelData.body
                color: Global.colors.on_surface_variant
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.fillHeight: true
                maximumLineCount: 4
                elide: Text.ElideRight
                textFormat: modelData.hints?.["urgency"] !== undefined ? Text.PlainText : Text.PlainText
              }

              Item { Layout.fillHeight: true }

              // Actions
              Flow {
                Layout.fillWidth: true
                visible: modelData.actions.length > 0
                spacing: Global.format.spacing_small

                Repeater {
                  model: modelData.actions

                  delegate: Rectangle {
                    id: actionButton
                    required property NotificationAction modelData
                    required property int index

                    color: "transparent"
                    border.color: actionMouse.containsMouse ? Global.colors.primary : Global.colors.outline
                    border.width: 1
                    implicitWidth: actionLabel.implicitWidth + Global.format.spacing_small * 2
                    implicitHeight: actionLabel.implicitHeight + Global.format.spacing_small

                    RowLayout {
                      anchors.centerIn: parent
                      spacing: 4

                      Text {
                        visible: notifItem.modelData.hasActionIcons
                        text: actionButton.modelData.identifier
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Global.format.text_size
                        color: actionMouse.containsMouse ? Global.colors.primary : Global.colors.on_surface_variant
                      }

                      Text {
                        id: actionLabel
                        text: actionButton.modelData.text
                        color: actionMouse.containsMouse ? Global.colors.primary : Global.colors.on_surface_variant
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Global.format.text_size
                      }
                    }

                    MouseArea {
                      id: actionMouse
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: actionButton.modelData.invoke()
                    }
                  }
                }
              }

              // Inline reply
              RowLayout {
                visible: notifItem.modelData.hasInlineReply
                Layout.fillWidth: true
                spacing: Global.format.spacing_small

                Rectangle {
                  Layout.fillWidth: true
                  implicitHeight: replyInput.implicitHeight + Global.format.spacing_small
                  color: "transparent"
                  border.color: Global.colors.outline
                  border.width: 1

                  TextInput {
                    id: replyInput
                    anchors.fill: parent
                    anchors.margins: 4
                    color: Global.colors.on_surface
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Global.format.text_size
                    clip: true

                    Text {
                      visible: replyInput.text === ""
                      text: notifItem.modelData.inlineReplyPlaceholder || "Reply..."
                      color: Global.colors.outline
                      font.family: "JetBrainsMono Nerd Font"
                      font.pixelSize: Global.format.text_size
                    }

                    onAccepted: {
                      if (text !== "") {
                        notifItem.modelData.sendInlineReply(text)
                        text = ""
                      }
                    }
                  }
                }

                Text {
                  text: "󰒊"
                  color: sendMouse.containsMouse ? Global.colors.primary : Global.colors.on_surface_variant
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: Global.format.text_size

                  MouseArea {
                    id: sendMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (replyInput.text !== "") {
                        notifItem.modelData.sendInlineReply(replyInput.text)
                        replyInput.text = ""
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
