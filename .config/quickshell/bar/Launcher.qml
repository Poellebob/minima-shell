import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

TextField {
  id: launcherRoot
  anchors.fill: parent
  anchors.margins: panel.format.spacing_tiny
  visible: parent.width > 50
  color: "white"
  font.pixelSize: panel.format.text_size
  verticalAlignment: TextInput.AlignVCenter
  placeholderText: "type> for command"
  background: Rectangle{
    anchors.fill: parent
    color: panel.colors.surface
    radius: panel.format.radius_medium
  }
}