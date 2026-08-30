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

    StyledText {
      id: networkText
      text: root.displayText
      visible: root.displayText !== ""
    }
  }

  property bool isConnected: false
  property string connectionType: "none"
  property string networkName: ""
  property int signalStrength: 0
  property string displayText: ""

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

  function updateDisplayText() {
    if (!isConnected) {
      displayText = "Disconnected";
      return;
    }

    if (connectionType === "ethernet") {
      displayText = "Ethernet";
      return;
    }

    if (connectionType === "wifi" && networkName !== "") {
      displayText = networkName;
      return;
    }

    displayText = "Connected";
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
          if (parts.length >= 3) {
            const deviceType = parts[0];
            const state = parts[1];
            const connection = parts[2];

            if (state === "connected") {
              connected = true;
              if (deviceType === "wifi") {
                type = "wifi";
                root.networkName = connection;
                wifiSignalProcess.running = true;
              } else if (deviceType === "ethernet") {
                type = "ethernet";
                root.networkName = connection;
              }
              break;
            }
          }
        }

        root.isConnected = connected;
        root.connectionType = type;

        if (!connected) {
          root.networkName = "";
          root.signalStrength = 0;
        }

        root.updateDisplayText();
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
        const lines = this.text.trim().split('\n');
        if (lines.length > 0 && lines[0] !== "") {
          const signal = parseInt(lines[0]);
          if (!isNaN(signal)) {
            root.signalStrength = signal;
          }
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
          root.updateDisplayText();
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
