import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.components.widget
import qs.components.text
import qs

BarWidget {
  id: audioRoot
  property PwNode defaultNode: Pipewire.defaultAudioSink

  signal audioMenuTriggered

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: Global.format.spacing_small

    PwObjectTracker {
      objects: [Pipewire.defaultAudioSink]
    }

    StyledText {
      id: volumeIcon
      text: defaultNode && defaultNode.audio.muted ? " 󰖁" : (defaultNode
                                                             && defaultNode.audio.volume
                                                             >= 0.60 ? " 󰕾" :
                                                                       defaultNode
                                                                       && defaultNode.audio.volume
                                                                       >= 0.20 ? " 󰖀" :
                                                                                 " 󰕿")
    }

    StyledText {
      id: volumeText
      text: defaultNode ? Math.round(defaultNode.audio.volume * 100) + "%" : "—"
    }
  }

  onClicked: mouse => {
               if (mouse.button === Qt.MiddleButton && defaultNode) {
                 defaultNode.audio.muted = !defaultNode.audio.muted;
               }

               if (mouse.button === Qt.LeftButton && defaultNode) {
                 audioMenuTriggered();
               }
             }

  onWheel: wheel => {
             if (!defaultNode)
             return;
             const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
             defaultNode.audio.volume = Math.max(0.0, Math.min(1.0,
                                                               defaultNode.audio.volume
                                                               + delta));
           }
}
