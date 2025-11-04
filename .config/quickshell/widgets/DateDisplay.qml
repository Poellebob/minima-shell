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
  
  
  // Timer to update the time every second
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
  
  // Initialize the display
  Component.onCompleted: {
    var now = new Date()
    dateRoot.currentTime = Qt.formatDateTime(now, "hh:mm:ss")
    dateRoot.currentDate = Qt.formatDateTime(now, "MMMM d")
    dateRoot.currentDay = Qt.formatDateTime(now, "dddd")
  }
  
  RowLayout {
    anchors.fill: parent
    anchors.rightMargin: Global.format.spacing_large
    anchors.leftMargin: Global.format.spacing_large
    anchors.topMargin: Global.format.spacing_large
    anchors.bottomMargin: Global.format.spacing_large * 2
    spacing: 0
    
    // Centered clock display
    ColumnLayout {
      Layout.fillHeight: true
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignCenter
      spacing: Global.format.spacing_medium
      
      Text {
        Layout.alignment: Qt.AlignHCenter
        text: dateRoot.currentTime
        font.family: "CommitMono Nerd Font Mono"
        font.pixelSize: Global.format.font_size_xlarge
        font.bold: true
        color: Global.colors.on_surface_variant
        horizontalAlignment: Text.AlignHCenter
      }
      
      Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Global.format.spacing_small
        implicitWidth: 80
        implicitHeight: 2
        color: Global.colors.primary
        radius: 1
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: dateRoot.currentDay
        font.family: "CommitMono Nerd Font Mono"
        font.pixelSize: Global.format.font_size_medium
        font.bold: true
        color: Global.colors.on_surface_variant
        horizontalAlignment: Text.AlignHCenter
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: dateRoot.currentDate
        font.family: "CommitMono Nerd Font Mono"
        font.pixelSize: Global.format.font_size_medium
        font.bold: true
        color: Global.colors.on_surface_variant
        horizontalAlignment: Text.AlignHCenter
      }
    }
  }
}
