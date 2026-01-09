pragma Singleton
import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import qs.colors
import qs.format

Singleton {
  readonly property Colors colors: settings["Theme"]["darkTheme"] ? colorsRaw.dark : colorsRaw.light
  readonly property Format format: Format {}

  readonly property bool panelAlwaysVisible: settings["Panel"]["panelAlwaysVisible"]
  
  property var launcher: null
  property var clipboardManager: null
  property var wallpaperSelector: null

  FileView {
    id: confFile
    path: Quickshell.env("HOME") + "/.config/quickshell/config.ini"
    blockLoading: true
    watchChanges: true
    
    onFileChanged: {
      this.reload()
    }
  }

  property ColorsAdapter colorsRaw: ColorsAdapter {}

  property bool darkTheme: settings["Theme"]["darkTheme"]
  
  property var settings: {
    const home = Quickshell.env("HOME")
    const lines = confFile.text().split(/\r?\n/)
    const result = {}
    let section = null

    function expandTilde(value) {
      if (typeof value === "string" && value.startsWith("~")) {
        if (value === "~")
          return home
        if (value.startsWith("~/"))
          return home + value.slice(1)
      }
      return value
    }

    function parseValue(value) {
      if (value === "true") return true
      if (value === "false") return false

      if (!isNaN(value) && value.trim() !== "")
        return Number(value)

      return expandTilde(value)
    }

    for (let line of lines) {
      line = line.trim()
      if (!line || line.startsWith(";") || line.startsWith("#")) continue

      if (line.startsWith("[") && line.endsWith("]")) {
        section = line.slice(1, -1)
        result[section] = {}
        continue
      }

      const [key, ...rest] = line.split("=")
      const rawValue = rest.join("=").trim()
      const value = parseValue(rawValue)

      if (section) {
        result[section][key.trim()] = value
      } else {
        result[key.trim()] = value
      }
    }

    return result
  }

}
