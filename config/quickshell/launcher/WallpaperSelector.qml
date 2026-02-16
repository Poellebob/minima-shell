import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.components.widget
import qs

MenuPanel {
  id: wallpaperSelectorRoot
  menuWidth: 786
  menuHeight: 600
  floating: true
  property var wallpapers: []
  property int tab: 0
  property string searchText: ""
  property string wallpapersDir: Quickshell.env("HOME") + "/Wallpapers"
  property bool engineEnabled: Global.settings["Wallpaper"]["engineEnabled"]
  property string enginePath: Global.settings["Wallpaper"]["enginePath"]
  property string workshopPath: Global.settings["Wallpaper"]["workshopPath"]
  property int engineFps: Global.settings["Wallpaper"]["fps"]
  property bool engineFill: Global.settings["Wallpaper"]["fill"]
  property bool matureContent: Global.settings["Wallpaper"]["matureContent"]
  property int volume: Global.settings["Wallpaper"]["volume"]
  property bool initialLoadComplete: false
  property string savedWallpaper: ""
  property var favorites: []
  property string favoritesPath: Quickshell.env("HOME") + "/.config/wallpaper-favorites.conf"
    
  Component.onCompleted: {
    // Load favorites first
    readFavoritesProc.running = true
    
    // Always load wallpapers on startup
    scanWallpapers()
    
    // Try to read the saved wallpaper from config
    readWallpaperConf.running = true
    
    if (visible) {
      searchBox.clear()
      searchBox.focus = true
      wallpaperGrid.currentIndex = 0
    }
  }

  property var filterWallpapers: {
    let filtered = wallpapers
    
    if (searchText.trim() !== "") {
      const search = searchText.toLowerCase()
      filtered = wallpapers.filter(item => {
        const name = item.name.toLowerCase()
        const folder = item.folder ? item.folder.toLowerCase() : ""
        return name.includes(search) || folder.includes(search)
      })
    }

    return filtered.slice((4*10)*tab, (4*10)*(tab+1))
  }
  
  function scanWallpapers() {
    scanImagesProc.running = true
    if (engineEnabled) {
      scanEngineProc.running = true
    }
  }

  function sortWallpapers() {
    wallpapers = wallpapers.slice().sort((a, b) => {
      const aFav = isFavorite(a)
      const bFav = isFavorite(b)

      if (aFav && !bFav) return -1
      if (!aFav && bFav) return 1

      return a.name.localeCompare(b.name)
    })
  }

  function startNextEngineProject() {
    if (engineQueueIndex >= engineQueue.length) {
      // All engine wallpapers have been scanned
      checkAndApplyInitialWallpaper()
      sortWallpapers()
      return
    }
    parseProjectProc.projectPath = engineQueue[engineQueueIndex]
    parseProjectProc.running = true
  }

  function hasEngineWallpaper(folderId) {
    return wallpaperSelectorRoot.wallpapers.some(w =>
      w.type === "engine" && w.id === folderId
    )
  }
  
  function getWallpaperId(wallpaperData) {
    if (wallpaperData.type === "engine") {
      return "engine:" + wallpaperData.id
    } else {
      return "image:" + wallpaperData.path
    }
  }
  
  function isFavorite(wallpaperData) {
    const id = getWallpaperId(wallpaperData)
    return favorites.indexOf(id) !== -1
  }
  
  function toggleFavorite(wallpaperData) {
    const id = getWallpaperId(wallpaperData)
    let newFavorites = favorites.slice()
    const index = newFavorites.indexOf(id)
    
    if (index !== -1) {
      newFavorites.splice(index, 1)
    } else {
      newFavorites.push(id)
    }
    
    favorites = newFavorites
    saveFavoritesProc.running = true
  }
  
  function checkAndApplyInitialWallpaper() {
    if (initialLoadComplete) return
    initialLoadComplete = true
    
    if (savedWallpaper && savedWallpaper.trim() !== "") {
      // Try to apply the saved wallpaper
      if (savedWallpaper.startsWith("engine:")) {
        const folderId = savedWallpaper.substring(7)
        const engineWallpaper = wallpapers.find(w => w.type === "engine" && w.id === folderId)
        if (engineWallpaper) {
          console.log("Applying saved engine wallpaper:", folderId)
          setWallpaper(engineWallpaper)
          return
        }
      } else {
        const imageWallpaper = wallpapers.find(w => w.type === "image" && w.path === savedWallpaper)
        if (imageWallpaper) {
          console.log("Applying saved image wallpaper:", savedWallpaper)
          setWallpaper(imageWallpaper)
          return
        }
      }
    }
    
    // If no saved wallpaper or it wasn't found, apply the first wallpaper
    if (wallpapers.length > 0) {
      console.log("No saved wallpaper foAutumnund, applying first wallpaper")
      setWallpaper(wallpapers[0])
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
    Quickshell.execDetached(["killall", "-9", "linux-wallpaperengine"])
    setWallpaperProc.wallpaperPath = path
    setWallpaperProc.previewPath = path
    setWallpaperProc.wallpaperType = "image"
    setWallpaperProc.running = true
  }
  
  function setEngineWallpaper(folderId, previewPath) {
    engineProc.folderId = folderId
    engineProc.previewPath = previewPath
    engineProc.running = true
  }

  // Read favorites from config
  Process {
    id: readFavoritesProc
    command: ["cat", favoritesPath]
    
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.trim().split('\n').filter(line => line.trim() !== "")
        wallpaperSelectorRoot.favorites = lines
        console.log("Loaded", lines.length, "favorites")
      }
    }
    
    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0) {
        console.log("No favorites file found")
        wallpaperSelectorRoot.favorites = []
      }
    }
  }
  
  // Save favorites to config
  Process {
    id: saveFavoritesProc
    command: [
      "bash", "-c",
      "echo \"" + favorites.join('\n') + "\" > " + favoritesPath
    ]
    
    onExited: (exitCode, exitStatus) => {
      if (exitCode === 0) {
        console.log("Favorites saved")
      }
    }
  }
  
  // Read the saved wallpaper from config
  Process {
    id: readWallpaperConf
    command: ["cat", Quickshell.env("HOME") + "/.config/wallpaper.conf"]
    
    stdout: StdioCollector {
      onStreamFinished: {
        wallpaperSelectorRoot.savedWallpaper = this.text.trim()
        console.log("Read saved wallpaper:", wallpaperSelectorRoot.savedWallpaper)
      }
    }
    
    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0) {
        console.log("No wallpaper.conf found or error reading it")
        wallpaperSelectorRoot.savedWallpaper = ""
      }
    }
  }
  
  // Scan regular image files
  Process {
    id: scanImagesProc
    property var buffer: []
    
    command: ["bash", "-c", "find -L " + wallpaperSelectorRoot.wallpapersDir + " -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\)"]
    
    stdout: SplitParser {
      onRead: (line) => {
        scanImagesProc.buffer.push(line)
        console.log(line)
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
        
        // If engine is not enabled, check for initial wallpaper now
        if (!engineEnabled) {
          checkAndApplyInitialWallpaper()
          sortWallpapers()
        }
      }
    }
  }

  property var engineQueue: []
  property int engineQueueIndex: 0
  
  // Scan wallpaper engine projects
  Process {
    id: scanEngineProc
    property var buffer: []
    command: ["bash", "-c",
      "find -L " + wallpaperSelectorRoot.workshopPath + " -name 'project.json'"
    ]
    stdout: SplitParser {
      onRead: (line) => {
        scanEngineProc.buffer.push(line)
      }
    }
    onExited: (exitCode, exitStatus) => {
      if (exitCode === 0) {
        wallpaperSelectorRoot.engineQueue = scanEngineProc.buffer.slice()
        wallpaperSelectorRoot.engineQueueIndex = 0
        scanEngineProc.buffer = []
        if (engineQueue.length > 0) {
          startNextEngineProject()
        } else {
          // No engine wallpapers found, check for initial wallpaper
          checkAndApplyInitialWallpaper()
        }
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
          if (
            (contentRating === "Mature" || contentRating === "Questionable") &&
            !wallpaperSelectorRoot.matureContent
          ) {
            // skip
          } else {
            const previewName = projectData.preview
            if (previewName) {
              const projectDir =
                parseProjectProc.projectPath.substring(
                  0,
                  parseProjectProc.projectPath.lastIndexOf('/')
                )
              const folderId =
                projectDir.substring(projectDir.lastIndexOf('/') + 1)
              let current = wallpaperSelectorRoot.wallpapers.slice()
              if (!hasEngineWallpaper(folderId)) {
                let current = wallpaperSelectorRoot.wallpapers.slice()
                current.push({
                  type: "engine",
                  name: projectData.title || folderId,
                  folder: "WE: " + folderId,
                  id: folderId,
                  path: projectDir,
                  preview: "file://" + projectDir + "/" + previewName,
                  previewPath: projectDir + "/" + previewName
                })
                wallpaperSelectorRoot.wallpapers = current
              }
            }
          }
        } catch (e) {
          console.log("Failed to parse project.json:", e)
        }
        wallpaperSelectorRoot.engineQueueIndex++
        wallpaperSelectorRoot.startNextEngineProject()
      }
    }
  }
  
  // Kill existing wallpaper engine processes and start new one
  Process {
    id: engineProc
    property string folderId: ""
    property string previewPath: ""
    command: ["killall", "-9", "linux-wallpaperengine"]
    
    onExited: (exitCode, exitStatus) => {
      for (let i in Quickshell.screens) {
        let args = [
          wallpaperSelectorRoot.enginePath,
          "--screen-root", Quickshell.screens[i].name,
          "--bg", workshopPath + folderId,
          "--volume", wallpaperSelectorRoot.volume
        ]
        if (wallpaperSelectorRoot.engineFps > 0) {
          args.push("--fps", wallpaperSelectorRoot.engineFps)
        }
        if (wallpaperSelectorRoot.engineFill) {
          args.push("--scaling", "fill")
        }
        console.log(args)
        Quickshell.execDetached({
          command: args,
          environment: ["XDG_SESSION_TYPE=wayland"]
        })
      }
      console.log(Quickshell.screens[0].name)
      updateConfProc.wallpaperPath = "engine:" + folderId
      updateConfProc.previewPath = previewPath
      console.log(previewPath)
      updateConfProc.running = true
    }
  }
    
  // Set regular image wallpaper with swww
  Process {
    id: setWallpaperProc
    property string wallpaperPath: ""
    property string previewPath: ""
    property string wallpaperType: ""
    command: [
      "swww", "img", wallpaperPath, 
      "--transition-type", "fade", 
      "--transition-duration", "1"
    ]
    
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
    command: [
      "bash", "-c", 
      "echo \"" + wallpaperPath + "\" > " + 
      Quickshell.env("HOME") + "/.config/wallpaper.conf"
    ]
    
    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0) {
        return
      }
      Quickshell.execDetached([
        "bash", "-c", 
        "matugen -j hex image \"" + previewPath + "\" 2>/dev/null | grep { | jq . > " + 
        Quickshell.env("HOME") + "/.config/quickshell/colors/colors.json" 
      ])
    }
  }
    
  IpcHandler {
    target: "minimaWallpaperSelector"
    
    function open(): void {
      wallpaperSelectorRoot.visible = !wallpaperSelectorRoot.visible
      wallpaperSelectorRoot.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
      searchBox.focus = true
    }
  }
  
  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Global.format.spacing_large
    spacing: Global.format.spacing_large
    
    // Title bar
    RowLayout {
      Layout.fillWidth: true
      Layout.preferredHeight: 24
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
      
      RowLayout { 
        Layout.fillWidth: true
        spacing: Global.format.spacing_large
        StyledButton {
          Layout.fillWidth: true
          text: " < "
          onPressed: {
            if (wallpaperSelectorRoot.tab > 0){
              wallpaperSelectorRoot.tab -= 1
            }
            searchBox.focus = true
          }
        }
        Text {
          color: Global.colors.tertiary
          text: (wallpaperSelectorRoot.tab + 1) + " of " + (Math.floor(wallpaperSelectorRoot.wallpapers.length/(4*10)) + 1)
        }
        StyledButton {
          Layout.fillWidth: true
          text: " > "
          onPressed: {
            if (wallpaperSelectorRoot.tab < Math.floor(wallpaperSelectorRoot.wallpapers.length/(4*10))) {
              wallpaperSelectorRoot.tab += 1
            }
            searchBox.focus = true
          }
        }
      }
      
      Text {
        visible: wallpaperSelectorRoot.favorites.length > 0
        text: " " + wallpaperSelectorRoot.favorites.length + " favorites"
        font.pixelSize: Global.format.text_size
        color: Global.colors.primary
        font.family: "JetBrainsMono Nerd Font"
      }
      
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
        cacheBuffer: visible ? (4*10)*cellHeight : cellHeight*3
        
        populate: Transition {
          NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        }
        
        model: wallpaperSelectorRoot.filterWallpapers
        
        delegate: Rectangle {
          id: wallpaperItem
          required property var modelData
          required property int index
          
          width: wallpaperGrid.cellWidth - Global.format.spacing_small
          height: wallpaperGrid.cellHeight - Global.format.spacing_small
          radius: Global.format.radius_medium
          color: mouseArea.containsMouse || wallpaperGrid.currentIndex === index ? 
                Global.colors.surface_container_high : Global.colors.surface_container
          visible: wallpaperSelectorRoot.visible

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
              id: previewContainer
              Layout.fillWidth: true
              Layout.fillHeight: true
              radius: Global.format.radius_small
              color: Global.colors.surface_dim
              clip: true

              Loader {
                anchors.fill: parent
                active: wallpaperSelectorRoot.visible || Global.launcher?.visible
                asynchronous: true

                sourceComponent: Image {
                  anchors.fill: parent
                  source: wallpaperItem.modelData.preview
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
                  cache: true
                  mipmap: true
                  retainWhileLoading: true
                  Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: wallpaperGrid.currentIndex === wallpaperItem.index ? 2 : 0
                    border.color: Global.colors.primary
                    radius: parent.radius
                  }
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
                  text: "󰇻"
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: 14
                  color: Global.colors.on_tertiary
                }
              }
              
              // Favorite star - as a separate clickable item
              Rectangle {
                id: favStar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Global.format.spacing_tiny
                width: 24
                height: 24
                radius: 12
                color: wallpaperSelectorRoot.isFavorite(wallpaperItem.modelData) ? 
                      Global.colors.primary : Global.colors.surface_dim
                opacity: favMouseArea.containsMouse || wallpaperSelectorRoot.isFavorite(wallpaperItem.modelData) ? 1.0 : 0.6
                
                Behavior on color {
                  ColorAnimation { duration: 150 }
                }
                
                Behavior on opacity {
                  NumberAnimation { duration: 150 }
                }
                
                Text {
                  anchors.centerIn: parent
                  text: wallpaperSelectorRoot.isFavorite(wallpaperItem.modelData) ? "" : ""
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: 14
                  color: wallpaperSelectorRoot.isFavorite(wallpaperItem.modelData) ? 
                        Global.colors.on_primary : Global.colors.on_surface
                }
                
                // Separate MouseArea for the star only
                MouseArea {
                  id: favMouseArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    console.log("Toggling favorite for:", wallpaperItem.modelData.name)
                    wallpaperSelectorRoot.toggleFavorite(wallpaperItem.modelData)
                  }
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

          // Main MouseArea for the entire item (excluding the star)
          MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            
            anchors.topMargin: favStar.height + Global.format.spacing_tiny
            propagateComposedEvents: false
            
            onClicked: (mouse) => {
              wallpaperGrid.currentIndex = wallpaperItem.index
            }
            
            onDoubleClicked: {
              wallpaperSelectorRoot.setWallpaper(wallpaperItem.modelData)
            }
            
            onPressAndHold: {
              wallpaperGrid.currentIndex = wallpaperItem.index
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
        focus: wallpaperSelectorRoot.visible
        
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
          searchBox.focus = true
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
