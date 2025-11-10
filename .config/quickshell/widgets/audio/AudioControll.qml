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
      
      RowLayout {
        id: tabLayout
        spacing: Global.format.spacing_medium
        Layout.fillWidth: true
        Layout.preferredHeight: Global.format.big_icon_size + Global.format.radius_small
        
        Rectangle {
          id: tab1
          implicitHeight: parent.height
          Layout.fillWidth: true
          radius: Global.format.radius_large
          color: Global.colors.surface
          
          Behavior on color {
            ColorAnimation {
              duration: 150
              easing.type: Easing.OutCubic
            }
          }
        }
        
        Rectangle {
          id: tab2
          implicitHeight: parent.height
          Layout.fillWidth: true
          radius: Global.format.radius_large
          color: Global.colors.surface
          
          Behavior on color {
            ColorAnimation {
              duration: 150
              easing.type: Easing.OutCubic
            }
          }
        }
      }
    }
  }
}
