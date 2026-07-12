import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ExpandedPanel {
  id: clockExpanded

  property var date: new Date()

  function activate() {}
  function navigateUp() {}
  function navigateDown() {}

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: clockExpanded.date = new Date()
  }

  ColumnLayout {
    anchors.centerIn: parent
    spacing: Global.format.spacing_medium

    Text {
      text: Qt.formatDateTime(clockExpanded.date, "HH:mm:ss")
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.font_size_xlarge
      font.bold: true
      color: Global.colors.primary
      Layout.alignment: Qt.AlignCenter
    }

    Text {
      text: Qt.formatDateTime(clockExpanded.date, "dddd")
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.font_size_medium
      color: Global.colors.on_surface
      Layout.alignment: Qt.AlignCenter
    }

    Text {
      text: Qt.formatDateTime(clockExpanded.date, "MMMM d, yyyy")
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      color: Global.colors.on_surface_variant
      Layout.alignment: Qt.AlignCenter
    }
  }
}
