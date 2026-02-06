import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import qs

PanelWindow {
  id: WindowRoot
  property int menuWidth: 600
  property var clipboardEntries: []
  property string searchText: ""
  
  anchors {
    left: true
    bottom: true
    right: true
  }
  
  margins {
    left: (Screen.width - menuWidth) / 2
    right: (Screen.width - menuWidth) / 2
    bottom: 0
  }
  
  implicitHeight: 400
  visible: false
  exclusiveZone: 0
  aboveWindows: true
  color: "transparent"
  focusable: true
  
  HyprlandFocusGrab {
    id: grab
    windows: [clipboardManagerRoot]
  }


}
