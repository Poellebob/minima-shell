import QtQuick
import Quickshell.Io
import qs

ModuleBase {
  id: clockModule

  property string time: ""

  label: time

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: clockModule.time = Qt.formatDateTime(new Date(), "HH:mm")
  }

  Component.onCompleted: time = Qt.formatDateTime(new Date(), "HH:mm")
}
