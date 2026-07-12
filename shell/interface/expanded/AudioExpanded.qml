import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ExpandedPanel {
  id: audioExpanded

  property int currentVolume: 50
  property bool isMuted: false

  function activate() { isMuted = !isMuted }
  function navigateUp() { currentVolume = Math.min(100, currentVolume + 5) }
  function navigateDown() { currentVolume = Math.max(0, currentVolume - 5) }

  RowLayout {
    Layout.fillWidth: true

    Text {
      text: isMuted ? "󰖁" : "󰕾"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.font_size_large
      color: Global.colors.primary
    }

    ColumnLayout {
      Layout.fillWidth: true

      Text {
        text: isMuted ? "Muted" : currentVolume + "%"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        color: Global.colors.on_surface
      }

      Rectangle {
        Layout.fillWidth: true
        height: 4
        radius: 2
        color: Global.colors.surface_variant

        Rectangle {
          width: parent.width * (currentVolume / 100)
          height: parent.height
          radius: parent.radius
          color: Global.colors.primary
        }
      }
    }
  }
}
