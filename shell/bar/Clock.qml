import QtQuick
import Quickshell
import qs.components.bar
import qs.components.text
import qs

ModuleBase {
  id: clockRoot
  implicitWidth: text.implicitWidth + Global.format.spacing_medium

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