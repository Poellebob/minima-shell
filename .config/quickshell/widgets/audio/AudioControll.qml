import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.components.widget
import qs

DropdownWindow {
  id: menuRoot
  implicitWidth: 400
  color: "transparent"
  
  Timer {
    id: hideTimer
    interval: Global.format.interval_short
    running: false
    repeat: false
    onTriggered: {
      menuRoot.visible = false
    }
  }
  
  Rectangle {
    anchors.margins: Global.format.spacing_large
    anchors.topMargin: Global.format.spacing_medium
    anchors.fill: parent
    radius: Global.format.radius_large
    color: Global.colors.on_surface
    
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Global.format.spacing_large
      spacing: Global.format.spacing_medium
      
      Tabbar {
        id: tabs
        model: [
          {text: "hello"},
          {text: "joho"}
        ]
      }
    }
  }
}
