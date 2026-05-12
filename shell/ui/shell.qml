import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.bar
import qs.launcher
import qs.widgets.logout
import qs.widgets.notificationCenter

ShellRoot {
  id: root

  Instantiator {
    model: Quickshell.screens

    delegate: Panel {
      screen: modelData
    }
  }

  Logout { id: logout }

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
