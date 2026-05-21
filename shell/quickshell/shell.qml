import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.bar
import qs.launcher
import qs.widgets.notificationCenter

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

      Connections {
        target: root
        function onOpenHomeMenu() { openHome() }
      }
    }
  }

  signal openHomeMenu()

  IpcHandler {
    target: "minimaHome"

    function open(): void {
      openHomeMenu()
    }
  }

  Instantiator {
    model: Quickshell.screens

    delegate: LauncherOpener {
      screen: modelData
      implicitWidth: 600
    }
  }

  Instantiator {
    model: Quickshell.screens

    delegate: NotificationOpener {
      screen: modelData
    }
  }

  IpcHandler {
    target: "minimaLauncher"
    function open(): void { Launcher.open() }
  }

  IpcHandler {
    target: "minimaClipboard"
    function open(): void { ClipboardManager.open() }
  }

  IpcHandler {
    target: "minimaWallpaperSelector"
    function open(): void { WallpaperSelector.open() }
  }

  IpcHandler {
    target: "minimaNotifications"
    function open(): void { NotificationMenu.open() }
  }
}
