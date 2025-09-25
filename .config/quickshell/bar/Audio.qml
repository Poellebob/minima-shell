import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.colors

Item {
  id: audioRoot

  implicitHeight: rect.implicitHeight
  implicitWidth: rect.implicitWidth
  property PwNode defaultNode: Pipewire.defaultAudioSink

  Rectangle {
    id: rect
    color: panel.colors.dark_surface_variant
    radius: panel.format.radius_small
    implicitHeight: panel.format.module_height
    implicitWidth: row.implicitWidth + panel.format.spacing_medium

    RowLayout {
      id: row
      anchors.centerIn: parent
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 4
      PwObjectTracker { objects: [ Pipewire.defaultAudioSink ] }
      Text {
        id: volumeIcon
        text: defaultNode && defaultNode.audio.muted
          ? " 󰖁"
          : (defaultNode && defaultNode.audio.volume >= 0.60
            ? " 󰕾"
            : defaultNode && defaultNode.audio.volume >= 0.20
            ? " 󰖀"
            : " 󰕿")
        font.pixelSize: panel.format.text_size
        color: panel.colors.dark_on_surface_variant
      }

      Text {
        id: volumeText
        text: defaultNode
          ? Math.round(defaultNode.audio.volume * 100) + "%"
          : "—"
        font.pixelSize: panel.format.text_size
        color: panel.colors.dark_on_surface_variant
      }
    }
  }
}
