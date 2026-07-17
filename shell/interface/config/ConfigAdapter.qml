import QtQuick
import Quickshell.Io
import Quickshell

Item {
  id: configFile

  FileView {
    id: confFile
    path: Quickshell.env("MINIMA_CONFIG") || (Quickshell.env("HOME") + "/.config/minima/config.json")
    watchChanges: true
    blockLoading: false

    onFileChanged: reload()

    JsonAdapter {
      id: json
      property JsonObject system: JsonObject {
        property string wm: "sway"
        property string matugenConfigPath: ""
      }
      property JsonObject theme: JsonObject {
        property bool darkTheme: true
      }
      property JsonObject panel: JsonObject {
        property bool enabled: true
        property bool top: false
      }
      property JsonObject launcher: JsonObject {
        property bool enabled: true
        property string qalcPath: ""
      }
      property JsonObject clipboard: JsonObject {
        property bool enabled: true
      }
      property JsonObject wallpaper: JsonObject {
        property bool enabled: true
        property bool engineEnabled: false
        property string enginePath: ""
        property string workshopPath: ""
        property int fps: 25
        property bool fill: true
        property bool matureContent: false
      }
    }
  }

  readonly property var config: json
}
