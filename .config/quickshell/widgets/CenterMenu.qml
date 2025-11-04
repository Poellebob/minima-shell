import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

PopupWindow {
  id: menuRoot

  property var bar: panel
  anchor.window: bar
  anchor.rect.x: bar.width / 2 - width / 2
  anchor.rect.y: bar.height

  implicitHeight: visible ? visibleHeight : 1
  implicitWidth: 800
  color: "transparent"

  property int visibleHeight: 600
  property string fetchString
  property string fetchPath: Quickshell.shellDir + "/scripts/sysfetch.sh"
  
  /*Behavior on implicitHeight {
    NumberAnimation {
      duration: 100
      easing.type: Easing.OutCubic
    }
  }*/

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
    interval: Global.format.interval_xlong
    running: true
    repeat: true
    onTriggered: {
      fetchRunner.running = true
    }
  }
  
  Rectangle {
    id: menuIURoot
    anchors.fill: parent
    bottomLeftRadius: Global.format.radius_xlarge + Global.format.spacing_small
    bottomRightRadius: Global.format.radius_xlarge + Global.format.spacing_small
    color: Global.colors.background
  }
  
  Timer {
    id: hideTimer
    interval: Global.format.interval_short
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
      anchors.leftMargin: Global.format.spacing_large
      anchors.rightMargin: Global.format.spacing_large
      anchors.bottomMargin: Global.format.spacing_large
      anchors.topMargin: Global.format.spacing_medium

      //visible: menuRoot.height == menuRoot.visibleHeight ? true : false
      
      RowLayout {
        spacing: Global.format.spacing_large
        anchors.fill: parent
        
        // Left column
        ColumnLayout {
          spacing: Global.format.spacing_large
          Layout.fillHeight: true
          Layout.preferredWidth: parent.width * 0.8
          
          // Top row with small square and wide rectangle
          RowLayout {
            spacing: Global.format.spacing_large
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.235
            
            Rectangle {
              id: profileIcon
              Layout.preferredWidth: parent.height
              Layout.preferredHeight: parent.height
              color: Global.colors.inverse_on_surface
              radius: Global.format.radius_large

              DateDisplay{
                anchors.fill: parent
              }
            }
            
            Rectangle {
              id: fetchOutput
              Layout.fillWidth: true
              Layout.preferredHeight: parent.height
              color: Global.colors.inverse_on_surface
              radius: Global.format.radius_large
              
              Text {
                id: fetchText
                anchors.fill: parent
                anchors.margins: Global.format.spacing_medium
                text: menuRoot.fetchString
                font.family: "monospace"
                font.bold: true
                wrapMode: Text.WrapAnywhere
                textFormat: Text.RichText
                color: Global.colors.on_surface_variant
              }
            }
          }
          
          // Large middle rectangle
          Rectangle {
            id: mediaControls
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Global.colors.inverse_on_surface
            radius: Global.format.radius_large
            
            MediaPlayer {
              anchors.fill: parent
            }
          }
          
          // Bottom rectangle
          Rectangle {
            id: systemUsage
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.2
            color: Global.colors.inverse_on_surface
            radius: Global.format.radius_large

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
          color: Global.colors.inverse_on_surface
          radius: Global.format.radius_large
          
          SystemUsage {
            anchors.fill: parent
          }
        }
      }
    }
  }
}
