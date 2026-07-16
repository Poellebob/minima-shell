import QtQuick
import Quickshell.Io
import Quickshell

Item {
  id: configFile

  FileView {
    id: confFile
    path: Quickshell.env("MINIMA_CONFIG") || (Quickshell.env("HOME") + "/.config/minima/config.json")
    watchChanges: true
    blockLoading: true

    onFileChanged: reload()

    JsonAdapter {
      id: json
      property JsonObject System: JsonObject {
        property string wm: "sway"
        property string matugenConfigPath: ""
      }
      property JsonObject Theme: JsonObject {
        property bool darkTheme: true
      }
      property JsonObject Panel: JsonObject {
        property bool enabled: true
        property bool panelAlwaysVisible: true
      }
      property JsonObject Launcher: JsonObject {
        property bool enabled: true
        property string qalcPath: ""
      }
      property JsonObject Clipboard: JsonObject {
        property bool enabled: true
      }
      property JsonObject Wallpaper: JsonObject {
        property bool enabled: true
        property bool engineEnabled: false
        property string enginePath: ""
        property string workshopPath: ""
        property int fps: 25
        property bool fill: true
        property bool matureContent: false
      }
      property JsonObject Interface: JsonObject {
        property string position: "bottom"
        property int expandedHeight: 400
      }
    }
  }

  readonly property var settings: json
}
