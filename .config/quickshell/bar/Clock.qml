import QtQuick
import Quickshell
import qs.colors
import qs.components.bar
import qs.components.text

ModuleBase {
  id: clockRoot
  implicitWidth: text.implicitWidth + format.spacing_medium

  StyledText {
    id: text
    text: Qt.formatDateTime(clock.date, "HH:mm")
    anchors.centerIn: parent
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}