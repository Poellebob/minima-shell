import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import qs

PanelWindow {
  id: wallpaperSelectorRoot
  property int menuWidth: 900
  property int menuHeight: 600
  property var wallpapers: []
  property string searchText: ""
  property string wallpapersDir: Quickshell.env("HOME") + "/Wallpapers"
  property bool engineEnabled: Global.settings["Wallpaper"]["engine_enabled"]
  property string enginePath: Global.settings["Wallpaper"]["enginePath"]
  property string workshopPath: Global.settings["Wallpaper"]["workshopPath"]
  property int engineFps: Global.settings["Wallpaper"]["fps"]
  property bool engineFill: Global.settings["Wallpaper"]["fill"]
  property bool matureContent: Global.settings["Wallpaper"]["matureContent"]
  
  anchors {
    left: true
    bottom: true
    right: true
  }
  
  margins {
    left: (Screen.width - menuWidth) / 2
    right: (Screen.width - menuWidth) / 2
    bottom: (Screen.height - menuHeight) / 2
  }
  
  implicitHeight: menuHeight
  visible: false
  exclusiveZone: 0
  aboveWindows: true
  color: "transparent"
  focusable: true
  
  onVisibleChanged: {
    if (visible) {
      scanWallpapers()
      searchBox.clear()
      searchBox.focus = true
      wallpaperGrid.currentIndex = 0
    }
  }
  
  Component.onCompleted: {
    scanWallpapers()
  }
  
  function scanWallpapers() {
    scanImagesProc.running = true
    if (engineEnabled) {
      scanEngineProc.running = true
    }
  }
  
  function setWallpaper(wallpaperData) {
    if (wallpaperData.type === "engine") {
      setEngineWallpaper(wallpaperData.id, wallpaperData.previewPath)
    } else {
      setImageWallpaper(wallpaperData.path)
    }
  }
  
  function setImageWallpaper(path) {
    setWallpaperProc.wallpaperPath = path
    setWallpaperProc.previewPath = path
    setWallpaperProc.wallpaperType = "image"
    setWallpaperProc.running = true
  }
  
  function setEngineWallpaper(folderId, previewPath) {
    killEngineProc.folderId = folderId
    killEngineProc.previewPath = previewPath
    killEngineProc.running = true
  }
  
  function filterWallpapers() {
    if (searchText.trim() === "") {
      return wallpapers
    }
    
    const search = searchText.toLowerCase()
    return wallpapers.filter(item => {
      const name = item.name.toLowerCase()
      const folder = item.folder ? item.folder.toLowerCase() : ""
      return name.includes(search) || folder.includes(search)
    })
  }
  
  // Scan regular image files
  Process {
    id: scanImagesProc
    property var buffer: []
    
    command: ["bash", "-c", "find -L " + wallpaperSelectorRoot.wallpapersDir + " -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\)"]
    
    stdout: SplitParser {
      onRead: (line) => {
        scanImagesProc.buffer.push(line)
      }
    }
    
    onExited: (exitCode, exitStatus) => {
      if (exitCode === 0) {
        let images = []
        for (let path of scanImagesProc.buffer) {
          const parts = path.split('/')
          const fileName = parts[parts.length - 1]
          const folderName = parts[parts.length - 2] || ""
          images.push({
            type: "image",
            name: fileName,
            folder: folderName,
            path: path,
            preview: "file://" + path
          })
        }
        wallpaperSelectorRoot.wallpapers = images
        scanImagesProc.buffer = []
      }
    }
  }
  
  // Scan wallpaper engine projects
  Process {
    id: scanEngineProc
    property var buffer: []
    
    command: ["bash", "-c", "find -L " + wallpaperSelectorRoot.workshopPath + " -name 'project.json'"]
    
    stdout: SplitParser {
      onRead: (line) => {
        scanEngineProc.buffer.push(line)
      }
    }
    
    onExited: (exitCode, exitStatus) => {
      if (exitCode === 0) {
        for (let projectPath of scanEngineProc.buffer) {
          parseProjectProc.projectPath = projectPath
          parseProjectProc.running = true
        }
        scanEngineProc.buffer = []
      }
    }
  }
  
  // Parse individual project.json files
  Process {
    id: parseProjectProc
    property string projectPath: ""
    
    command: ["cat", projectPath]
    
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const projectData = JSON.parse(this.text)
          const contentRating = projectData.contentrating || ""
          
          if ((contentRating === "Mature" || contentRating === "Questionable") && !wallpaperSelectorRoot.matureContent) {
            return
          }
          
          const previewName = projectData.preview
          if (!previewName) return
          
          const projectDir = parseProjectProc.projectPath.substring(0, parseProjectProc.projectPath.lastIndexOf('/'))
          const folderId = projectDir.substring(projectDir.lastIndexOf('/') + 1)
          const previewPath = projectDir + "/" + previewName
          
          let currentWallpapers = wallpaperSelectorRoot.wallpapers.slice()
          currentWallpapers.push({
            type: "engine",
            name: projectData.title || folderId,
            folder: "WE: " + folderId,
            id: folderId,
            path: projectDir,
            preview: "file://" + previewPath,
            previewPath: previewPath
          })
          wallpaperSelectorRoot.wallpapers = currentWallpapers
        } catch (e) {
          console.log("Failed to parse project.json:", e)
        }
      }
    }
  }
  
  // Kill existing wallpaper engine processes and start new one
  Process {
    id: killEngineProc
    property string folderId: ""
    property string previewPath: ""
    command: ["pkill", "-9", "linux-wallpaperengine"]
    
    onExited: (exitCode, exitStatus) => {
      startEngineProc.folderId = folderId
      startEngineProc.previewPath = previewPath
      startEngineProc.running = true
    }
  }
  
  // Start wallpaper engine
  Process {
    id: startEngineProc
    property string folderId: ""
    property string previewPath: ""
    command: {
      let args = [wallpaperSelectorRoot.enginePath, "--bg", folderId]
      if (wallpaperSelectorRoot.engineFps > 0) {
        args.push("--fps", wallpaperSelectorRoot.engineFps.toString())
      }
      if (wallpaperSelectorRoot.engineFill) {
        args.push("--scaling", "fill")
      }
      return args
    }
    
    onExited: (exitCode, exitStatus) => {
      if (exitCode === 0) {
        updateConfProc.wallpaperPath = "engine:" + folderId
        updateConfProc.previewPath = previewPath
        updateConfProc.running = true
      }
    }
  }
  
  // Set regular image wallpaper with swww
  Process {
    id: setWallpaperProc
    property string wallpaperPath: ""
    property string previewPath: ""
    property string wallpaperType: ""
    command: ["swww", "img", wallpaperPath, "--transition-type", "fade", "--transition-duration", "1"]
    
    onExited: (exitCode, exitStatus) => {
      if (exitCode === 0) {
        updateConfProc.wallpaperPath = wallpaperPath
        updateConfProc.previewPath = previewPath
        updateConfProc.running = true
      }
    }
  }
  
  // Update wallpaper.conf
  Process {
    id: updateConfProc
    property string wallpaperPath: ""
    property string previewPath: ""
    command: ["bash", "-c", "echo \"" + wallpaperPath + "\" > " + Quickshell.env("HOME") + "/.config/wallpaper.conf"]
    
    onExited: (exitCode, exitStatus) => {
      if (exitCode === 0) {
        regenColorsProc.previewPath = previewPath
        regenColorsProc.running = true
      }
    }
  }
  
  // Regenerate colors based on preview image
  Process {
    id: regenColorsProc
    property string previewPath: ""
    command: ["bash", "-c", "matugen -j hex image \"" + previewPath + "\" 2>/dev/null | grep '{' | jq . > " + Quickshell.env("HOME") + "/.config/quickshell/colors/colors.json && " + Quickshell.env("HOME") + "/.config/quickshell/scripts/generate-colors.sh"]
    
    onExited: (exitCode, exitStatus) => {
      wallpaperSelectorRoot.visible = false
      grab.active = false
    }
  }
  
  GlobalShortcut {
    id: wallpaperShortcut
    appid: "minima"
    name: "wallpaperSelector"
    description: "Opens the minima-shell wallpaper selector"
    onPressed: {
      wallpaperSelectorRoot.visible = !wallpaperSelectorRoot.visible
      grab.active = wallpaperSelectorRoot.visible
    }
  }
  
  HyprlandFocusGrab {
    id: grab
    windows: [wallpaperSelectorRoot]
  }
  
  Rectangle {
    anchors.fill: parent
    radius: Global.format.radius_xlarge + Global.format.spacing_small
    color: Global.colors.surface_variant
    
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Global.format.spacing_large
      spacing: Global.format.spacing_large
      
      // Title bar
      RowLayout {
        Layout.fillWidth: true
        spacing: Global.format.spacing_medium
        
        Text {
          text: "󰸉"
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: Global.format.font_size_large
          color: Global.colors.primary
        }
        
        Text {
          text: "Wallpaper Selector"
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: Global.format.font_size_large
          font.bold: true
          color: Global.colors.on_surface_variant
        }
        
        Item { Layout.fillWidth: true }
        
        Text {
          text: wallpaperSelectorRoot.wallpapers.length + " wallpapers"
          font.pixelSize: Global.format.text_size
          color: Global.colors.outline
        }
      }
      
      // Wallpaper grid
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Global.format.radius_large
        color: Global.colors.surface
        
        GridView {
          id: wallpaperGrid
          anchors.fill: parent
          anchors.margins: Global.format.spacing_medium
          clip: true
          cellWidth: 180
          cellHeight: 160
          focus: false
          
          populate: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
          }
          
          model: wallpaperSelectorRoot.filterWallpapers()
          
          delegate: Rectangle {
            id: wallpaperItem
            required property var modelData
            required property int index
            
            width: wallpaperGrid.cellWidth - Global.format.spacing_small
            height: wallpaperGrid.cellHeight - Global.format.spacing_small
            radius: Global.format.radius_medium
            color: mouseArea.containsMouse || wallpaperGrid.currentIndex === index ? 
                   Global.colors.surface_container_high : Global.colors.surface_container
            
            Behavior on color {
              ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
              }
            }
            
            ColumnLayout {
              anchors.fill: parent
              anchors.margins: Global.format.spacing_small
              spacing: Global.format.spacing_tiny
              
              // Image preview
              Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Global.format.radius_small
                color: Global.colors.surface_dim
                clip: true
                
                Image {
                  anchors.fill: parent
                  source: wallpaperItem.modelData.preview
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
                  cache: true
                  
                  Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: wallpaperGrid.currentIndex === wallpaperItem.index ? 2 : 0
                    border.color: Global.colors.primary
                    radius: parent.radius
                  }
                }
                
                // Wallpaper Engine badge
                Rectangle {
                  visible: wallpaperItem.modelData.type === "engine"
                  anchors.top: parent.top
                  anchors.right: parent.right
                  anchors.margins: Global.format.spacing_tiny
                  width: 24
                  height: 24
                  radius: 12
                  color: Global.colors.tertiary
                  
                  Text {
                    anchors.centerIn: parent
                    text: "󰑴"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    color: Global.colors.on_tertiary
                  }
                }
              }
              
              // File info
              ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: Global.format.font_size_small * 3
                spacing: 0
                
                Text {
                  Layout.fillWidth: true
                  text: wallpaperItem.modelData.name
                  font.pixelSize: Global.format.font_size_small
                  color: Global.colors.on_surface_variant
                  elide: Text.ElideMiddle
                  font.bold: true
                }
                
                Text {
                  Layout.fillWidth: true
                  text: wallpaperItem.modelData.folder
                  font.pixelSize: Global.format.font_size_small - 2
                  color: Global.colors.outline
                  elide: Text.ElideRight
                }
              }
            }
            
            MouseArea {
              id: mouseArea
              anchors.fill: parent
              hoverEnabled: true
              
              onClicked: {
                wallpaperGrid.currentIndex = wallpaperItem.index
              }
              
              onDoubleClicked: {
                wallpaperSelectorRoot.setWallpaper(wallpaperItem.modelData)
              }
            }
          }
          
          ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
          }
        }
        
        Text {
          anchors.centerIn: parent
          visible: wallpaperGrid.count === 0
          text: wallpaperSelectorRoot.searchText ? 
                "No wallpapers match your search" : 
                "No wallpapers found"
          color: Global.colors.outline
          font.pixelSize: Global.format.text_size
        }
      }
      
      // Search bar
      RowLayout {
        Layout.fillWidth: true
        spacing: Global.format.spacing_medium
        
        TextField {
          id: searchBox
          Layout.fillWidth: true
          implicitHeight: 39
          color: Global.colors.on_surface
          font.pixelSize: Global.format.text_size
          placeholderText: "Search by name or folder..."
          
          onTextChanged: {
            wallpaperSelectorRoot.searchText = text
            wallpaperGrid.currentIndex = 0
          }
          
          onAccepted: {
            if (wallpaperGrid.count > 0) {
              wallpaperSelectorRoot.setWallpaper(wallpaperGrid.model[wallpaperGrid.currentIndex])
            }
          }
          
          Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Up) {
              const cols = Math.floor(wallpaperGrid.width / wallpaperGrid.cellWidth)
              if (wallpaperGrid.currentIndex >= cols) {
                wallpaperGrid.currentIndex -= cols
              }
              event.accepted = true
            } else if (event.key === Qt.Key_Down) {
              const cols = Math.floor(wallpaperGrid.width / wallpaperGrid.cellWidth)
              if (wallpaperGrid.currentIndex < wallpaperGrid.count - cols) {
                wallpaperGrid.currentIndex += cols
              }
              event.accepted = true
            } else if (event.key === Qt.Key_Left) {
              if (wallpaperGrid.currentIndex > 0) {
                wallpaperGrid.currentIndex -= 1
              }
              event.accepted = true
            } else if (event.key === Qt.Key_Right) {
              if (wallpaperGrid.currentIndex < wallpaperGrid.count - 1) {
                wallpaperGrid.currentIndex += 1
              }
              event.accepted = true
            } else if (event.key === Qt.Key_Escape) {
              searchBox.clear()
              wallpaperSelectorRoot.visible = false
              grab.active = false
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
          implicitWidth: contentItem.implicitWidth + Global.format.spacing_large
          text: "󰑐 Refresh"
          
          onClicked: {
            wallpaperSelectorRoot.scanWallpapers()
          }
          
          background: Rectangle {
            color: parent.pressed ? Global.colors.primary : 
                   (parent.hovered ? Global.colors.primary_container : Global.colors.surface)
            radius: Global.format.radius_large
          }
          
          contentItem: Text {
            text: parent.text
            color: parent.pressed ? Global.colors.on_primary : Global.colors.on_surface_variant
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Global.format.text_size
            font.family: "JetBrainsMono Nerd Font"
          }
        }
      }
    }
  }
}
