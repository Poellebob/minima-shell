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
  
  Rectangle {
    anchors.margins: Global.format.spacing_large
    anchors.topMargin: Global.format.spacing_medium
    anchors.fill: parent
    radius: Global.format.radius_large
    color: Global.colors.inverse_on_surface
    
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Global.format.spacing_large
      spacing: Global.format.spacing_medium
      
      Tabbar {
        id: tabs
        model: [
          {text: "Devices"},
          {text: "Sourses"}
        ]
      }

      
    }
  }
}
