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
    for (const key in adapter.devices.values)
      devs.push(adapter.devices.values[key])
    return devs
  }

  readonly property var sortedDevices: {
    const devs = devices.filter(d => d !== null)
    return devs.slice().sort((a, b) => {
      const aConnected = a.state === BluetoothDeviceState.Connected
      const bConnected = b.state === BluetoothDeviceState.Connected
      if (aConnected !== bConnected) return aConnected ? -1 : 1

      const aPaired = a.paired
      const bPaired = b.paired
      if (aPaired !== bPaired) return aPaired ? -1 : 1

      const aNamed = a.name !== ""
      const bNamed = b.name !== ""
      if (aNamed !== bNamed) return aNamed ? -1 : 1

      return (a.name || a.address).localeCompare(b.name || b.address)
    })
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: Global.format.spacing_medium

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
            text: modelData.name
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
        visible: root.currentAdapter !== null && (root.currentAdapter?.enabled ?? false)
        text: root.currentAdapter?.discovering ? " 󰑎 Scanning…" : " 󰐷 Scan"
        color: root.currentAdapter?.discovering ? Global.colors.primary : Global.colors.on_surface_variant
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.currentAdapter)
              root.currentAdapter.discovering = !root.currentAdapter.discovering
          }
        }
      }

      Text {
        text: (root.currentAdapter?.enabled ?? false) ? "On" : "Off"
        color: (root.currentAdapter?.enabled ?? false) ? Global.colors.primary : Global.colors.outline
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.currentAdapter)
              root.currentAdapter.enabled = !root.currentAdapter.enabled
          }
        }
      }
    }

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      Text {
        anchors.centerIn: parent
        visible: root.sortedDevices.length === 0
        color: Global.colors.outline
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        text: {
          if (!root.currentAdapter) return "No adapter"
          if (!(root.currentAdapter.enabled ?? false)) return "Bluetooth is off"
          if (root.currentAdapter.discovering) return "Scanning for devices…"
          return "No devices found"
        }
      }

      ListView {
        id: deviceList
        anchors.fill: parent
        orientation: ListView.Horizontal
        clip: true
        spacing: Global.format.spacing_medium
        currentIndex: 0
        highlightMoveDuration: 200

        onModelChanged: {
          currentIndex = Math.min(currentIndex, count - 1)
          if (currentIndex >= 0)
            positionViewAtIndex(currentIndex, ListView.Center)
        }

        model: root.sortedDevices

        delegate: Item {
          id: deviceItem
          required property BluetoothDevice modelData
          required property int index
          width: 200
          height: deviceList.height
          visible: modelData !== null

          property bool isValid: modelData !== null
          property bool isConnected: isValid && modelData.state === BluetoothDeviceState.Connected
          property bool isTransitioning: isValid && (modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting)

          function deviceState(): string {
            if (!isValid) return ""
            switch (modelData.state) {
              case BluetoothDeviceState.Connected:     return "󰂱"
              case BluetoothDeviceState.Connecting:    return "󰂴"
              case BluetoothDeviceState.Disconnecting: return "󰂴"
              default: return modelData.paired ? "󰂲" : "󰂳"
            }
          }

          function deviceName(): string {
            if (!isValid) return ""
            return modelData.name || modelData.address
          }

          function statusText(): string {
            if (!isValid) return ""
            let parts = []
            if (modelData.paired)  parts.push("Paired")
            if (modelData.bonded)  parts.push("Bonded")
            if (modelData.trusted) parts.push("Trusted")
            if (modelData.blocked) parts.push("Blocked")
            return parts.join(" · ") || modelData.address
          }

          function actionText(): string {
            if (!isValid) return ""
            if (isTransitioning)
              return modelData.state === BluetoothDeviceState.Connecting ? "Connecting…" : "Disconnecting…"
            return isConnected ? "Disconnect" : "Connect"
          }

          ColumnLayout {
            anchors.fill: parent
            spacing: Global.format.spacing_small

            Rectangle {
              Layout.fillWidth: true
              Layout.fillHeight: true
              color: "transparent"
              border.color: cardMouseArea.containsMouse
                ? Global.colors.on_surface
                : deviceItem.isConnected
                  ? Global.colors.primary
                  : Global.colors.outline
              border.width: 1

              Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Global.format.spacing_small
                text: deviceItem.isValid ? deviceItem.deviceState() : ""
                color: deviceItem.isConnected ? Global.colors.primary : Global.colors.outline
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.icon_size
              }

              Text {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: Global.format.spacing_small
                visible: deviceItem.isValid && modelData.batteryAvailable && deviceItem.isConnected
                text: deviceItem.isValid ? Math.round(modelData.battery * 100) + "%" : ""
                color: Global.colors.on_surface_variant
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.font_size_small
              }

              Text {
                anchors.centerIn: parent
                text: deviceItem.deviceName()
                color: cardMouseArea.containsMouse
                  ? Global.colors.on_surface
                  : deviceItem.isConnected
                    ? Global.colors.primary
                    : Global.colors.on_surface_variant
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
                font.bold: deviceItem.isConnected
                elide: Text.ElideRight
                width: parent.width - Global.format.spacing_medium * 2
                horizontalAlignment: Text.AlignHCenter
              }

              MouseArea {
                id: cardMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: deviceList.currentIndex = deviceItem.index
                onDoubleClicked: {
                  if (!deviceItem.isValid || deviceItem.isTransitioning) return
                  if (deviceItem.isConnected)
                    deviceItem.modelData.disconnect()
                  else
                    deviceItem.modelData.connect()
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

                Text {
                  anchors.top: parent.top
                  anchors.right: parent.right
                  anchors.margins: Global.format.spacing_small
                  visible: deviceItem.isValid && modelData.paired && !deviceItem.isConnected
                  text: " 󰩺 "
                  color: unpairMouse.containsMouse ? Global.colors.error : Global.colors.outline
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: Global.format.font_size_medium

                  MouseArea {
                    id: unpairMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    propagateComposedEvents: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => { if (deviceItem.isValid) deviceItem.modelData.forget(); mouse.accepted = false }
                  }
                }
              }

              Text {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Global.format.spacing_small
                text: deviceItem.actionText()
                color: deviceItem.isTransitioning
                  ? Global.colors.outline
                  : (deviceItem.isConnected ? Global.colors.error : Global.colors.on_surface_variant)
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.font_size_small
                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  acceptedButtons: Qt.LeftButton
                  propagateComposedEvents: true
                  enabled: !deviceItem.isTransitioning
                  onClicked: (mouse) => {
                    if (deviceItem.isValid) {
                      if (deviceItem.isConnected)
                        deviceItem.modelData.disconnect()
                      else
                        deviceItem.modelData.connect()
                    }
                    mouse.accepted = false
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
