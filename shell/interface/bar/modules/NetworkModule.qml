import QtQuick
import qs

ModuleBase {
  id: networkModule

  property string networkName: "Disconnected"
  property int signalStrength: 0
  property bool connected: false

  icon: connected ? "󰤨" : "󰤭"
  label: connected ? networkName : "Offline"

  Timer {
    interval: Global.format.interval_medium
    running: true
    repeat: true
    onTriggered: networkModule.updateNetwork()
  }

  function updateNetwork() {
    // Placeholder: will use nmcli
  }
}
