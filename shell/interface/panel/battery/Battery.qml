import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.components.widget
import qs.components.text
import qs

BarWidget {
  id: batteryRoot

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

  visible: UPower.displayDevice.percentage == 0 ? false : true

  Component.onCompleted: displayInfo()

  RowLayout {
    id: column

    anchors.centerIn: parent
    spacing: Global.format.spacing_small

    StyledText {
      id: batteryIcon

      horizontalAlignment: Text.AlignHCenter
      text: getBatteryIcon(UPower.displayDevice.iconName)
    }

    StyledText {
      id: percentageText

      horizontalAlignment: Text.AlignHCenter
      text: `${Math.round(UPower.displayDevice.percentage * 100)}%`
    }
  }
}
