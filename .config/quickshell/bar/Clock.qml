import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.colors

Item {
  id: clockRoot
  implicitHeight: rect.implicitHeight
  implicitWidth: rect.implicitWidth

  Rectangle {
    id: rect
    implicitHeight: panel.format.module_height
    implicitWidth: text.implicitWidth + panel.format.spacing_medium
    color: panel.colors.dark_surface_variant
    radius: panel.format.radius_small

    Text {
      id: text
      text: Qt.formatDateTime(clock.date, "HH:mm")
      color: panel.colors.dark_on_surface_variant
      font.pixelSize: panel.format.text_size
      anchors.centerIn: parent
    }
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}
