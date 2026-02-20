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

  Component.onCompleted: displayInfo();

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
      text: "-%"
      horizontalAlignment: Text.AlignHCenter
    }
  }

  Timer {
    interval: Global.format.interval_xlong
    running: true
    repeat: true
    onTriggered: displayInfo() 
  }

  property bool p10: false
  property bool p5: false

  function displayInfo() {
    if(!UPower.displayDevice.ready) return

    percentageText.text = Math.round(UPower.displayDevice.percentage * 100) + "%"

    if (UPower.displayDevice.percentage * 100 < 10 && !p10) {
      p10 = true
      Quickshell.execDetached(["sh", "-c", "notify-send -u critical batary low"])
    }
    if (UPower.displayDevice.percentage * 100 < 5 && !p5) {
      p5 = true
      Quickshell.execDetached(["sh", "-c", "notify-send -u critical batary low"])
    }
    if (UPower.displayDevice.percentage * 100 > 10) {
      p5 = false
      p10 = false
    }

    batteryIcon.text = batteryRoot.getBatteryIcon(UPower.displayDevice.iconName)
  }

  function getBatteryIcon(name) {
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
    case "battery-full-charging-symbolic":
      return "󰂄";
    case "battery-charging-symbolic":
      return "󰂄";
    case "battery-low-charging-symbolic":
      return "󰂄";
    default:
      return "󰁹";
    }
  }
}
