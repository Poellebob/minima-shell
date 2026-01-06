import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import qs

PanelWindow {
  id: launcherMenuRoot
  property int menuWidth: 600

  anchors {
    left: true
    bottom: true
    right: true
  }

  margins {
    left: (Screen.width - menuWidth) / 2
    right: (Screen.width - menuWidth) / 2
    bottom: 0
  }

  GlobalShortcut {
    id: launcherShortcut
    appid: "minima"
    name: "launcher"
    description: "Opens the minima-shell launcher"

    onPressed: {
      searchBox.clear()
      launcherMenuRoot.visible = !launcherMenuRoot.visible
      searchBox.focus = true
      grab.active = launcherMenuRoot.visible
    }
  }

  HyprlandFocusGrab {
    id: grab
    windows: [launcherMenuRoot]
  }

  implicitHeight: 400
  visible: false
  exclusiveZone: 0
  aboveWindows: true
  color: "transparent"
  focusable: true
  
  property bool isCustomCommand: searchBox.text.length > 0 && searchBox.text[0] === ">"

  property var customCommands: [
    {
      name: "Clip",
      description: "Open clipboard manager",
      icon: "edit-paste",
      execute: function () {
        Global.clipboardManager.visible = true
      }
    },
    {
      name: "Wallpapers",
      description: "Open wallpaper selector",
      icon: "preferences-desktop-wallpaper-symbolic",
      execute: function () {
        if (Global.wallpaperSelector) {
          Global.wallpaperSelector.visible = true
        }
      }
    }
  ]

  Rectangle {
    anchors.fill: parent
    topLeftRadius: Global.format.radius_xlarge + Global.format.spacing_small
    topRightRadius: Global.format.radius_xlarge + Global.format.spacing_small
    color: Global.colors.surface_variant
    
    Rectangle {
      anchors{
        top: parent.top
        left: parent.left
        right: parent.right
        bottom: searchBox.top

        topMargin: Global.format.spacing_large
        bottomMargin: Global.format.spacing_large
        rightMargin: Global.format.spacing_large
        leftMargin: Global.format.spacing_large
      }
      radius: Global.format.radius_large
      color: Global.colors.surface
      
      ListView {
        id: appList
        anchors.fill: parent
        anchors.margins: Global.format.spacing_small
        spacing: Global.format.spacing_tiny
        clip: true
        highlightFollowsCurrentItem: true
        focus: false

        populate: Transition {
          NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
        }

        model: {
          let entries = []
          let allEntries = []

          if (launcherMenuRoot.isCustomCommand) {
            allEntries = launcherMenuRoot.customCommands
          } else {
            allEntries = DesktopEntries.applications.values
          }

          if (searchBox.text === "") {
            return allEntries
          }

          const searchTerm = isCustomCommand
            ? searchBox.text.slice(1).trim().toLowerCase()
            : searchBox.text.trim().toLowerCase()

          for (const entry of allEntries) {
            if (entry.name.toLowerCase().includes(searchTerm)) {
              entries.push(entry)
            }
          }

          return entries
        }
        
        delegate: Rectangle {
          id: appItem
          required property var modelData
          property bool selected: modelData == appList.currentItem
          focus: false
          width: appList.width - scrollBar.width
          height: 40
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
                appItem.modelData?.execute()
                searchBox.clear()
                grab.active = false
                launcherMenuRoot.visible = false
              }
            }
          }
        }
        
        ScrollBar.vertical: ScrollBar {
          id: scrollBar
          policy: ScrollBar.AsNeeded
        }
      }
    }

    TextField {
      id: searchBox

      anchors{
        bottom: parent.bottom
        left: parent.left
        right: parent.right

        bottomMargin: Global.format.spacing_medium
        topMargin: Global.format.spacing_large
        leftMargin: Global.format.spacing_large
        rightMargin: Global.format.spacing_large
      }
      implicitHeight: 39
      color: "white"
      font.pixelSize: Global.format.text_size
      placeholderText: "type > for command"

      onFocusChanged: {
        focus: true
      }
      
      onAccepted: {
        console.log(appList.currentItem?.name)
        appList.currentItem?.modelData.execute()
        clear()
        launcherMenuRoot.visible = false
      }

      Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Up) {
          appList.currentIndex -= 1
          event.accepted = true
        } else if (event.key === Qt.Key_Down) {
          appList.currentIndex += 1
          event.accepted = true
        } else if (event.key === Qt.Key_Escape) {
          clear()
          launcherMenuRoot.visible = false
          event.accepted = true
        }
        if (appList.currentIndex < 0) appList.currentIndex = 0
        if (appList.currentIndex >= appList.count) appList.currentIndex = appList.count -1
      }
      
      background: Rectangle {
        anchors.fill: parent
        color: Global.colors.surface
        radius: Global.format.radius_large
      }
    }
  }
}
