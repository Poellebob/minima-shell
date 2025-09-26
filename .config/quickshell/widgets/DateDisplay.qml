import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
  id: dateRoot
  property string currentTime: ""
  property string currentDate: ""
  property string currentDay: ""
  
  
  // Timer to update the time every second
  Timer {
    id: timeTimer
    interval: panel.format.interval_short
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
    anchors.rightMargin: panel.format.spacing_large
    anchors.leftMargin: panel.format.spacing_large
    anchors.topMargin: panel.format.spacing_large
    anchors.bottomMargin: panel.format.spacing_large * 2
    spacing: 0
    
    // Centered clock display
    ColumnLayout {
      Layout.fillHeight: true
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignCenter
      spacing: panel.format.spacing_medium
      
      Text {
        Layout.alignment: Qt.AlignHCenter
        text: dateRoot.currentTime
        font.family: "CommitMono Nerd Font Mono"
        font.pixelSize: panel.format.font_size_xlarge
        font.bold: true
        color: panel.colors.dark_on_surface_variant
        horizontalAlignment: Text.AlignHCenter
      }
      
      Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: panel.format.spacing_small
        implicitWidth: 80
        implicitHeight: 2
        color: panel.colors.dark_primary
        radius: 1
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: dateRoot.currentDay
        font.family: "CommitMono Nerd Font Mono"
        font.pixelSize: panel.format.font_size_medium
        font.bold: true
        color: panel.colors.dark_on_surface_variant
        horizontalAlignment: Text.AlignHCenter
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: dateRoot.currentDate
        font.family: "CommitMono Nerd Font Mono"
        font.pixelSize: panel.format.font_size_medium
        font.bold: true
        color: panel.colors.dark_on_surface_variant
        horizontalAlignment: Text.AlignHCenter
      }
    }
  }
}