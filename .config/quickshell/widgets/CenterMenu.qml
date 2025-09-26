import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: menuRoot
  anchor.window: panel
  anchor.rect.x: panel.width / 2 - width / 2
  anchor.rect.y: panel.height
  implicitHeight: 600
  implicitWidth: 800
  color: "transparent"
  
  property string fetchString
  property string fetchPath: Quickshell.shellDir + "/scripts/sysfetch.sh"
  
  Process {
    id: fetchRunner
    command: [fetchPath]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        menuRoot.fetchString = this.text
      }
    }
  }
  
  Timer {
    id: fetchTimer
    interval: panel.format.interval_xlong
    running: true
    repeat: true
    onTriggered: {
      fetchRunner.running = true
    }
  }
  
  Rectangle {
    id: menuIURoot
    anchors.fill: parent
    bottomLeftRadius: panel.format.radius_xlarge + panel.format.spacing_small
    bottomRightRadius: panel.format.radius_xlarge + panel.format.spacing_small
    color: panel.colors.dark_background
  }
  
  Timer {
    id: hideTimer
    interval: panel.format.interval_short
    running: false
    repeat: false
    onTriggered: {
      menuRoot.visible = false
    }
  }
  
  MouseArea {
    id: menuMouseArea
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    propagateComposedEvents: true
    preventStealing: true

    onEntered: hideTimer.stop()
    onExited: hideTimer.restart()

    Item {
      anchors.fill: parent
      anchors.leftMargin: panel.format.spacing_large
      anchors.rightMargin: panel.format.spacing_large
      anchors.bottomMargin: panel.format.spacing_large
      anchors.topMargin: panel.format.spacing_medium
      
      RowLayout {
        spacing: panel.format.spacing_large
        anchors.fill: parent
        
        // Left column
        ColumnLayout {
          spacing: panel.format.spacing_large
          Layout.fillHeight: true
          Layout.preferredWidth: parent.width * 0.8
          
          // Top row with small square and wide rectangle
          RowLayout {
            spacing: panel.format.spacing_large
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.235
            
            Rectangle {
              id: profileIcon
              Layout.preferredWidth: parent.height
              Layout.preferredHeight: parent.height
              color: panel.colors.dark_inverse_on_surface
              radius: panel.format.radius_large

              DateDisplay{
                anchors.fill: parent
              }
            }
            
            Rectangle {
              id: fetchOutput
              Layout.fillWidth: true
              Layout.preferredHeight: parent.height
              color: panel.colors.dark_inverse_on_surface
              radius: panel.format.radius_large
              
              Text {
                id: fetchText
                anchors.fill: parent
                anchors.margins: panel.format.spacing_medium
                text: menuRoot.fetchString
                font.family: "monospace"
                font.bold: true
                wrapMode: Text.WrapAnywhere
                textFormat: Text.RichText
                color: panel.colors.dark_on_surface_variant
              }
            }
          }
          
          // Large middle rectangle
          Rectangle {
            id: mediaControls
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: panel.colors.dark_inverse_on_surface
            radius: panel.format.radius_large
            
            MediaPlayer {
              anchors.fill: parent
            }
          }
          
          // Bottom rectangle
          Rectangle {
            id: systemUsage
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.2
            color: panel.colors.dark_inverse_on_surface
            radius: panel.format.radius_large

            NetworkBluetoothStatus {
              anchors.fill: parent
            }
          }
        }
        
        // Right tall rectangle with audio and brightness controls
        Rectangle {
          id: audioAndBrightness
          Layout.fillHeight: true
          Layout.preferredWidth: parent.height * 0.235
          color: panel.colors.dark_inverse_on_surface
          radius: panel.format.radius_large
          
          SystemUsage {
            anchors.fill: parent
          }
        }
      }
    }
  }
}