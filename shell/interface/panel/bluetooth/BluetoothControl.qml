import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs

Item {
  id: root

  implicitHeight: 250

  property int adapterIndex: 0
  property BluetoothAdapter currentAdapter: Bluetooth.adapters.values[adapterIndex] ?? Bluetooth.defaultAdapter

  readonly property var devices: {
    const adapter = currentAdapter
    if (!adapter) return []
    const devs = []
    for (const key in adapter.devices.values) {
      const dev = adapter.devices.values[key]
      if (dev && dev.name)
        devs.push(dev)
    }
    return devs
  }

  readonly property var sortedDevices: {
    return devices.slice().sort((a, b) => {
      const aConnected = a.state === BluetoothDeviceState.Connected
      const bConnected = b.state === BluetoothDeviceState.Connected
      if (aConnected !== bConnected) return aConnected ? -1 : 1

      if (a.paired !== b.paired) return a.paired ? -1 : 1

      return (a.name || a.address).localeCompare(b.name || b.address)
    })
  }

  readonly property BluetoothDevice selectedDevice: {
    if (sortedDevices.length === 0) return null
    const idx = deviceList.currentIndex
    if (idx < 0 || idx >= sortedDevices.length) return null
    return sortedDevices[idx]
  }

  function adapterStateText(): string {
    if (!currentAdapter) return ""
    switch (currentAdapter.state) {
      case BluetoothAdapterState.Enabled:   return "On"
      case BluetoothAdapterState.Disabled:  return "Off"
      case BluetoothAdapterState.Enabling:  return "Enabling…"
      case BluetoothAdapterState.Disabling: return "Disabling…"
      case BluetoothAdapterState.Blocked:   return "Blocked"
      default: return ""
    }
  }

  function adapterStateColor(): color {
    if (!currentAdapter) return Global.colors.outline
    switch (currentAdapter.state) {
      case BluetoothAdapterState.Enabled:   return Global.colors.primary
      case BluetoothAdapterState.Disabled:  return Global.colors.outline
      case BluetoothAdapterState.Enabling:
      case BluetoothAdapterState.Disabling: return Global.colors.secondary
      case BluetoothAdapterState.Blocked:   return Global.colors.error
      default: return Global.colors.outline
    }
  }

  function deviceStateIcon(dev): string {
    if (!dev) return ""
    if (dev.blocked) return "󱘖"
    switch (dev.state) {
      case BluetoothDeviceState.Connected:     return "󰂱"
      case BluetoothDeviceState.Connecting:    return "󰂴"
      case BluetoothDeviceState.Disconnecting: return "󰂴"
      default: return dev.paired ? "󰂲" : "󰂳"
    }
  }

  function deviceActionText(dev): string {
    if (!dev) return ""
    if (dev.state === BluetoothDeviceState.Connecting) return "Connecting…"
    if (dev.state === BluetoothDeviceState.Disconnecting) return "Disconnecting…"
    return dev.state === BluetoothDeviceState.Connected ? "Disconnect" : "Connect"
  }

  function detailStateText(dev): string {
    if (!dev) return ""
    let parts = [BluetoothDeviceState.toString(dev.state)]
    if (dev.paired)  parts.push("Paired")
    if (dev.bonded)  parts.push("Bonded")
    if (dev.trusted) parts.push("Trusted")
    if (dev.blocked) parts.push("Blocked")
    return parts.join(" · ")
  }

  function detailInfoText(dev): string {
    if (!dev) return ""
    let parts = []
    if (dev.batteryAvailable)
      parts.push("Battery " + Math.round(dev.battery * 100) + "%")
    if (dev.adapter)
      parts.push(dev.adapter.name)
    return parts.join(" · ") || "—"
  }

  function emptyStateText(): string {
    if (!currentAdapter) return "No adapter"
    switch (currentAdapter.state) {
      case BluetoothAdapterState.Blocked:   return "Adapter blocked by rfkill"
      case BluetoothAdapterState.Enabling:  return "Enabling adapter…"
      case BluetoothAdapterState.Disabling: return "Disabling adapter…"
    }
    if (!currentAdapter.enabled) return "Bluetooth is off"
    if (currentAdapter.discovering) return "Scanning for devices…"
    return "No devices found"
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: Global.format.spacing_medium

    // Adapter header row
    RowLayout {
      Layout.fillWidth: true
      spacing: Global.format.spacing_medium

      Row {
        spacing: Global.format.spacing_small

        Repeater {
          model: Bluetooth.adapters
          delegate: Text {
            required property var modelData
            required property int index
            text: modelData.name + " " + modelData.adapterId
            color: root.adapterIndex === index ? Global.colors.primary : Global.colors.on_surface_variant
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            font.bold: root.adapterIndex === index

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.adapterIndex = index
            }
          }
        }
      }

      Item { Layout.fillWidth: true }

      Text {
        visible: root.currentAdapter?.enabled
        text: root.currentAdapter?.discoverable ? "  Discoverable" : "  Undiscoverable"
        color: root.currentAdapter?.discoverable ? Global.colors.primary : Global.colors.on_surface_variant
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: { if (root.currentAdapter) root.currentAdapter.discoverable = !root.currentAdapter.discoverable }
        }
      }

      Text {
        visible: root.currentAdapter?.enabled
        text: root.currentAdapter?.pairable ? "  Pairable" : "  Unpairable"
        color: root.currentAdapter?.pairable ? Global.colors.primary : Global.colors.on_surface_variant
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: { if (root.currentAdapter) root.currentAdapter.pairable = !root.currentAdapter.pairable }
        }
      }

      Text {
        visible: root.currentAdapter?.enabled
        text: root.currentAdapter?.discovering ? "  Scanning…" : "  Scan"
        color: root.currentAdapter?.discovering ? Global.colors.primary : Global.colors.on_surface_variant
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: { if (root.currentAdapter) root.currentAdapter.discovering = !root.currentAdapter.discovering }
        }
      }

      Text {
        text: root.adapterStateText()
        color: root.adapterStateColor()
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: { if (root.currentAdapter) root.currentAdapter.enabled = !root.currentAdapter.enabled }
        }
      }
    }

    // Device list
    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      Text {
        anchors.centerIn: parent
        visible: root.sortedDevices.length === 0
        color: Global.colors.outline
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        text: root.emptyStateText()
      }

      ListView {
        id: deviceList
        anchors.fill: parent
        orientation: ListView.Horizontal
        clip: true
        spacing: Global.format.spacing_medium
        currentIndex: 0
        highlightMoveDuration: 200
        model: root.sortedDevices

        onModelChanged: {
          currentIndex = Math.min(currentIndex, count - 1)
          if (currentIndex >= 0) positionViewAtIndex(currentIndex, ListView.Center)
        }

        delegate: Item {
          id: card
          required property BluetoothDevice modelData
          required property int index
          width: 200
          height: deviceList.height

          property bool isTransitioning: modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting

          ColumnLayout {
            anchors.fill: parent
            spacing: Global.format.spacing_small

            Rectangle {
              Layout.fillWidth: true
              Layout.fillHeight: true
              color: "transparent"
              border.color: deviceList.currentIndex === card.index
                ? Global.colors.tertiary
                : cardMouse.containsMouse
                  ? Global.colors.on_surface
                  : modelData.state === BluetoothDeviceState.Connected
                    ? Global.colors.primary
                    : Global.colors.outline
              border.width: 1

              Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Global.format.spacing_small
                text: root.deviceStateIcon(modelData)
                color: modelData.state === BluetoothDeviceState.Connected ? Global.colors.primary
                  : modelData.blocked ? Global.colors.error
                  : Global.colors.outline
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
              }

              Text {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: Global.format.spacing_small
                visible: modelData.batteryAvailable && modelData.state === BluetoothDeviceState.Connected
                text: Math.round(modelData.battery * 100) + "%"
                color: Global.colors.on_surface_variant
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
              }

              Text {
                anchors.centerIn: parent
                text: modelData.name || modelData.address
                color: cardMouse.containsMouse
                  ? Global.colors.on_surface
                  : modelData.state === BluetoothDeviceState.Connected
                    ? Global.colors.primary
                    : Global.colors.on_surface_variant
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
                font.bold: modelData.state === BluetoothDeviceState.Connected
                elide: Text.ElideRight
                width: parent.width - Global.format.spacing_medium * 2
                horizontalAlignment: Text.AlignHCenter
              }

              Text {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Global.format.spacing_small
                text: root.deviceActionText(modelData)
                color: card.isTransitioning
                  ? Global.colors.outline
                  : modelData.state === BluetoothDeviceState.Connected
                    ? Global.colors.error
                    : Global.colors.on_surface_variant
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  enabled: !card.isTransitioning
                  onClicked: {
                    if (modelData.state === BluetoothDeviceState.Connected)
                      modelData.disconnect()
                    else
                      modelData.connect()
                  }
                }
              }

              MouseArea {
                id: cardMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: deviceList.currentIndex = card.index
                onDoubleClicked: {
                  if (card.isTransitioning) return
                  if (modelData.state === BluetoothDeviceState.Connected)
                    modelData.disconnect()
                  else
                    modelData.connect()
                }
                onWheel: (wheel) => {
                  if (wheel.angleDelta.x < 0 || wheel.angleDelta.y < 0) {
                    if (deviceList.currentIndex < deviceList.count - 1)
                      deviceList.currentIndex++
                  } else {
                    if (deviceList.currentIndex > 0)
                      deviceList.currentIndex--
                  }
                }
              }
            }
          }
        }
      }
    }

    // Detail panel
    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: root.selectedDevice ? 56 : 0
      visible: root.selectedDevice !== null
      color: "transparent"
      border.color: Global.colors.outline
      border.width: 1

      Item {
        anchors.fill: parent
        anchors.margins: Global.format.spacing_small

        Column {
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          spacing: 2

          Text {
            text: root.selectedDevice?.name || root.selectedDevice?.address || ""
            color: Global.colors.on_surface
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            font.bold: true
            elide: Text.ElideRight
            width: 160
          }

          Text {
            text: root.selectedDevice?.address || ""
            color: Global.colors.outline
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.font_size_small
          }
        }

        Column {
          anchors.centerIn: parent
          spacing: 2

          Text {
            text: root.detailStateText(root.selectedDevice)
            color: Global.colors.on_surface_variant
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.font_size_small
            width: 200
            horizontalAlignment: Text.AlignHCenter
          }

          Text {
            text: root.detailInfoText(root.selectedDevice)
            color: Global.colors.outline
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.font_size_small
            width: 200
            horizontalAlignment: Text.AlignHCenter
          }
        }

        RowLayout {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: Global.format.spacing_medium

          Text {
            visible: root.selectedDevice && !root.selectedDevice.trusted
            text: "Trust"
            color: trustMouse.containsMouse ? Global.colors.primary : Global.colors.on_surface_variant
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            MouseArea {
              id: trustMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: { if (root.selectedDevice) root.selectedDevice.trusted = true }
            }
          }

          Text {
            visible: root.selectedDevice && root.selectedDevice.trusted
            text: "Untrust"
            color: trustMouse2.containsMouse ? Global.colors.primary : Global.colors.on_surface_variant
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            MouseArea {
              id: trustMouse2
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: { if (root.selectedDevice) root.selectedDevice.trusted = false }
            }
          }

          Text {
            visible: root.selectedDevice && !root.selectedDevice.blocked
            text: "Block"
            color: blockMouse.containsMouse ? Global.colors.error : Global.colors.on_surface_variant
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            MouseArea {
              id: blockMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: { if (root.selectedDevice) root.selectedDevice.blocked = true }
            }
          }

          Text {
            visible: root.selectedDevice && root.selectedDevice.blocked
            text: "Unblock"
            color: blockMouse2.containsMouse ? Global.colors.error : Global.colors.on_surface_variant
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            MouseArea {
              id: blockMouse2
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: { if (root.selectedDevice) root.selectedDevice.blocked = false }
            }
          }
        }
      }
    }
  }
}
