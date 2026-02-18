import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components.widget
import qs

MenuPanel {
  id: logoutRoot

  implicitHeight: buttonGrid.height + Global.format.spacing_large * 2
  implicitWidth: buttonGrid.width + Global.format.spacing_large * 2

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

  GridLayout {
    id: buttonGrid

    columns: 3
    columnSpacing: Global.format.spacing_large
    rowSpacing: Global.format.spacing_large
    anchors.centerIn: parent 

    StyledButton {
      width: 200
      height: 200
      text: "Logout"

      implicitWidth: 200
      implicitHeight: 200

      onPressed: {
        Quickshell.execDetached([
          "sh",
          "-c",
          "pid=$(cat /tmp/.hyprland-systemd-inhibit 2>/dev/null); [ -n \"$pid\" ] && kill \"$pid\" && rm -f /tmp/.hyprland-systemd-inhibit"
        ])
        logoutRoot.run(["loginctl", "terminate-session", Quickshell.env("XDG_SESSION_ID")])
      }
    }

    StyledButton {
      width: 200
      height: 200
      text: "Poweroff"

      implicitWidth: 200
      implicitHeight: 200

      onPressed: {
        logoutRoot.run(["systemctl", "poweroff"])
      }
    }

    StyledButton {
      width: 200
      height: 200
      text: "Reboot"

      implicitWidth: 200
      implicitHeight: 200

      onPressed: {
        logoutRoot.run(["systemctl", "reboot"])
      }
    }

    StyledButton {
      width: 200
      height: 200
      text: "Sleep"

      implicitWidth: 200
      implicitHeight: 200

      onPressed: {
        logoutRoot.run(["systemctl", "suspend"])
      }
    }

    StyledButton {
      width: 200
      height: 200
      text: "Lock"

      implicitWidth: 200
      implicitHeight: 200

      onPressed: {
        logoutRoot.run(["hyprlock"])
      }
    }

    StyledButton {
      width: 200
      height: 200
      text: "Hibernate"

      implicitWidth: 200
      implicitHeight: 200

      onPressed: {
        logoutRoot.run(["systemctl", "hibernate"])
      }
    }
  }
}

