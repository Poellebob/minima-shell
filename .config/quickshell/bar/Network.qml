import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.colors

Item {
  id: networkRoot
  implicitHeight: rect.implicitHeight
  implicitWidth: rect.implicitWidth

  Rectangle {
    id: rect
    implicitHeight: panel.format.module_height
    implicitWidth: row.implicitWidth + panel.format.spacing_medium
    color: panel.colors.dark_surface_variant
    radius: panel.format.radius_small

    RowLayout {
      id: row
      anchors.centerIn: parent
      spacing: panel.format.spacing_small

      Text {
        id: networkIcon
        text: networkRoot.getNetworkIcon()
        color: networkRoot.isConnected ? panel.colors.dark_on_surface_variant : panel.colors.dark_outline
        font.pixelSize: panel.format.text_size
      }

      Text {
        id: networkText
        text: networkRoot.displayText
        color: panel.colors.dark_on_surface_variant
        font.pixelSize: panel.format.text_size
        visible: networkRoot.displayText !== ""
      }
    }
  }

  property bool isConnected: false
  property string connectionType: "none" // "wifi", "ethernet", "none"
  property string networkName: ""
  property int signalStrength: 0
  property string displayText: ""

  function getNetworkIcon() {
    if (!isConnected) {
      return "󰤭" // No connection
    }
    
    if (connectionType === "ethernet") {
      return "󰈀" // Ethernet
    }
    
    // WiFi icons based on signal strength
    if (signalStrength >= 75) {
      return "󰤨" // Full WiFi
    } else if (signalStrength >= 50) {
      return "󰤥" // Good WiFi
    } else if (signalStrength >= 25) {
      return "󰤢" // Weak WiFi
    } else {
      return "󰤟" // Very weak WiFi
    }
  }

  function updateDisplayText() {
    if (!isConnected) {
      displayText = "Disconnected"
      return
    }

    if (connectionType === "ethernet") {
      displayText = "Ethernet"
      return
    }

    if (connectionType === "wifi" && networkName !== "") {
      displayText = networkName
      return
    }

    displayText = "Connected"
  }

  // Network status process
  Process {
    id: networkProcess
    command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.trim().split('\n')
        let connected = false
        let type = "none"
        
        for (let line of lines) {
          const parts = line.split(':')
          if (parts.length >= 3) {
            const deviceType = parts[0]
            const state = parts[1]
            const connection = parts[2]
            
            if (state === "connected") {
              connected = true
              if (deviceType === "wifi") {
                type = "wifi"
                networkRoot.networkName = connection
                wifiSignalProcess.running = true
              } else if (deviceType === "ethernet") {
                type = "ethernet"
                networkRoot.networkName = connection
              }
              break
            }
          }
        }
        
        networkRoot.isConnected = connected
        networkRoot.connectionType = type
        
        if (!connected) {
          networkRoot.networkName = ""
          networkRoot.signalStrength = 0
        }
        
        networkRoot.updateDisplayText()
      }
    }
  }

  // WiFi signal strength process
  Process {
    id: wifiSignalProcess
    command: ["nmcli", "-t", "-f", "SIGNAL", "device", "wifi", "list", "--rescan", "no"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.trim().split('\n')
        if (lines.length > 0 && lines[0] !== "") {
          // Get the first (strongest) signal
          const signal = parseInt(lines[0])
          if (!isNaN(signal)) {
            networkRoot.signalStrength = signal
          }
        }
      }
    }
  }

  // Alternative approach using ip command for basic connectivity
  Process {
    id: ipRouteProcess
    command: ["ip", "route", "get", "8.8.8.8"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        // If we can get a route to 8.8.8.8, we have internet connectivity
        const hasRoute = this.text.includes("via") || this.text.includes("dev")
        if (!networkRoot.isConnected && hasRoute) {
          networkRoot.isConnected = true
          networkRoot.connectionType = "ethernet" // Fallback assumption
          networkRoot.updateDisplayText()
        }
      }
    }
  }

  Timer {
    interval: panel.format.interval_long
    running: true
    repeat: true
    onTriggered: {
      networkProcess.running = true
      fallbackTimer.start()
    }
  }
  Timer {
    id: fallbackTimer
    interval: panel.format.interval_short
    running: false
    onTriggered: {
      if (!networkRoot.isConnected) {
        ipRouteProcess.running = true
      }
    }
  }

  Timer {
    interval: panel.format.interval_longest
    running: networkRoot.connectionType === "wifi" && networkRoot.isConnected
    repeat: true
    onTriggered: wifiSignalProcess.running = true
  }
}