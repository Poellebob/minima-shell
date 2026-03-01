import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.components.widget
import qs

DropdownWindow {
  id: menuRoot
  
  implicitWidth: 600
  implicitHeight: 400

  Rectangle {
    anchors.fill: parent
    anchors.margins: Global.format.spacing_large
    radius: Global.format.radius_large
    color: Global.colors.surface_variant
    
    
  }
}
