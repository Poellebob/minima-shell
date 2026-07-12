import QtQuick
import qs

ModuleBase {
  id: bluetoothModule

  property bool enabled: false
  property string deviceName: ""

  icon: enabled ? "󰂯" : "󰂲"
  label: enabled ? (deviceName || "BT") : "Off"

  Timer {
    interval: Global.format.interval_medium
    running: true
    repeat: true
    onTriggered: bluetoothModule.updateBluetooth()
  }

  function updateBluetooth() {
    // Placeholder: will use bluetoothctl
  }
}
