import QtQuick
import qs

ModuleBase {
  id: batteryModule

  property int percentage: 0
  property bool charging: false

  icon: "󰁹"
  label: percentage + "%"
  visible: percentage > 0

  Timer {
    interval: Global.format.interval_xlong
    running: true
    repeat: true
    onTriggered: batteryModule.updateBattery()
  }

  function updateBattery() {
    // Placeholder: will use UPower
  }
}
