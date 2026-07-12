import QtQuick
import qs

ModuleBase {
  id: audioModule

  property int volume: 0
  property bool muted: false

  icon: muted ? "󰖁" : (volume >= 60 ? "󰕾" : (volume >= 20 ? "󰖀" : "󰕿"))
  label: muted ? "Mute" : volume + "%"

  Timer {
    interval: Global.format.interval_short
    running: true
    repeat: true
    onTriggered: audioModule.updateVolume()
  }

  function updateVolume() {
    // Placeholder: will use PipeWire
  }

  onActivated: {
    // Toggle mute
    muted = !muted
  }

  onWheel: (wheel) => {
    if (wheel.angleDelta.y > 0) {
      volume = Math.min(100, volume + 5)
    } else {
      volume = Math.max(0, volume - 5)
    }
  }
}
