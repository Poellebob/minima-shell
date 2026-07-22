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
    target: "systray"
    function open(index: int): void {
      Global.openSystrayMenu(index)
    }
  }

  IpcHandler {
    target: "launcher"
    function open(): void {
      Global.openLauncher()
    }
  }

  IpcHandler {
    target: "clipboard"
    function open(): void {
      Global.openClipboard()
    }
  }
}
