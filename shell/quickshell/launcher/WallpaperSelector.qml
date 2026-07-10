//@ pragma UseQApplication
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Wayland
import qs.components.widget
import qs

pragma Singleton

MenuPanel {
  id: root

  implicitWidth: 786
  implicitHeight: 600

  readonly property int pageSize: 40

  property var    wallpapers:          []
  property var    favorites:           []
  property int    tab:                 0
  property string searchText:          ""
  property bool   initialLoadComplete: false
  property string savedWallpaper:      ""
  property bool wallpaperConfRead: false

  property var  imageScanResults: []
  property var  engineScanResults: []
  property bool iDone: false
  property bool eDone: false

  onIDoneChanged: if (iDone && (eDone || !engineEnabled)) mergeAndSort()
  onEDoneChanged: if (iDone && eDone) mergeAndSort()

  function mergeAndSort() {
    root.wallpapers = root.imageScanResults.concat(root.engineScanResults)
    sortWallpapers()
    tryApplyInitialWallpaper()
  }

  readonly property string wallpapersDir: Quickshell.env("HOME") + "/Wallpapers"
  readonly property string favoritesPath: Quickshell.env("HOME") + "/.config/minima/wallpaper-favorites.conf"
  readonly property string wallpaperPath: Quickshell.env("HOME") + "/.config/minima/wallpaper.conf"

  readonly property bool   engineEnabled: Global.settings["Wallpaper"]["engineEnabled"]
  readonly property string enginePath:    Global.settings["Wallpaper"]["enginePath"]
  readonly property string workshopPath:  Global.settings["Wallpaper"]["workshopPath"]
  readonly property int    engineFps:     Global.settings["Wallpaper"]["fps"]
  readonly property bool   engineFill:    Global.settings["Wallpaper"]["fill"]
  readonly property bool   matureContent: Global.settings["Wallpaper"]["matureContent"]
  readonly property int    volume:        Global.settings["Wallpaper"]["volume"] || 50

  property var engineQueue:      []
  property int engineQueueIndex: 0

  property var filteredWallpapers: {
    let list = wallpapers

    if (searchText.trim() !== "") {
      const q = searchText.toLowerCase()
      list = wallpapers.filter(w =>
        w.name.toLowerCase().includes(q) ||
        (w.folder ?? "").toLowerCase().includes(q)
      )
    }

    return list.slice(pageSize * tab, pageSize * (tab + 1))
  }

  Component.onCompleted: {
    readFavoritesProc.running = true
    scanWallpapers()
    readWallpaperConf.running = true

    if (visible) {
      searchBox.clear()
      searchBox.focus = true
      wallpaperGrid.currentIndex = 0
    }
  }

  function open(): void {
    root.visible = !root.visible
    root.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
    searchBox.focus = true
  }

  function scanWallpapers() {
    scanImagesProc.running = true
    if (root.engineEnabled)
      scanEngineProc.running = true
  }

  function sortWallpapers() {
    wallpapers = wallpapers.slice().sort((a, b) => {
      const aFav = isFavorite(a) ? 0 : 1
      const bFav = isFavorite(b) ? 0 : 1
      if (aFav !== bFav) return aFav - bFav
      return a.name.localeCompare(b.name)
    })
  }

  function getWallpaperId(w) {
    return w.type === "engine" ? "engine:" + w.id : "image:" + w.path
  }

  function isFavorite(w) {
    return favorites.indexOf(getWallpaperId(w)) !== -1
  }

  function toggleFavorite(w) {
    const id  = getWallpaperId(w)
    const idx = favorites.indexOf(id)
    const next = favorites.slice()
    if (idx !== -1)
      next.splice(idx, 1)
    else
      next.push(id)
    favorites = next
    saveFavoritesProc.running = true
  }

  function setWallpaper(w) {
    if (w.type === "engine")
      setEngineWallpaper(w.id, w.previewPath)
    else
      setImageWallpaper(w.path)
  }

  function setImageWallpaper(path) {
    Quickshell.execDetached(["killall", "-9", "linux-wallpaperengine"])
    setWallpaperProc.wallpaperPath = path
    setWallpaperProc.previewPath   = path
    setWallpaperProc.running       = true
  }

  function setEngineWallpaper(folderId, previewPath) {
    engineProc.folderId    = folderId
    engineProc.previewPath = previewPath
    engineProc.running     = true
  }

  function tryApplyInitialWallpaper() {
    if (initialLoadComplete) return
    if (!iDone || (!eDone && engineEnabled)) return
    if (!wallpaperConfRead) return

    initialLoadComplete = true

    if (savedWallpaper && savedWallpaper.trim() !== "") return

    if (wallpapers.length > 0)
      setWallpaper(wallpapers[0])
  }

  function startNextEngineProject() {
    if (engineQueueIndex >= engineQueue.length) {
      root.eDone = true
      return
    }
    parseProjectProc.projectPath = engineQueue[engineQueueIndex]
    parseProjectProc.running = true
  }

  Process {
    id: readFavoritesProc
    command: ["cat", root.favoritesPath]

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.trim().split('\n').filter(l => l.trim() !== "")
        root.favorites = lines
      }
    }

    onExited: (exitCode, _) => {
      if (exitCode !== 0)
        root.favorites = []
    }
  }

  Process {
    id: saveFavoritesProc
    command: ["bash", "-c", "echo \"" + favorites.join('\n') + "\" > " + root.favoritesPath]
  }

  Process {
    id: readWallpaperConf
    command: ["cat", root.wallpaperPath]

    stdout: StdioCollector {
      onStreamFinished: {
        root.savedWallpaper = this.text.trim()
      }
    }

    onExited: (exitCode, _) => {
      if (exitCode !== 0)
        root.savedWallpaper = ""
      root.wallpaperConfRead = true
      root.tryApplyInitialWallpaper()
    }
  }

  Process {
    id: scanImagesProc
    property var buffer: []
    command: [
      "/bin/sh", "-c",
      "find -L " + root.wallpapersDir +
      " -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\)"
    ]

    stdout: SplitParser {
      onRead: (line) => scanImagesProc.buffer.push(line)
    }

    onExited: (exitCode, _) => {
      if (exitCode === 0) {
        root.imageScanResults = scanImagesProc.buffer.map(path => {
          const parts = path.split('/')
          return {
            type:    "image",
            name:    parts[parts.length - 1],
            folder:  parts[parts.length - 2] ?? "",
            path:    path,
            preview: "file://" + path
          }
        })
      }
      scanImagesProc.buffer = []
      root.iDone = true
    }
  }

  Process {
    id: scanEngineProc
    property var buffer: []
    command: ["/bin/sh", "-c", "find -L " + root.workshopPath + " -name 'project.json'"]

    stdout: SplitParser {
      onRead: (line) => scanEngineProc.buffer.push(line)
    }

    onExited: (exitCode, _) => {
      if (exitCode === 0) {
        root.engineQueue      = scanEngineProc.buffer.slice()
        root.engineQueueIndex = 0
        scanEngineProc.buffer = []
        if (root.engineQueue.length > 0) {
          root.startNextEngineProject()
          return
        }
      }
      root.eDone = true
    }
  }

  Process {
    id: parseProjectProc
    property string projectPath: ""
    command: ["cat", projectPath]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const data   = JSON.parse(this.text)
          const rating = data.contentrating || ""
          const isMature = rating === "Mature" || rating === "Questionable"

          if (!isMature || root.matureContent) {
            if (data.preview) {
              const dir      = parseProjectProc.projectPath.substring(0, parseProjectProc.projectPath.lastIndexOf('/'))
              const folderId = dir.substring(dir.lastIndexOf('/') + 1)
              const alreadyQueued = root.engineScanResults.some(w => w.id === folderId)
              if (!alreadyQueued) {
                const next = root.engineScanResults.slice()
                next.push({
                  type:        "engine",
                  name:        data.title || folderId,
                  folder:      "WE: " + folderId,
                  id:          folderId,
                  path:        dir,
                  preview:     "file://" + dir + "/" + data.preview,
                  previewPath: dir + "/" + data.preview
                })
                root.engineScanResults = next
              }
            }
          }
        } catch (e) {
          console.log("Failed to parse project.json:", e)
        }
        root.engineQueueIndex++
        root.startNextEngineProject()
      }
    }
  }

  Process {
    id: engineProc
    property string folderId:    ""
    property string previewPath: ""
    command: ["killall", "-9", "linux-wallpaperengine"]

    onExited: (_, __) => {
      for (let i in Quickshell.screens) {
        const screen = Quickshell.screens[i]
        let args = [
          root.enginePath,
          "--screen-root", screen.name,
          "--bg", root.workshopPath + folderId,
          "--volume", root.volume
        ]
        if (root.engineFps > 0) args.push("--fps", root.engineFps)
        if (root.engineFill)   args.push("--scaling", "fill")
        console.log(args.toString())
        Quickshell.execDetached({ command: args, environment: ["XDG_SESSION_TYPE=wayland"] })
      }
      updateConfProc.wallpaperPath = "engine:" + folderId
      updateConfProc.previewPath   = previewPath
      updateConfProc.running       = true
    }
  }

  Process {
    id: setWallpaperProc
    property string wallpaperPath: ""
    property string previewPath:   ""
    command: ["awww", "img", wallpaperPath, "--transition-type", "fade", "--transition-duration", "1"]

    onExited: (exitCode, _) => {
      if (exitCode !== 0) return
      updateConfProc.wallpaperPath = wallpaperPath
      updateConfProc.previewPath   = previewPath
      updateConfProc.running       = true
    }
  }

  Process {
    id: updateConfProc
    property string wallpaperPath: ""
    property string previewPath:   ""
    command: ["/bin/sh", "-c", "echo \"" + wallpaperPath + "\" > " + root.wallpaperPath]

    onExited: (exitCode, _) => {
      if (exitCode !== 0) return
      Quickshell.execDetached([
        "/bin/sh", "-c",
        "matugen -c " + Global.matugenConfigPath + " -j hex image \"" + previewPath + "\" --source-color-index 0"
      ])
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
            if (root.tab > 0) root.tab -= 1
            searchBox.focus = true
          }
        }

        Text {
          color: Global.colors.tertiary
          text: (root.tab + 1) + " of " + (Math.floor(root.wallpapers.length / root.pageSize) + 1)
        }

        StyledButton {
          Layout.fillWidth: true
          text: " > "
          onPressed: {
            if (root.tab < Math.floor(root.wallpapers.length / root.pageSize))
              root.tab += 1
            searchBox.focus = true
          }
        }
      }

      Text {
        visible: root.favorites.length > 0
        text: " " + root.favorites.length + " favorites"
        font.pixelSize: Global.format.text_size
        color: Global.colors.primary
        font.family: "JetBrainsMono Nerd Font"
      }

      Text {
        text: root.wallpapers.length + " wallpapers"
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
        cacheBuffer: visible ? root.pageSize * cellHeight : cellHeight * 3

        model: root.filteredWallpapers

        populate: Transition {
          NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        }

        delegate: Rectangle {
          id: wallpaperItem
          required property var modelData
          required property int index

          width: wallpaperGrid.cellWidth - Global.format.spacing_small
          height: wallpaperGrid.cellHeight - Global.format.spacing_small
          radius: Global.format.radius_medium
          color: mouseArea.containsMouse || wallpaperGrid.currentIndex === index
            ? Global.colors.surface_container_high
            : Global.colors.surface_container
          visible: root.visible

          Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
          }

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: Global.format.spacing_small
            spacing: Global.format.spacing_tiny

            // Preview image
            Rectangle {
              id: previewContainer
              Layout.fillWidth: true
              Layout.fillHeight: true
              radius: Global.format.radius_small
              color: Global.colors.surface_dim
              clip: true

              Loader {
                anchors.fill: parent
                active: root.visible || Global.launcher?.visible
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
                    radius: previewContainer.radius
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

              // Favorite toggle
              Rectangle {
                id: favStar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Global.format.spacing_tiny
                width: 24
                height: 24
                radius: 12
                color: root.isFavorite(wallpaperItem.modelData)
                  ? Global.colors.primary
                  : Global.colors.surface_dim
                opacity: favMouseArea.containsMouse || root.isFavorite(wallpaperItem.modelData)
                  ? 1.0 : 0.6

                Behavior on color   { ColorAnimation  { duration: 150 } }
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Text {
                  anchors.centerIn: parent
                  text: root.isFavorite(wallpaperItem.modelData) ? "" : ""
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: 14
                  color: root.isFavorite(wallpaperItem.modelData)
                    ? Global.colors.on_primary
                    : Global.colors.on_surface
                }

                MouseArea {
                  id: favMouseArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.toggleFavorite(wallpaperItem.modelData)
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
                font.bold: true
                color: Global.colors.on_surface_variant
                elide: Text.ElideMiddle
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
            anchors.topMargin: favStar.height + Global.format.spacing_tiny
            hoverEnabled: true
            propagateComposedEvents: false

            onClicked:       wallpaperGrid.currentIndex = wallpaperItem.index
            onDoubleClicked: root.setWallpaper(wallpaperItem.modelData)
            onPressAndHold:  wallpaperGrid.currentIndex = wallpaperItem.index
          }
        }

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
      }

      Text {
        anchors.centerIn: parent
        visible: wallpaperGrid.count === 0
        text: root.searchText ? "No wallpapers match your search" : "No wallpapers found"
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
        focus: root.visible

        onTextChanged: {
          root.searchText = text
          wallpaperGrid.currentIndex = 0
        }

        onAccepted: {
          if (wallpaperGrid.count > 0)
            root.setWallpaper(wallpaperGrid.model[wallpaperGrid.currentIndex])
        }

        Keys.onPressed: (event) => {
          const cols = Math.floor(wallpaperGrid.width / wallpaperGrid.cellWidth)
          switch (event.key) {
            case Qt.Key_Up:
              if (wallpaperGrid.currentIndex >= cols)
                wallpaperGrid.currentIndex -= cols
              break
            case Qt.Key_Down:
              if (wallpaperGrid.currentIndex < wallpaperGrid.count - cols)
                wallpaperGrid.currentIndex += cols
              break
            case Qt.Key_Left:
              if (wallpaperGrid.currentIndex > 0)
                wallpaperGrid.currentIndex -= 1
              break
            case Qt.Key_Right:
              if (wallpaperGrid.currentIndex < wallpaperGrid.count - 1)
                wallpaperGrid.currentIndex += 1
              break
            case Qt.Key_Escape:
              searchBox.clear()
              root.visible = false
              break
            default:
              return
          }
          event.accepted = true
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
          root.wallpapers        = []
          root.imageScanResults  = []
          root.engineScanResults = []
          root.iDone             = false
          root.eDone             = false
          root.scanWallpapers()
          searchBox.focus = true
        }

        background: Rectangle {
          color: parent.pressed ? Global.colors.primary
               : parent.hovered ? Global.colors.primary_container
               : Global.colors.surface
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
