import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.components.bar
import qs.components.text

ModuleBase {
  id: audioRoot
  implicitWidth: row.implicitWidth + format.spacing_medium
  property PwNode defaultNode: Pipewire.defaultAudioSink

  RowLayout {
    id: row
    anchors.centerIn: parent
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 4

    PwObjectTracker { objects: [ Pipewire.defaultAudioSink ] }

    StyledText {
      id: volumeIcon
      text: defaultNode && defaultNode.audio.muted
        ? " 󰖁"
        : (defaultNode && defaultNode.audio.volume >= 0.60
          ? " 󰕾"
          : defaultNode && defaultNode.audio.volume >= 0.20
            ? " 󰖀"
            : " 󰕿")
    }

    StyledText {
      id: volumeText
      text: defaultNode
        ? Math.round(defaultNode.audio.volume * 100) + "%"
        : "—"
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.MiddleButton | Qt.RightButton
    onClicked: {
      if (mouse.button === Qt.MiddleButton && defaultNode) {
        defaultNode.audio.muted = !defaultNode.audio.muted
      }
    }
    onWheel: {
      if (!defaultNode) return
      const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
      defaultNode.audio.volume = Math.max(0.0, Math.min(1.0, defaultNode.audio.volume + delta))
    }
  }
}