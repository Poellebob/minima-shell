import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs

PanelWindow {
  id: windowRoot
  property var clipboardEntries: []
  property string searchText: ""

  implicitWidth: 600
  implicitHeight: 400
  visible: false
  exclusiveZone: 0
  aboveWindows: true
  color: "transparent"
  focusable: true

  Rectangle {
    anchors.fill: parent
    topLeftRadius: windowRoot.anchors.top || windowRoot.anchors.left ? 0 : Global.format.radius_xlarge + Global.format.spacing_small
    topRightRadius: windowRoot.anchors.top || windowRoot.anchors.right ? 0 : Global.format.radius_xlarge + Global.format.spacing_small
    bottomLeftRadius: windowRoot.anchors.bottom || windowRoot.anchors.left ? 0 : Global.format.radius_xlarge + Global.format.spacing_small
    bottomRightRadius: windowRoot.anchors.bottom || windowRoot.anchors.right ? 0 : Global.format.radius_xlarge + Global.format.spacing_small
    color: Global.colors.surface_variant
  }
}
