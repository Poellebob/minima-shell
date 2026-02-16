import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: logoutRoot

  implicitHeight: buttonGrid.height
  implicitWidth: buttonGrid.width

  visible: false
  color: "transparent"
  focusable: true

  WlrLayershell.layer: WlrLayer.Overlay

  Process {
    command: [
      "sh",
      "-c",
      "systemd-inhibit --who=\"minima shell\" --why=\"lock keybind\" --what=handle-power-key --mode=block sleep infinity"
    ]
    running: true
  }

  IpcHandler {
    target: "minimaLogout"

    function open(): void {
      logoutRoot.open()
    }
  }

  function open() {
    visible = !visible
  }

  function run(cmd) {
    Quickshell.execDetached(cmd)
    visible = false
  }

  Grid {
    id: buttonGrid

    columns: 3
    rows: 2
    spacing: Global.format.spacing_large

    Button {
      width: 200
      height: 200
      text: "Logout"

      onClicked: {
        Quickshell.execDetached([
          "sh",
          "-c",
          "pid=$(cat /tmp/.hyprland-systemd-inhibit 2>/dev/null); [ -n \"$pid\" ] && kill \"$pid\" && rm -f /tmp/.hyprland-systemd-inhibit"
        ])
        logoutRoot.run(["loginctl", "terminate-session", Quickshell.env("XDG_SESSION_ID")])
      }
    }

    Button {
      width: 200
      height: 200
      text: "Poweroff"

      onClicked: {
        logoutRoot.run(["systemctl", "poweroff"])
      }
    }

    Button {
      width: 200
      height: 200
      text: "Reboot"

      onClicked: {
        logoutRoot.run(["systemctl", "reboot"])
      }
    }

    Button {
      width: 200
      height: 200
      text: "Sleep"

      onClicked: {
        logoutRoot.run(["systemctl", "suspend"])
      }
    }

    Button {
      width: 200
      height: 200
      text: "Lock"

      onClicked: {
        logoutRoot.run(["hyprlock"])
      }
    }

    Button {
      width: 200
      height: 200
      text: "Hibernate"

      onClicked: {
        logoutRoot.run(["systemctl", "hibernate"])
      }
    }
  }
}

