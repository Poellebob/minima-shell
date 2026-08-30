import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.components.widget
import qs.components.text
import qs

BarWidget {
  id: root

  signal bluetoothMenuTriggered

  property int currentDeviceIndex: 0
  property string displayText: ""

  visible: Bluetooth.adapters.values.length !== 0

  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property bool adapterEnabled: adapter?.state
                                         === BluetoothAdapterState.Enabled
  readonly property var connectedDevices: {
    if (!adapter)
      return [];
    const devs = [];
    for (const key in adapter.devices.values) {
      const dev = adapter.devices.values[key];
      if (dev.connected)
        devs.push(dev.name || dev.address);
    }
    return devs;
  }

  onConnectedDevicesChanged: {
    if (connectedDevices.length === 0)
      displayText = adapterEnabled ? "Not Connected" : "Disabled";
    else if (connectedDevices.length === 1)
      displayText = connectedDevices[0];
    else {
      displayText = connectedDevices[currentDeviceIndex];
      currentDeviceIndex = (currentDeviceIndex + 1) % connectedDevices.length;
    }
  }

  onAdapterEnabledChanged: {
    currentDeviceIndex = 0;
    if (adapterEnabled)
      displayText = connectedDevices.length > 0 ? connectedDevices[0] :
                                                  "Not Connected";
    else
      displayText = "Disabled";
  }

  Component.onCompleted: {
    if (!adapterEnabled)
      displayText = "Disabled";
  }

  onClicked: mouse => {
               if (mouse.button === Qt.LeftButton)
               bluetoothMenuTriggered();
             }

  RowLayout {
    anchors.centerIn: parent
    spacing: Global.format.spacing_small

    StyledText {
      text: adapter?.state === BluetoothAdapterState.Enabled ? "󰂯" : "󰂲"
      color: adapter?.state === BluetoothAdapterState.Enabled
             ? Global.colors.on_surface_variant : Global.colors.outline
    }

    StyledText {
      text: root.displayText
      visible: root.displayText !== ""
    }
  }
}
