import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.components.widget
import qs.components.text
import qs

BarWidget {
  id: root

  signal notificationMenuTriggered

  readonly property var notifServer: _notifServer
  readonly property int notifCount:
    _notifServer.trackedNotifications.values.length

  implicitWidth: text.implicitWidth

  NotificationServer {
    id: _notifServer
    keepOnReload: true
    actionsSupported: true
    imageSupported: true
    bodySupported: true
    onNotification: notif => {
                      notif.tracked = true;
                      console.log("Notification received:");
                      console.log("  appName:", notif.appName);
                      console.log("  appIcon:", notif.appIcon);
                      console.log("  summary:", notif.summary);
                      console.log("  body:", notif.body);
                      console.log("  urgency:", notif.urgency);
                      console.log("  time:", notif.time);
                      console.log("  image:", notif.image);
                      console.log("  actions:", notif.actions);
                      console.log("  resident:", notif.resident);
                      console.log("  hasInlineReply:", notif.hasInlineReply);
                    }
  }

  onClicked: mouse => {
               if (mouse.button === Qt.LeftButton)
               notificationMenuTriggered();
             }

  StyledText {
    id: text
    anchors.centerIn: parent
    text: "󰂚" + (root.notifCount == 0 ? "" : (root.notifCount > 99 ? " 99+" :
                                                                     " " + root.notifCount.toString(
                                                                       )))
    color: root.notifCount > 0 ? Global.colors.primary :
                                 Global.colors.on_surface_variant
  }
}
