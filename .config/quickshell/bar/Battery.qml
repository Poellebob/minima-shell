import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.components.bar
import qs.components.text
import qs

ModuleBase {
  id: batteryRoot
  implicitWidth: column.implicitWidth + Global.format.radius_xlarge
  visible: UPower.displayDevice.percentage == 0 ? false : true
  border.color: Global.colors.primary
  border.width: UPower.onBattery ? 0 : 1

  RowLayout {
    id: column
    anchors.centerIn: parent
    spacing: Global.format.spacing_tiny

    StyledText {
      id: batteryIcon
      horizontalAlignment: Text.AlignHCenter
    }

    StyledText {
      id: percentageText
      text: "NaN%"
      horizontalAlignment: Text.AlignHCenter
    }
  }

  Timer {
    interval: Global.format.interval_xlong
    running: true
    repeat: true
    onTriggered: displayInfo() 
  }

  function displayInfo() {
    // Force property refresh
    percentageText.text = UPower.displayDevice.ready
    ? Math.round(UPower.displayDevice.percentage * 100) + "%" : "—"

    batteryIcon.text = batteryRoot.getBatteryIcon(UPower.displayDevice.iconName)
  }

  function getBatteryIcon(name) {
    console.log(name)
    switch (name) {
    case "battery-empty-symbolic":
      return "󰂎";
    case "battery-caution-symbolic":
      return "󰂃";
    case "battery-low-symbolic":
      return "󱊡";
    case "battery-good-symbolic":
      return "󱊢";
    case "battery-full-symbolic":
      return "󱊣";
    case "battery-charging-symbolic":
      return "󰂄";
    case "battery-low-charging-symbolic":
      return "󰂄";
    default:
      return "󰁹";
    }
  }
}
