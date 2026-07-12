import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ExpandedPanel {
  id: workspaceExpanded

  function activate() {}
  function navigateUp() {}
  function navigateDown() {}

  Text {
    text: "Workspace Selector"
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: Global.format.font_size_medium
    color: Global.colors.on_surface
    Layout.alignment: Qt.AlignCenter
  }
}
