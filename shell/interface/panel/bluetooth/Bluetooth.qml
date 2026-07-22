import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.components.widget
import qs.components.text
import qs

BarWidget {
  id: bluetoothRoot

  signal bluetoothMenuTriggered

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: Global.format.spacing_small

    StyledText {
      id: bluetoothIcon
      text: Bluetooth.defaultAdapter?.enabled ? "󰂯" : "󰂲"
      color: Bluetooth.defaultAdapter?.enabled ? Global.colors.on_surface_variant : Global.colors.outline
    }

    StyledText {
      id: bluetoothText
      text: bluetoothRoot.displayText
      visible: bluetoothRoot.displayText !== ""
    }
  }

  onClicked: bluetoothMenuTriggered()

  property int currentDeviceIndex: 0
  property string displayText: ""

  readonly property var defaultAdapter: Bluetooth.defaultAdapter
  readonly property bool adapterEnabled: defaultAdapter?.enabled ?? false
  readonly property var connectedDevices: {
    const adapter = Bluetooth.defaultAdapter
    if (!adapter) return []
    const devices = []
    for (const val in adapter.devices.values) {
      const dev = adapter.devices.values[val]
      if (dev.connected)
        devices.push(dev.name || dev.address)
    }
    return devices
  }

  onConnectedDevicesChanged: {
    if (connectedDevices.length === 0) {
      displayText = adapterEnabled ? "Not Connected" : "Disabled"
    } else if (connectedDevices.length === 1) {
      displayText = connectedDevices[0]
    } else {
      displayText = connectedDevices[currentDeviceIndex]
      currentDeviceIndex = (currentDeviceIndex + 1) % connectedDevices.length
    }
  }

  onAdapterEnabledChanged: {
    if (!adapterEnabled) {
      currentDeviceIndex = 0
      displayText = "Disabled"
    }
  }

  Component.onCompleted: {
    if (!adapterEnabled) {
      displayText = "Disabled"
    }
  }
}
