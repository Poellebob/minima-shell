import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs

PanelWindow {
  id: windowRoot
  property int menuWidth: 600
  property int menuHeight: 400
  property var clipboardEntries: []
  property string searchText: ""

  property bool floating: false
  
  anchors {
    left: true
    bottom: true
    right: true
  }
  
  margins {
    left: (Screen.width - menuWidth) / 2
    right: (Screen.width - menuWidth) / 2
    bottom: floating ? (Screen.height - menuHeight) / 2 : 0
  }
  
  implicitHeight: menuHeight
  visible: false
  exclusiveZone: 0
  aboveWindows: true
  color: "transparent"
  focusable: true

  Rectangle {
    anchors.fill: parent
    topLeftRadius: Global.format.radius_xlarge + Global.format.spacing_small
    topRightRadius: Global.format.radius_xlarge + Global.format.spacing_small
    bottomLeftRadius: windowRoot.floating ? Global.format.radius_xlarge + Global.format.spacing_small : 0
    bottomRightRadius: windowRoot.floating ? Global.format.radius_xlarge + Global.format.spacing_small : 0
    color: Global.colors.surface_variant
  }
}
