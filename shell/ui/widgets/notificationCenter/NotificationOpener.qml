import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components.widget
import qs

PanelWindow {
  anchors.bottom: true
  anchors.right: true
  implicitWidth:  15
  implicitHeight: 15
  color: "transparent"
  exclusiveZone: 0

  MouseArea {
    id: mouseActive
    anchors.fill: parent
    hoverEnabled: true

    onClicked: NotificationMenu.open()

    Rectangle {
      color: Global.colors.surface
      implicitHeight: mouseActive.containsMouse ? parent.height : 1
      visible: mouseActive.containsMouse
      topRightRadius: height
      topLeftRadius: height

      anchors{
        bottom: parent.bottom
        left: parent.left
        right: parent.right
      }

      Behavior on implicitHeight {
        NumberAnimation{duration: 100}
      }

      Rectangle {
        visible: NotificationMenu.notifServer.trackedNotifications.values.length > 0
        width:  paret.width - Global.format.spacing_normal * 2
        height: prent.height - Global.format.spacing_noraml * 2
        radius: width / 2
        color:  Global.colors.primary
        anchors.fill: parent

        anchors {
          top:   parent.top
          right: parent.right
          margins: 2
        }
      }
    }
  }
}
