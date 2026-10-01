import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.panel
import qs.session

ShellRoot {
  id: root

  Process {
    command: ["sh", "-c",
      "systemd-inhibit --who=\"minima shell\" --why=\"lock keybind\" --what=handle-power-key --mode=block sleep infinity"]
    running: true
  }

  Instantiator {
    model: Quickshell.screens

    delegate: Panel {
      screen: modelData
    }
  }

  Instantiator {
    model: Quickshell.screens

    delegate: LogoutMenu {
      screen: modelData
    }
  }

  LockScreen {
    id: lockScreen
  }

  IpcHandler {
    function open(index: int): void {
    Global.openSystrayMenu(index);
  }

    target: "systray"
  }

  IpcHandler {
    function open(): void {
    Global.openLauncher();
  }

    target: "launcher"
  }

  IpcHandler {
    function open(): void {
    Global.openClipboard();
  }

    target: "clipboard"
  }

  IpcHandler {
    function open(): void {
    Global.openNotifications();
  }

    target: "notifications"
  }

  IpcHandler {
    function open(): void {
    Global.openLogoutMenu();
  }

    target: "minimaLogout"
  }

  IpcHandler {
    function open(): void {
    Global.openLockScreen();
  }

    target: "minimaLock"
  }
}
