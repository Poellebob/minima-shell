import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.colors

PanelWindow {
  id: launcherMenuRoot
  anchors {
    top: true
    left: true
    bottom: true
  }
  property int height: 600
  implicitWidth: 300
  exclusiveZone: 0
  aboveWindows: true
  color: "transparent"
  focusable: WlrKeyboardFocus.OnDemand 
  required property string command
  
  property bool isCustomCommand: command.length > 0 && command[0] === ">"
  signal executed()

  function up() {
    appList.currentIndex -= 1
  }
  function down() {
    appList.currentIndex += 1
  }
  function launch() {
    appList.currentItem.modelData.execute()
    executed()
  }

  Rectangle {
    anchors {
      top: parent.top
      right: parent.right
      left: parent.left
    }
    implicitHeight: launcherMenuRoot.height
    bottomRightRadius: panel.format.radius_xlarge + panel.format.spacing_small
    color: panel.colors.surface_variant
    
    Rectangle {
      id: innerRect
      anchors.fill: parent
      anchors.topMargin: panel.format.spacing_medium - 2
      anchors.bottomMargin: panel.format.spacing_large
      anchors.rightMargin: panel.format.spacing_large
      anchors.leftMargin: panel.format.spacing_tiny
      radius: panel.format.radius_large
      color: panel.colors.surface
      
      ListView {
        id: appList
        anchors.fill: parent
        anchors.margins: panel.format.spacing_small
        spacing: panel.format.spacing_tiny
        clip: true
        visible: !launcherMenuRoot.isCustomCommand
        highlightFollowsCurrentItem: true
        focus: false

        populate: Transition {
          NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
        }

        model: {
          if (isCustomCommand) {
            return []
          }
          
          const entries = []
          const allEntries = DesktopEntries.applications.values
          
          if (command === "") {
            appList.currentIndex = 0
            return allEntries
          }
          
          // Filter entries
          const searchTerm = command.trim().toLowerCase()
          for (const entry in allEntries) {
            if (allEntries[entry].name.toLowerCase().includes(searchTerm)) entries.push(allEntries[entry])
          }

          appList.currentIndex = 0
          return entries
        }
        
        delegate: Rectangle {
          id: appItem
          required property var modelData
          property bool selected: modelData == appList.currentItem
          focus: false
          width: appList.width - scrollBar.width
          height: panel.format.module_height + panel.format.spacing_medium
          radius: panel.format.radius_medium
          color: mouseArea.containsMouse || appList.currentItem.modelData == modelData ? panel.colors.surface_container_high : "transparent"
          
          Behavior on color {
            ColorAnimation {
              duration: 150
              easing.type: Easing.OutCubic
            }
          }
          
          RowLayout {
            anchors.fill: parent
            anchors.margins: panel.format.spacing_small
            spacing: panel.format.spacing_medium
            
            IconImage {
              Layout.preferredWidth: panel.format.icon_size
              Layout.preferredHeight: panel.format.icon_size
              Layout.alignment: Qt.AlignVCenter
              source: appItem.modelData.icon ? Quickshell.iconPath(appItem.modelData.icon) : ""
            }
            
            ColumnLayout {
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignVCenter
              spacing: 0
              
              Text {
                Layout.fillWidth: true
                text: appItem.modelData.name
                color: panel.colors.on_surface_variant
                font.pixelSize: panel.format.text_size
                font.bold: true
                elide: Text.ElideRight
              }
              
              Text {
                Layout.fillWidth: true
                text: appItem.modelData.description || ""
                color: panel.colors.outline
                font.pixelSize: panel.format.font_size_small
                elide: Text.ElideRight
                visible: text !== ""
              }
            }
          }
          
          MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            
            onClicked: {
              if (appItem.modelData) {
                appItem.modelData.execute()
                launcherMenuRoot.executed()
              }
            }
          }
        }
        
        ScrollBar.vertical: ScrollBar {
          id: scrollBar
          policy: ScrollBar.AsNeeded
        }
      }
      
      // Custom command area - you can implement your custom commands here
      Item {
        id: customCommandArea
        anchors.fill: parent
        anchors.margins: panel.format.spacing_small
        visible: launcherMenuRoot.isCustomCommand
        
        Text {
          anchors.centerIn: parent
          text: "Custom Command Mode\n" + launcherMenuRoot.command
          color: panel.colors.on_surface_variant
          font.pixelSize: panel.format.text_size
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }
}