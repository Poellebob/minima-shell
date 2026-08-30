import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components.text
import qs

Item {
  id: root

  implicitHeight: 250

  property var wallpapers: []
  property string searchText: ""
  property string savedWallpaper: ""
  property var favorites: []

  property var imageScanResults: []
  property var engineScanResults: []
  property bool iDone: false
  property bool eDone: false

  property bool wasEngineActive: false

  readonly property string homeDir: Quickshell.env("HOME")
  readonly property string resolvedWorkshopPath: workshopPath.replace("~",
                                                                      homeDir)
  readonly property string wallpapersDir: homeDir + "/Wallpapers"
  readonly property string wallpaperConf: homeDir
                                          + "/.config/minima/wallpaper.conf"
  readonly property string favoritesPath: homeDir
                                          + "/.config/minima/wallpaper-favorites.conf"

  readonly property bool engineEnabled: Global.config.wallpaper.engineEnabled
  readonly property string enginePath: Global.config.wallpaper.enginePath
  readonly property string workshopPath: Global.config.wallpaper.workshopPath
  readonly property int engineFps: Global.config.wallpaper.fps
  readonly property bool engineFill: Global.config.wallpaper.fill
  readonly property bool matureContent: Global.config.wallpaper.matureContent
  readonly property int volume: Global.config.wallpaper.volume

  property var engineQueue: []
  property int engineQueueIndex: 0

  readonly property var filtered: {
    if (searchText.trim() === "")
      return wallpapers;
    const q = searchText.toLowerCase();
    return wallpapers.filter(w => w.name.toLowerCase().includes(q) || (w.folder
                                                                       ?? "").toLowerCase(
                               ).includes(q));
  }

  signal closed

  property alias currentIndex: list.currentIndex

  onIDoneChanged: if (iDone && (eDone || !engineEnabled))
                    mergeAndSort()
  onEDoneChanged: if (iDone && eDone)
                    mergeAndSort()

  function mergeAndSort() {
    wallpapers = imageScanResults.concat(engineScanResults);
    wallpapers = wallpapers.slice().sort((a, b) => {
                                           const aFav = favorites.indexOf(
                                             getWallpaperId(a)) !== -1;
                                           const bFav = favorites.indexOf(
                                             getWallpaperId(b)) !== -1;
                                           if (aFav !== bFav)
                                           return aFav ? -1 : 1;
                                           return a.name.localeCompare(b.name);
                                         });
  }

  function getWallpaperId(w) {
    return w.type === "engine" ? "engine:" + w.id : "image:" + w.path;
  }

  function isFavorite(w) {
    return favorites.indexOf(getWallpaperId(w)) !== -1;
  }

  function toggleFavorite(w) {
    const id = getWallpaperId(w);
    const idx = favorites.indexOf(id);
    const next = favorites.slice();
    if (idx !== -1)
      next.splice(idx, 1);
    else
      next.push(id);
    favorites = next;
    favoritesFileView.setText(next.join('\n'));
  }

  function reload() {
    imageScanResults = [];
    engineScanResults = [];
    iDone = false;
    eDone = false;
    scanImagesProc.running = true;
    if (engineEnabled)
      scanEngineProc.running = true;
  }

  function open() {
    searchText = "";
    wallpapers = [];
    imageScanResults = [];
    engineScanResults = [];
    iDone = false;
    eDone = false;
    scanImagesProc.running = true;
    if (engineEnabled)
      scanEngineProc.running = true;
    favoritesFileView.reload();
  }

  function close() {
    searchText = "";
    list.currentIndex = 0;
    closed();
  }

  function selectCurrent() {
    if (list.currentIndex >= 0 && list.currentIndex < filtered.length)
      setWallpaper(filtered[list.currentIndex]);
  }

  function toggleFavoriteCurrent() {
    if (list.currentIndex >= 0 && list.currentIndex < filtered.length)
      toggleFavorite(filtered[list.currentIndex]);
  }

  function moveNext() {
    if (list.currentIndex < list.count - 1)
      list.currentIndex++;
  }

  function movePrev() {
    if (list.currentIndex > 0)
      list.currentIndex--;
  }

  function setWallpaper(w) {
    if (w.type === "engine")
      setEngineWallpaper(w.id, w.previewPath, false);
    else
      setImageWallpaper(w.path, false);
  }

  function setImageWallpaper(path, isBackgroundApply) {
    const background = isBackgroundApply === true;
    setProc.wallpaperPath = path;
    setProc.previewPath = path;
    setProc.skipAnimation = background || root.wasEngineActive;
    setProc.killEngineAfter = root.wasEngineActive;
    setProc.isBackgroundApply = background;
    setProc.running = true;
  }

  function setEngineWallpaper(folderId, previewPath, isBackgroundApply) {
    engineProc.folderId = folderId;
    engineProc.previewPath = previewPath;
    engineProc.isBackgroundApply = isBackgroundApply === true;
    engineProc.running = true;
  }

  function applyCurrentWallpaper() {
    if (!savedWallpaper || savedWallpaper.trim() === "")
      return;
    if (savedWallpaper.indexOf("engine:") === 0) {
      const folderId = savedWallpaper.substring("engine:".length);
      setEngineWallpaper(folderId, "", true);
    } else {
      setImageWallpaper(savedWallpaper, true);
    }
  }

  function startNextEngineProject() {
    if (engineQueueIndex >= engineQueue.length) {
      eDone = true;
      return;
    }
    parseProjectProc.projectPath = engineQueue[engineQueueIndex];
    parseProjectProc.running = true;
  }

  Connections {
    target: Quickshell
    function onScreensChanged() {
      if (confFile.loaded)
        root.applyCurrentWallpaper();
    }
  }

  FileView {
    id: confFile
    path: root.wallpaperConf
    blockLoading: true
    onLoaded: {
      root.savedWallpaper = text().trim();
      root.applyCurrentWallpaper();
    }
    onSaved: {
      if (!confFile._skipMatugen) {
        const matugenBin = Global.config.system.matugenBin;
        const matugenConfig = Global.config.system.matugenConfigPath;
        if (matugenBin !== "" && matugenConfig !== "") {
          Quickshell.execDetached(["/bin/sh", "-c", matugenBin + " -c "
                                   + matugenConfig + " -j hex image \""
                                   + confFile._previewPath
                                   + "\" --source-color-index 0"]);
        }
      }
      if (!confFile._isBackgroundApply)
        root.closed();
    }
    property bool _skipMatugen: false
    property bool _isBackgroundApply: false
    property string _previewPath: ""
  }

  FileView {
    id: favoritesFileView
    path: root.favoritesPath
    onLoaded: {
      const lines = text().trim().split('\n').filter(l => l.trim() !== "");
      root.favorites = lines;
    }
  }

  function writeConf(wallpaperValue, previewPath, skipMatugen,
                     isBackgroundApply) {
    confFile._skipMatugen = skipMatugen;
    confFile._previewPath = previewPath;
    confFile._isBackgroundApply = isBackgroundApply;
    confFile.setText(wallpaperValue);
  }

  Process {
    id: scanImagesProc
    property var buffer: []
    command: ["/bin/sh", "-c", "find -L " + root.wallpapersDir
      + " -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\)"]
    stdout: SplitParser {
      onRead: line => scanImagesProc.buffer.push(line)
    }
    onExited: (code, _) => {
                if (code === 0) {
                  root.imageScanResults = scanImagesProc.buffer.map(path => {
                                                                      const parts
                                                                      = path.split(
                                                                        "/");
                                                                      return {
                                                                        type: "image",
                                                                        name: parts[parts.length
                                                                          - 1],
                                                                        folder: parts[parts.length
                                                                          - 2] ?? "",
                                                                        path: path,
                                                                        preview: "file://"
                                                                                 + path
                                                                      };
                                                                    });
                }
                scanImagesProc.buffer = [];
                root.iDone = true;
              }
  }

  Process {
    id: scanEngineProc
    property var buffer: []
    command: ["/bin/sh", "-c", "find -L " + root.resolvedWorkshopPath
      + " -name 'project.json'"]
    stdout: SplitParser {
      onRead: line => scanEngineProc.buffer.push(line)
    }
    onExited: (code, _) => {
                if (code === 0) {
                  root.engineQueue = scanEngineProc.buffer.slice();
                  root.engineQueueIndex = 0;
                  scanEngineProc.buffer = [];
                  if (root.engineQueue.length > 0) {
                    root.startNextEngineProject();
                    return;
                  }
                }
                root.eDone = true;
              }
  }

  Process {
    id: parseProjectProc
    property string projectPath: ""
    command: ["cat", projectPath]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const data = JSON.parse(this.text);
          const rating = data.contentrating || "";
          const isMature = rating === "Mature" || rating === "Questionable";

          if (!isMature || root.matureContent) {
            if (data.preview) {
              const dir = parseProjectProc.projectPath.substring(0,
                                                                 parseProjectProc.projectPath.lastIndexOf(
                                                                   "/"));
              const folderId = dir.substring(dir.lastIndexOf("/") + 1);
              const alreadyQueued = root.engineScanResults.some(w => w.id
                                                                === folderId);
              if (!alreadyQueued) {
                const next = root.engineScanResults.slice();
                next.push({
                            type: "engine",
                            name: data.title || folderId,
                            folder: "WE: " + folderId,
                            id: folderId,
                            path: dir,
                            preview: "file://" + dir + "/" + data.preview,
                            previewPath: dir + "/" + data.preview
                          });
                root.engineScanResults = next;
              }
            }
          }
        } catch (e) {
          console.log("Failed to parse project.json:", e);
        }
        root.engineQueueIndex++;
        root.startNextEngineProject();
      }
    }
  }

  Process {
    id: engineProc
    property string folderId: ""
    property string previewPath: ""
    property bool isBackgroundApply: false
    command: ["killall", "-9", "linux-wallpaperengine"]
    onExited: (_, __) => {
                let args = [root.enginePath, "--volume", root.volume];
                if (root.engineFps > 0)
                args.push("--fps", root.engineFps);
                for (let i in Quickshell.screens) {
                  const screen = Quickshell.screens[i];
                  args.push("--scaling", root.engineFill ? "fill" : "stretch");
                  args.push("--screen-root", screen.name);
                  args.push("--bg", root.resolvedWorkshopPath + folderId);
                }
                Quickshell.execDetached({
                                          command: args,
                                          environment:
                                            ["XDG_SESSION_TYPE=wayland"]
                                        });
                root.wasEngineActive = true;
                writeConf("engine:" + folderId, previewPath,
                          engineProc.isBackgroundApply,
                          engineProc.isBackgroundApply);
              }
  }

  Process {
    id: setProc
    property string wallpaperPath: ""
    property string previewPath: ""
    property bool skipAnimation: false
    property bool killEngineAfter: false
    property bool isBackgroundApply: false
    command: skipAnimation ? ["awww", "img", wallpaperPath] : ["awww", "img",
                                                               wallpaperPath,
                                                               "--transition-type",
                                                               "fade", "--transition-duration",
                                                               "1"]
    onExited: (code, _) => {
                if (code !== 0)
                return;
                if (setProc.killEngineAfter)
                Quickshell.execDetached(["killall", "-9",
                                         "linux-wallpaperengine"]);
                root.wasEngineActive = false;
                writeConf(wallpaperPath, previewPath, setProc.isBackgroundApply,
                          setProc.isBackgroundApply);
              }
  }

  ListView {
    id: list
    anchors.fill: parent
    orientation: ListView.Horizontal
    clip: true
    spacing: Global.format.spacing_medium
    highlightMoveDuration: 200
    currentIndex: 0

    onCurrentIndexChanged: {
      if (currentIndex < 0)
        return;
    }

    onModelChanged: {
      currentIndex = Math.min(currentIndex, count - 1);

      if (currentIndex >= 0)
        positionViewAtIndex(currentIndex, ListView.Center);
    }

    model: root.filtered

    delegate: Item {
      id: item
      required property var modelData
      required property int index
      width: 200
      height: list.height

      ColumnLayout {
        anchors.fill: parent
        spacing: Global.format.spacing_small

        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          color: Global.colors.surface_container
          clip: true

          Image {
            anchors.fill: parent
            source: item.modelData.preview
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            mipmap: true

            Rectangle {
              anchors.fill: parent
              color: "transparent"
              border.width: list.currentIndex === item.index ? 2 : 0
              border.color: Global.colors.primary
            }
          }

          Text {
            visible: item.modelData.type === "engine"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: Global.format.spacing_tiny
            text: "󰇻"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            color: Global.colors.tertiary
          }

          Text {
            visible: root.isFavorite(item.modelData)
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: Global.format.spacing_tiny
            text: ""
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            color: Global.colors.primary
          }
        }

        StyledText {
          text: item.modelData.name
          elide: Text.ElideRight
          Layout.fillWidth: true
        }

        StyledText {
          text: item.modelData.folder
          elide: Text.ElideRight
          Layout.fillWidth: true
          font.pixelSize: Global.format.font_size_small
          color: Global.colors.outline
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: list.currentIndex = item.index
        onDoubleClicked: root.setWallpaper(item.modelData)
        onWheel: wheel => {
                   if (wheel.angleDelta.x < 0 || wheel.angleDelta.y < 0) {
                     if (list.currentIndex < list.count - 1)
                     list.currentIndex++;
                   } else {
                     if (list.currentIndex > 0)
                     list.currentIndex--;
                   }
                 }
      }
    }
  }
}
