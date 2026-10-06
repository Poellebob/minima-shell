import QtQuick
import qs.components.widget
import qs.components.text
import qs

BarWidget {
  id: root

  signal notificationMenuTriggered

  readonly property var notifServer: Global.notifServer
  readonly property int notifCount:
    root.notifServer.trackedNotifications.values.length

  implicitWidth: text.implicitWidth

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
