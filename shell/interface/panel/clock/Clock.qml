import QtQuick
import Quickshell
import qs.components.widget
import qs.components.text
import qs

BarWidget {
  id: clockRoot

  signal calendarMenuTriggered

  onClicked: mouse => {
               if (mouse.button === Qt.LeftButton)
               calendarMenuTriggered();
             }

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
