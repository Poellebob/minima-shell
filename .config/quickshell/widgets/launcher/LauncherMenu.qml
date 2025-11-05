import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs

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
    bottomRightRadius: Global.format.radius_xlarge + Global.format.spacing_small
    color: Global.colors.surface_variant
    
    Rectangle {
      id: innerRect
      anchors.fill: parent
      anchors.topMargin: Global.format.spacing_medium - 2
      anchors.bottomMargin: Global.format.spacing_large
      anchors.rightMargin: Global.format.spacing_large
      anchors.leftMargin: Global.format.spacing_tiny
      radius: Global.format.radius_large
      color: Global.colors.surface
      
      ListView {
        id: appList
        anchors.fill: parent
        anchors.margins: Global.format.spacing_small
        spacing: Global.format.spacing_tiny
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
          height: Global.format.module_height + Global.format.spacing_medium
          radius: Global.format.radius_medium
          color: mouseArea.containsMouse || appList.currentItem.modelData == modelData ? Global.colors.surface_container_high : "transparent"
          
          Behavior on color {
            ColorAnimation {
              duration: 150
              easing.type: Easing.OutCubic
            }
          }
          
          RowLayout {
            anchors.fill: parent
            anchors.margins: Global.format.spacing_small
            spacing: Global.format.spacing_medium
            
            IconImage {
              Layout.preferredWidth: Global.format.icon_size
              Layout.preferredHeight: Global.format.icon_size
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
                color: Global.colors.on_surface_variant
                font.pixelSize: Global.format.text_size
                font.bold: true
                elide: Text.ElideRight
              }
              
              Text {
                Layout.fillWidth: true
                text: appItem.modelData.description || ""
                color: Global.colors.outline
                font.pixelSize: Global.format.font_size_small
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
        anchors.margins: Global.format.spacing_small
        visible: launcherMenuRoot.isCustomCommand
        
        Text {
          anchors.centerIn: parent
          text: "Custom Command Mode\n" + launcherMenuRoot.command
          color: Global.colors.on_surface_variant
          font.pixelSize: Global.format.text_size
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }
}
