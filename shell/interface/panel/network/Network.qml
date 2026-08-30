import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components.widget
import qs.components.text
import qs

BarWidget {
  id: root

  signal networkMenuTriggered

  property bool isConnected: false
  property string connectionType: "none"
  property int signalStrength: 0

  function getNetworkIcon() {
    if (!isConnected) {
      return "󰤭";
    }

    if (connectionType === "ethernet") {
      return "󰈀";
    }

    if (signalStrength >= 75) {
      return "󰤨";
    } else if (signalStrength >= 50) {
      return "󰤥";
    } else if (signalStrength >= 25) {
      return "󰤢";
    } else {
      return "󰤟";
    }
  }

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: Global.format.spacing_small

    StyledText {
      id: networkIcon
      text: root.getNetworkIcon()
      color: root.isConnected ? Global.colors.on_surface_variant :
                                Global.colors.outline
    }
  }

  Process {
    id: networkProcess
    command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.trim().split('\n');
        let connected = false;
        let type = "none";

        for (let line of lines) {
          const parts = line.split(':');
          if (parts.length >= 3 && parts[1] === "connected") {
            connected = true;
            if (parts[0] === "wifi") {
              type = "wifi";
              wifiSignalProcess.running = true;
            } else if (parts[0] === "ethernet") {
              type = "ethernet";
            }
            break;
          }
        }

        root.isConnected = connected;
        root.connectionType = type;

        if (!connected) {
          root.signalStrength = 0;
        }
      }
    }
  }

  Process {
    id: wifiSignalProcess
    command: ["nmcli", "-t", "-f", "SIGNAL", "device", "wifi", "list",
      "--rescan", "no"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const signal = parseInt(this.text.trim().split('\n')[0]);
        if (!isNaN(signal)) {
          root.signalStrength = signal;
        }
      }
    }
  }

  Process {
    id: ipRouteProcess
    command: ["ip", "route", "get", "8.8.8.8"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const hasRoute = this.text.includes("via") || this.text.includes("dev");
        if (!root.isConnected && hasRoute) {
          root.isConnected = true;
          root.connectionType = "ethernet";
        }
      }
    }
  }

  Timer {
    interval: Global.format.interval_long
    running: true
    repeat: true
    onTriggered: {
      networkProcess.running = true;
      fallbackTimer.start();
    }
  }

  Timer {
    id: fallbackTimer
    interval: Global.format.interval_short
    running: false
    onTriggered: {
      if (!root.isConnected) {
        ipRouteProcess.running = true;
      }
    }
  }

  Timer {
    interval: Global.format.interval_long
    running: root.connectionType === "wifi" && root.isConnected
    repeat: true
    onTriggered: wifiSignalProcess.running = true
  }

  onClicked: mouse => {
               if (mouse.button === Qt.LeftButton)
               networkMenuTriggered();
             }
}
