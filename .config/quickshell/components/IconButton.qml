import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Rectangle {
    property string icon
    property bool enabled: true
    signal clicked()
    
    radius: panel.format.radius_small
    color: enabled ? (mouseArea.containsMouse ? panel.colors.dark_surface : "transparent") : "transparent"
    opacity: enabled ? 1.0 : 0.5
    
    IconImage {
      anchors.centerIn: parent
      width: parent.width * 0.9
      height: parent.height * 0.9
      source: icon
    }
    
    MouseArea {
      id: mouseArea
      anchors.fill: parent
      enabled: parent.enabled
      hoverEnabled: true
      propagateComposedEvents: true
      onClicked: {
        parent.clicked()
        mouse.accepted = true
      }
    }
    
    Behavior on color {
      ColorAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }
  }