import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components.bar
import qs.components.text
import qs

ModuleBase {
  id: bluetoothRoot
  implicitWidth: row.implicitWidth + Global.format.spacing_medium

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: Global.format.spacing_small

    StyledText {
      id: bluetoothIcon
      text: bluetoothRoot.bluetoothEnabled ? "󰂯" : "󰂲"
      color: bluetoothRoot.bluetoothEnabled ? Global.colors.on_surface_variant : Global.colors.outline
    }

    StyledText {
      id: bluetoothText
      text: bluetoothRoot.displayText
      visible: bluetoothRoot.displayText !== ""
    }
  }

  property bool bluetoothEnabled: false
  property var connectedDevices: []
  property int currentDeviceIndex: 0
  property string displayText: ""

  function updateDisplayText() {
    if (!bluetoothEnabled) {
      displayText = "Disabled"
      return
    }
    
    if (connectedDevices.length === 0) {
      displayText = "Not Connected"
      return
    }
    
    if (connectedDevices.length === 1) {
      displayText = connectedDevices[0]
      return
    }
    
    // Cycle through device names
    displayText = connectedDevices[currentDeviceIndex]
    currentDeviceIndex = (currentDeviceIndex + 1) % connectedDevices.length
  }

  // Bluetooth status process
  Process {
    id: bluetoothProcess
    command: ["bluetoothctl", "show"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        bluetoothRoot.bluetoothEnabled = this.text.includes("Powered: yes")
        if (bluetoothRoot.bluetoothEnabled) {
          connectedDevicesProcess.running = true
        } else {
          bluetoothRoot.connectedDevices = []
          bluetoothRoot.currentDeviceIndex = 0
          bluetoothRoot.updateDisplayText()
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
        const lines = this.text.trim().split('\n')
        let devices = []
        
        for (let line of lines) {
          if (line.startsWith("Device ")) {
            const parts = line.split(' ')
            if (parts.length >= 3) {
              const deviceName = parts.slice(2).join(' ')
              devices.push(deviceName)
            }
          }
        }
        
        bluetoothRoot.connectedDevices = devices
        bluetoothRoot.currentDeviceIndex = 0
        bluetoothRoot.updateDisplayText()
      }
    }
  }

  Timer {
    interval: Global.format.interval_long
    running: true
    repeat: true
    onTriggered: bluetoothProcess.running = true
  }

  Timer {
    interval: Global.format.interval_medium
    running: true
    repeat: true
    onTriggered: bluetoothRoot.updateDisplayText()
  }
}
