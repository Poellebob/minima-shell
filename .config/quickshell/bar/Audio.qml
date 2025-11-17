import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.components.bar
import qs.components.text
import qs.widgets.audio
import qs

ModuleBase {
  id: audioRoot
  implicitWidth: row.implicitWidth + Global.format.spacing_medium
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

  onClicked: (mouse) => {
    if (mouse.button === Qt.MiddleButton && defaultNode) {
      defaultNode.audio.muted = !defaultNode.audio.muted
    }

    if (mouse.button === Qt.RightButton && defaultNode) {
      menu.visible = !menu.visible
      console.log(audioRoot.mapToGlobal(audioRoot.width / 2, 0).x - menu.width / 2)
      console.log((panel.width - audioRoot.parent.width) / 2 + audioRoot.x + (audioRoot.width - menu.width) / 2)
      console.log(typeof(audioRoot.mapToGlobal(audioRoot.width / 2, 0).x - menu.width / 2))
      console.log(typeof((panel.width - audioRoot.parent.width) / 2 + audioRoot.x + (audioRoot.width - menu.width) / 2))
    }
  }

  onWheel: (wheel) => {
    if (!defaultNode) return
    const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
    defaultNode.audio.volume = Math.max(0.0, Math.min(1.0, defaultNode.audio.volume + delta))
  }

  AudioControll {
    id: menu
    window: panel
    x: (panel.width - audioRoot.parent.width) / 2 + audioRoot.x + (audioRoot.width - width) / 2
  }
}
