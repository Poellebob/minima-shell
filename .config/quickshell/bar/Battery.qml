import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.components.bar
import qs.components.text

ModuleBase {
  id: batteryRoot
  implicitWidth: column.implicitWidth + panel.format.radius_xlarge
  visible: UPower.displayDevice.percentage == 0 ? false : true
  border.color: panel.colors.primary
  border.width: UPower.onBattery ? 0 : 1

  RowLayout {
    id: column
    anchors.centerIn: parent
    spacing: panel.format.spacing_tiny

    StyledText {
      text: batteryRoot.batteryIcon(UPower.displayDevice.iconName)
      horizontalAlignment: Text.AlignHCenter
    }

    StyledText {
      id: percentageText
      text: "NaN%"
      horizontalAlignment: Text.AlignHCenter
    }
  }

  Timer {
    interval: panel.format.interval_xlong
    running: true
    repeat: true
    onTriggered: {
      // Force property refresh
      percentageText.text = UPower.displayDevice.ready
        ? Math.round(UPower.displayDevice.percentage * 100) + "%" : "—"
    }
  }
  function batteryIcon(name) {
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
    default:
        return "󰁹";
    }
  }
}
