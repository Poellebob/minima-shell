import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import qs

PanelWindow {
  id: clipboardManagerRoot
  property int menuWidth: 600
  property var clipboardEntries: []
  property string searchText: ""
  
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
  
  implicitHeight: 400
  visible: false
  exclusiveZone: 0
  aboveWindows: true
  color: "transparent"
  focusable: true
  
  onVisibleChanged: {
    if (visible) {
      refresh()
      searchBox.clear()
      searchBox.focus = true
      clipList.currentIndex = 0
    }
  }
  
  Component.onCompleted: {
    refresh()
  }
  
  function refresh() {
    readProc.running = true
  }
  
  function selectEntry(entry) {
    Quickshell.execDetached(["bash", "-c", `echo "${entry}" | cliphist decode | wl-copy`])
  }
  
  function deleteEntry(entry) {
    deleteProc.entry = entry
    deleteProc.running = true
  }
  
  function wipeAll() {
    wipeProc.running = true
  }
  
  function filterEntries() {
    if (searchText.trim() === "") {
      return clipboardEntries
    }
    
    const search = searchText.toLowerCase()
    return clipboardEntries.filter(entry => {
      const content = entry.replace(/^\d+\t/, "").toLowerCase()
      return content.includes(search)
    })
  }
  
  function isImageEntry(entry) {
    return /^\d+\t\[\[.*binary data.*\d+x\d+.*\]\]$/.test(entry)
  }
  
  Process {
    id: readProc
    property var buffer: []
    
    command: ["cliphist", "list"]
    
    stdout: SplitParser {
      onRead: (line) => {
        readProc.buffer.push(line)
      }
    }
    
    onExited: (exitCode, exitStatus) => {
      if (exitCode === 0) {
        clipboardManagerRoot.clipboardEntries = readProc.buffer
        readProc.buffer = []
      }
    }
  }
  
  Process {
    id: deleteProc
    property string entry: ""
    command: ["bash", "-c", `echo "${entry}" | cliphist delete`]
    
    onExited: (exitCode, exitStatus) => {
      clipboardManagerRoot.refresh()
    }
  }
  
  Process {
    id: wipeProc
    command: ["cliphist", "wipe"]
    
    onExited: (exitCode, exitStatus) => {
      clipboardManagerRoot.refresh()
    }
  }
  
  GlobalShortcut {
    id: clipboardShortcut
    appid: "minima"
    name: "clipboardManager"
    description: "Opens the minima-shell clipboard manager"
    onPressed: {
      clipboardManagerRoot.visible = !clipboardManagerRoot.visible
      grab.active = clipboardManagerRoot.visible
    }
  }
  
  HyprlandFocusGrab {
    id: grab
    windows: [clipboardManagerRoot]
  }
  
  Rectangle {
    anchors.fill: parent
    topLeftRadius: Global.format.radius_xlarge + Global.format.spacing_small
    topRightRadius: Global.format.radius_xlarge + Global.format.spacing_small
    color: Global.colors.surface_variant
    
    Rectangle {
      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        bottom: searchRow.top
        topMargin: Global.format.spacing_large
        bottomMargin: Global.format.spacing_large
        rightMargin: Global.format.spacing_large
        leftMargin: Global.format.spacing_large
      }
      radius: Global.format.radius_large
      color: Global.colors.surface
      
      ListView {
        id: clipList
        anchors.fill: parent
        anchors.margins: Global.format.spacing_small
        spacing: Global.format.spacing_tiny
        clip: true
        highlightFollowsCurrentItem: true
        focus: false
        
        populate: Transition {
          NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
        }
        
        model: clipboardManagerRoot.filterEntries()
        
        delegate: Rectangle {
          id: clipItem
          required property string modelData
          required property int index
          property bool isImage: clipboardManagerRoot.isImageEntry(modelData)
          property string displayText: modelData.replace(/^\d+\t/, "")
          
          width: clipList.width - scrollBar.width
          height: Math.max(Global.format.module_height + Global.format.spacing_medium * 2, contentText.implicitHeight + Global.format.spacing_medium * 2)
          radius: Global.format.radius_medium
          color: mouseArea.containsMouse || clipList.currentIndex === index ? Global.colors.surface_container_high : "transparent"
          
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
            
            Text {
              Layout.preferredWidth: Global.format.icon_size
              Layout.alignment: Qt.AlignTop
              text: clipItem.isImage ? "󰈟" : "󰈙"
              font.pixelSize: Global.format.icon_size
              font.family: "JetBrainsMono Nerd Font"
            }
            
            ColumnLayout {
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignVCenter
              spacing: 0
              
              Text {
                id: contentText
                Layout.fillWidth: true
                text: clipItem.displayText
                color: Global.colors.on_surface_variant
                font.pixelSize: Global.format.text_size
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 3
              }
            }
            
            Button {
              Layout.preferredWidth: Global.format.icon_size
              Layout.preferredHeight: Global.format.icon_size
              Layout.alignment: Qt.AlignVCenter
              text: "󰩺"
              
              onClicked: {
                clipboardManagerRoot.deleteEntry(clipItem.modelData)
              }
              
              background: Rectangle {
                color: parent.pressed ? Global.colors.error : (parent.hovered ? Global.colors.error_container : "transparent")
                radius: Global.format.radius_small
              }
              
              contentItem: Text {
                text: parent.text
                color: parent.pressed ? Global.colors.on_error : Global.colors.on_error_container
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Global.format.font_size_medium
                font.family: "JetBrainsMono Nerd Font"
              }
            }
          }
          
          MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            
            onClicked: {
              clipboardManagerRoot.selectEntry(clipItem.modelData)
              clipboardManagerRoot.visible = false
              grab.active = false
            }
          }
        }
        
        ScrollBar.vertical: ScrollBar {
          id: scrollBar
          policy: ScrollBar.AsNeeded
        }
        
        Text {
          anchors.centerIn: parent
          visible: clipList.count === 0
          text: clipboardManagerRoot.searchText ? "No matching entries" : "Clipboard is empty"
          color: Global.colors.outline
          font.pixelSize: Global.format.text_size
        }
      }
    }
    
    RowLayout {
      id: searchRow
      anchors {
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        bottomMargin: Global.format.spacing_medium
        leftMargin: Global.format.spacing_large
        rightMargin: Global.format.spacing_large
      }
      spacing: Global.format.spacing_medium
      
      TextField {
        id: searchBox
        Layout.fillWidth: true
        implicitHeight: 39
        color: Global.colors.on_surface
        font.pixelSize: Global.format.text_size
        placeholderText: "Search clipboard..."
        
        onTextChanged: {
          clipboardManagerRoot.searchText = text
        }
        
        onAccepted: {
          if (clipList.count > 0) {
            clipboardManagerRoot.selectEntry(clipList.model[clipList.currentIndex])
            clear()
            clipboardManagerRoot.visible = false
            grab.active = false
          }
        }
        
        Keys.onPressed: (event) => {
          if (event.key === Qt.Key_Up) {
            if (clipList.currentIndex > 0) {
              clipList.currentIndex -= 1
            }
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            if (clipList.currentIndex < clipList.count - 1) {
              clipList.currentIndex += 1
            }
            event.accepted = true
          } else if (event.key === Qt.Key_Escape) {
            clear()
            clipboardManagerRoot.visible = false
            grab.active = false
            event.accepted = true
          } else if (event.key === Qt.Key_Delete) {
            if (clipList.count > 0) {
              clipboardManagerRoot.deleteEntry(clipList.model[clipList.currentIndex])
            }
            event.accepted = true
          }
        }
        
        background: Rectangle {
          anchors.fill: parent
          color: Global.colors.surface
          radius: Global.format.radius_large
        }
      }
      
      Button {
        implicitHeight: 39
        text: "Clear All"
        
        onClicked: {
          clipboardManagerRoot.wipeAll()
        }
        
        background: Rectangle {
          color: parent.pressed ? Global.colors.error : (parent.hovered ? Global.colors.error_container : Global.colors.surface)
          radius: Global.format.radius_large
        }
        
        contentItem: Text {
          text: parent.text
          color: parent.pressed ? Global.colors.on_error : Global.colors.on_error_container
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          font.pixelSize: Global.format.text_size
        }
      }
    }
  }
}
