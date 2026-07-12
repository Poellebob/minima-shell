import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ExpandedPanel {
  id: batteryExpanded

  property int percentage: 85
  property bool charging: false

  function activate() {}
  function navigateUp() {}
  function navigateDown() {}

  ColumnLayout {
    Layout.fillWidth: true
    spacing: Global.format.spacing_medium

    RowLayout {
      Layout.fillWidth: true

      Text {
        text: charging ? "󰂄" : "󰁹"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.font_size_large
        color: charging ? Global.colors.primary : Global.colors.on_surface
      }

      Text {
        text: percentage + "%"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.font_size_large
        color: Global.colors.on_surface
        Layout.fillWidth: true
      }

      Text {
        text: charging ? "Charging" : "Discharging"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        color: Global.colors.on_surface_variant
      }
    }

    Rectangle {
      Layout.fillWidth: true
      height: 6
      radius: 3
      color: Global.colors.surface_variant

      Rectangle {
        width: parent.width * (percentage / 100)
        height: parent.height
        radius: parent.radius
        color: percentage < 20 ? Global.colors.error : Global.colors.primary
      }
    }
  }
}
