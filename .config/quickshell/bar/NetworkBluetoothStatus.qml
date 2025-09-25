import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
  id: statusRoot
  anchors.fill: parent

  RowLayout {
    anchors.fill: parent
    anchors.margins: panel.format.spacing_large
    spacing: panel.format.spacing_large

    // Left side - Network Status
    Rectangle {
      id: networkStatus
      Layout.fillHeight: true
      Layout.fillWidth: true
      color: panel.colors.dark_inverse_on_surface
      radius: panel.format.radius_large
      border.width: 1
      border.color: panel.colors.dark_primary
      
      // Network status process
      property string networkInfo: ""
      
      Process {
        id: networkProcess
        command: ["nmcli", "-t", "-f", "NAME,TYPE,STATE", "connection", "show", "--active"]
        running: true
        stdout: StdioCollector {
          onStreamFinished: {
            networkStatus.networkInfo = this.text
          }
        }
      }
      
      Timer {
        interval: panel.format.interval_long
        running: true
        repeat: true
        onTriggered: networkProcess.running = true
      }
      
      Column {
        anchors.fill: parent
        anchors.margins: panel.format.spacing_medium
        spacing: panel.format.spacing_medium
        
        RowLayout {
          width: parent.width
          spacing: panel.format.spacing_medium
          
          Text {
            text: "󰖩"
            font.family: "CommitMono Nerd Font Mono"
            font.pixelSize: panel.format.font_size_large
            font.bold: true
            color: panel.colors.dark_primary
          }
          
          Text {
            text: "Network"
            font.family: "CommitMono Nerd Font Mono"
            font.bold: true
            font.pixelSize: panel.format.font_size_medium
            color: panel.colors.dark_on_surface_variant
          }
        }
        
        Text {
          id: networkStatusText
          width: parent.width
          text: {
            if (networkStatus.networkInfo === "") return "Checking..."
            
            const lines = networkStatus.networkInfo.trim().split('\n')
            if (lines.length === 0 || lines[0] === "") return "Disconnected"
            
            let activeConnections = []
            for (let line of lines) {
              const parts = line.split(':')
              if (parts.length >= 3 && parts[2] === "activated") {
                const name = parts[0]
                const type = parts[1]
                activeConnections.push(`${name} (${type})`)
              }
            }
            
            if (activeConnections.length === 0) return "Disconnected"
            return activeConnections.slice(0, 2).join('\n')
          }
          font.family: "CommitMono Nerd Font Mono"
          font.pixelSize: panel.format.font_size_small
          color: panel.colors.dark_on_surface_variant
          wrapMode: Text.WrapAtWordBoundaryOrAnywhere
          elide: Text.ElideRight
        }
      }
    }

    // Right side - Bluetooth Status
    Rectangle {
      id: bluetoothStatus
      Layout.fillHeight: true
      Layout.fillWidth: true
      color: panel.colors.dark_inverse_on_surface
      radius: panel.format.radius_large
      border.width: 1
      border.color: panel.colors.dark_secondary
      
      // Bluetooth status process
      property string bluetoothInfo: ""
      property bool bluetoothEnabled: false
      
      Process {
        id: bluetoothProcess
        command: ["bluetoothctl", "show"]
        running: true
        stdout: StdioCollector {
          onStreamFinished: {
            bluetoothStatus.bluetoothInfo = this.text
            bluetoothStatus.bluetoothEnabled = this.text.includes("Powered: yes")
            if (bluetoothStatus.bluetoothEnabled) {
              connectedDevicesProcess.running = true
            }
          }
        }
      }
      
      Process {
        id: connectedDevicesProcess
        command: ["bluetoothctl", "devices", "Connected"]
        running: false
        stdout: StdioCollector {
          onStreamFinished: {
            bluetoothStatus.bluetoothInfo += "\n" + this.text
          }
        }
      }
      
      Timer {
        interval: panel.format.interval_long
        running: true
        repeat: true
        onTriggered: bluetoothProcess.running = true
      }
      
      Column {
        anchors.fill: parent
        anchors.margins: panel.format.spacing_medium
        spacing: panel.format.spacing_medium
        
        RowLayout {
          width: parent.width
          spacing: panel.format.spacing_medium
          
          Text {
            text: "󰂯"
            font.family: "CommitMono Nerd Font Mono"
            font.pixelSize: panel.format.font_size_large
            font.bold: true
            color: panel.colors.dark_secondary
          }
          
          Text {
            text: "Bluetooth"
            font.family: "CommitMono Nerd Font Mono"
            font.bold: true
            font.pixelSize: panel.format.font_size_medium
            color: panel.colors.dark_on_surface_variant
          }
        }
        
        Text {
          id: bluetoothStatusText
          width: parent.width
          text: {
            if (bluetoothStatus.bluetoothInfo === "") return "Checking..."
            if (!bluetoothStatus.bluetoothEnabled) return "Disabled"
            
            const lines = bluetoothStatus.bluetoothInfo.split('\n')
            let connectedDevices = []
            
            for (let line of lines) {
              if (line.startsWith("Device ")) {
                const parts = line.split(' ')
                if (parts.length >= 3) {
                  const deviceName = parts.slice(2).join(' ')
                  connectedDevices.push(deviceName)
                }
              }
            }
            
            if (connectedDevices.length === 0) return "No Connected Devices"
            return connectedDevices.slice(0, 2).join('\n')
          }
          font.family: "CommitMono Nerd Font Mono"
          font.pixelSize: panel.format.font_size_small
          color: panel.colors.dark_on_surface_variant
          wrapMode: Text.WrapAtWordBoundaryOrAnywhere
          elide: Text.ElideRight
        }
      }
    }
  }
}