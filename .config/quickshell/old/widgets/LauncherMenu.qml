import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.colors
import qs.format

PanelWindow {
  id: launcherMenuRoot

  readonly property Format format: Format {}
  // TODO: The color theme is hardcoded to dark.
  // This should be made dynamic.
  readonly property Colors colors: ColorsDark {}

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
    bottomRightRadius: format.radius_xlarge + format.spacing_small
    color: colors.surface_variant
    
    Rectangle {
      id: innerRect
      anchors.fill: parent
      anchors.topMargin: format.spacing_medium - 2
      anchors.bottomMargin: format.spacing_large
      anchors.rightMargin: format.spacing_large
      anchors.leftMargin: format.spacing_tiny
      radius: format.radius_large
      color: colors.surface
      
      ListView {
        id: appList
        anchors.fill: parent
        anchors.margins: format.spacing_small
        spacing: format.spacing_tiny
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
          height: format.module_height + format.spacing_medium
          radius: format.radius_medium
          color: mouseArea.containsMouse || appList.currentItem.modelData == modelData ? colors.surface_container_high : "transparent"
          
          Behavior on color {
            ColorAnimation {
              duration: 150
              easing.type: Easing.OutCubic
            }
          }
          
          RowLayout {
            anchors.fill: parent
            anchors.margins: format.spacing_small
            spacing: format.spacing_medium
            
            IconImage {
              Layout.preferredWidth: format.icon_size
              Layout.preferredHeight: format.icon_size
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
                color: colors.on_surface_variant
                font.pixelSize: format.text_size
                font.bold: true
                elide: Text.ElideRight
              }
              
              Text {
                Layout.fillWidth: true
                text: appItem.modelData.description || ""
                color: colors.outline
                font.pixelSize: format.font_size_small
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
        anchors.margins: format.spacing_small
        visible: launcherMenuRoot.isCustomCommand
        
        Text {
          anchors.centerIn: parent
          text: "Custom Command Mode\n" + launcherMenuRoot.command
          color: colors.on_surface_variant
          font.pixelSize: format.text_size
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }
}
