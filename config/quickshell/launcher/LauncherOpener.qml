import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components.widget
import qs

PanelWindow {
  anchors.bottom: true
  implicitWidth:  100
  implicitHeight: 15
  color: "transparent"
  exclusiveZone: 0

  MouseArea {
    id: mouseActive
    anchors.fill: parent
    hoverEnabled: true

    onClicked: {
      console.log("LauncherOpener clicked, calling Launcher.open()")
      Launcher.open()
    }
  }

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
  }
}
