import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs

Item {
  id: dateRoot

  property string currentTime: ""
  property string currentDate: ""
  property string currentDay: ""

  Timer {
    id: timeTimer
    interval: Global.format.interval_short
    running: true
    repeat: true
    onTriggered: {
      var now = new Date()
      dateRoot.currentTime = Qt.formatDateTime(now, "hh:mm:ss")
      dateRoot.currentDate = Qt.formatDateTime(now, "MMMM d")
      dateRoot.currentDay = Qt.formatDateTime(now, "dddd")
    }
  }

  Component.onCompleted: {
    var now = new Date()
    dateRoot.currentTime = Qt.formatDateTime(now, "hh:mm:ss")
    dateRoot.currentDate = Qt.formatDateTime(now, "MMMM d")
    dateRoot.currentDay = Qt.formatDateTime(now, "dddd")
  }

  RowLayout {
    anchors.centerIn: parent
    spacing: Global.format.spacing_large

    Text {
      text: dateRoot.currentTime
      font.family: "CommitMono Nerd Font Mono"
      font.pixelSize: 30
      font.bold: true
      color: Global.colors.on_surface_variant
      horizontalAlignment: Text.AlignRight
      Layout.alignment: Qt.AlignVCenter
    }

    Rectangle {
      Layout.preferredWidth: 2
      Layout.preferredHeight: 40
      color: Global.colors.primary
      radius: 1
      Layout.alignment: Qt.AlignVCenter
    }

    ColumnLayout {
      Layout.alignment: Qt.AlignVCenter
      spacing: Global.format.spacing_tiny

      Text {
        text: dateRoot.currentDay
        font.family: "CommitMono Nerd Font Mono"
        font.pixelSize: Global.format.font_size_medium
        font.bold: true
        color: Global.colors.on_surface_variant
      }

      Text {
        text: dateRoot.currentDate
        font.family: "CommitMono Nerd Font Mono"
        font.pixelSize: Global.format.font_size_medium
        font.bold: true
        color: Global.colors.on_surface_variant
      }
    }
  }
}
