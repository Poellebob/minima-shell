import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.bar
import qs.colors
import qs.format
import qs.settings

ShellRoot {
  id: root

  Singleton {
    id: globalInstance
    // Global singleton is auto-loaded from Global.qml
  }

  Process {
    command: [
      "sh",
      "-c",
      "systemd-inhibit --who=\"minima shell\" --why=\"lock keybind\" --what=handle-power-key --mode=block sleep infinity"
    ]
    running: true
  }

  Instantiator {
    model: Quickshell.screens

    delegate: StatusBar {
      screen: modelData
    }
  }

  IpcHandler {
    target: "minimaHome"
    function open(): void {
      // Focus home module
    }
  }

  IpcHandler {
    target: "minimaLauncher"
    function open(): void {
      // Focus launcher module and expand
    }
  }

  IpcHandler {
    target: "minimaClipboard"
    function open(): void {
      // Focus clipboard module and expand
    }
  }

  IpcHandler {
    target: "minimaWallpaperSelector"
    function open(): void {
      // Focus wallpaper module and expand
    }
  }

  IpcHandler {
    target: "minimaNotifications"
    function open(): void {
      // Focus notification module and expand
    }
  }
}
