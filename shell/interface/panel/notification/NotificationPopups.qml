import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs
import qs.components.text

PopupWindow {
  id: root

  required property var panel

  function urgencyColor(urgency): color {
    switch (urgency) {
    case NotificationUrgency.Critical:
      return Global.colors.error;
    case NotificationUrgency.Low:
      return Global.colors.outline;
    default:
      return Global.colors.primary;
    }
  }
  function urgencyIcon(urgency): string {
    switch (urgency) {
    case NotificationUrgency.Critical:
      return "󰀪";
    case NotificationUrgency.Low:
      return "󰍡";
    default:
      return "󰂚";
    }
  }

  color: "transparent"
  implicitHeight: Global.format.panel_height
  implicitWidth: popupRow.implicitWidth
  visible: popupModel.count > 0

  anchor {
    window: root.panel

    rect {
      x: root.panel.width - 1
      y: 0
      width: 1
      height: 1
    }

    edges: Edges.Top | Edges.Right
    gravity: Edges.Top | Edges.Left
    adjustment: PopupAdjustment.None
  }

  Connections {
    function onNotification(notif) {
      if (notif.lastGeneration)
        return;
      if (!Wm.isPrimaryScreen(root.panel.screen.name))
        return;
      popupModel.insert(0, {
        "appIcon": notif.appIcon,
        "body": notif.body,
        "image": notif.image,
        "summary": notif.summary,
        "urgency": notif.urgency
      });
    }

    target: Global.notifServer
  }

  ListModel {
    id: popupModel
  }

  Row {
    id: popupRow

    anchors.fill: parent

    Repeater {
      model: popupModel

      delegate: Rectangle {
        id: popup

        required property string appIcon
        required property string body
        required property string image
        required property string summary
        required property int urgency
        required property int index

        color: Global.colors.surface_container
        height: parent.height
        width: 280

        Timer {
          interval: Global.format.interval_long
          running: true
          onTriggered: popupModel.remove(popup.index)
        }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: Global.format.spacing_small
          anchors.rightMargin: Global.format.spacing_small
          spacing: Global.format.spacing_small

          IconImage {
            Layout.alignment: Qt.AlignVCenter
            visible: popup.image !== "" || popup.appIcon !== ""
            source: popup.image !== "" ? popup.image : Quickshell.iconPath(
                                          popup.appIcon)
            implicitWidth: Global.format.text_size
            implicitHeight: Global.format.text_size
          }

          StyledText {
            Layout.alignment: Qt.AlignVCenter
            visible: popup.image === "" && popup.appIcon === ""
            text: root.urgencyIcon(popup.urgency)
            color: root.urgencyColor(popup.urgency)
          }

          StyledText {
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: Math.round(popup.width * 0.6)
            color: Global.colors.on_surface
            elide: Text.ElideRight
            font.bold: true
            maximumLineCount: 1
            text: popup.summary
          }

          StyledText {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            visible: popup.body !== ""
            color: Global.colors.on_surface_variant
            elide: Text.ElideRight
            maximumLineCount: 1
            text: popup.body
          }
        }
      }
    }
  }
}
