pragma Singleton
import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import qs.colors
import qs.format

Singleton {
  readonly property Format format: Format {}

  property bool darkTheme: true

  readonly property Colors colors: darkTheme ? colorsRaw.dark : colorsRaw.light

  property var launcher: null
  property var clipboardManager: null
  property var wallpaperSelector: null

  readonly property var config: ({
    system: { 
      wm: "sway", 
      matugenConfigPath: "" 
    },
    theme: { 
      darkTheme: true 
    },
    panel: {
      enabled: true, 
      top: false
    },
    launcher: { 
      enabled: true, 
      qalcPath: "" 
    },
    clipboard: { 
      enabled: true 
    },
    wallpaper: { 
      enabled: true, 
      engineEnabled: false, 
      enginePath: "", workshopPath: "", 
      fps: 25, 
      fill: true, 
      matureContent: false 
    }
  })

  property ColorsAdapter colorsRaw: ColorsAdapter {}
}
