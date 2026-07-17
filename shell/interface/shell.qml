import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.panel

ShellRoot {
  id: root

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

    delegate: Panel {
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
