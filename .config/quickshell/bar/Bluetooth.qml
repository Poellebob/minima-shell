import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.colors

Item {
  id: bluetoothRoot
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
        id: bluetoothIcon
        text: bluetoothRoot.bluetoothEnabled ? "󰂯" : "󰂲"
        color: bluetoothRoot.bluetoothEnabled ? panel.colors.dark_on_surface_variant : panel.colors.dark_outline
        font.pixelSize: panel.format.text_size
      }

      Text {
        id: bluetoothText
        text: bluetoothRoot.displayText
        color: panel.colors.dark_on_surface_variant
        font.pixelSize: panel.format.text_size
        visible: bluetoothRoot.displayText !== ""
      }
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
    interval: panel.format.interval_long
    running: true
    repeat: true
    onTriggered: bluetoothProcess.running = true
  }

  Timer {
    interval: panel.format.interval_medium
    running: true
    repeat: true
    onTriggered: bluetoothRoot.updateDisplayText()
  }
}