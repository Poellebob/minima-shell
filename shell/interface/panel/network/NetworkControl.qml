import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.components.text
import qs

Item {
  id: root
  implicitWidth: 360

  readonly property var wifiDevice: Networking.devices.values.find(
                                       dev => dev?.type === DeviceType.Wifi) ?? null
  readonly property var wiredDevice: Networking.devices.values.find(
                                        dev => dev?.type === DeviceType.Wired) ?? null
  readonly property var connectedWifi: root.wifiDevice?.networks.values.find(
                                          net => net?.connected) ?? null
  property var pendNet: null

  onVisibleChanged: {
    if (!visible)
      pendNet = null;
  }

  function signalGlyph(strength: real): string {
    if (strength >= 0.75)
      return "󰤨";
    if (strength >= 0.5)
      return "󰤥";
    if (strength >= 0.25)
      return "󰤢";
    return "󰤟";
  }

  function netStateText(net): string {
    if (!net)
      return "";
    if (net.connected)
      return "Connected";
    switch (net.state) {
    case ConnectionState.Connecting:
      return "Connecting";
    case ConnectionState.Disconnecting:
      return "Disconnecting";
    default:
      return net.known ? "Saved" : "";
    }
  }

  function netStateColor(net): color {
    if (net?.connected)
      return Global.colors.primary;
    switch (net?.state) {
    case ConnectionState.Connecting:
    case ConnectionState.Disconnecting:
      return Global.colors.on_surface;
    default:
      return net?.known ? Global.colors.on_surface_variant :
                          Global.colors.outline;
    }
  }

  function securityText(sec): string {
    switch (sec) {
    case WifiSecurityType.Open:
      return "Open";
    case WifiSecurityType.WpaPsk:
      return "WPA";
    case WifiSecurityType.Wpa2Psk:
      return "WPA2";
    case WifiSecurityType.Sae:
    case WifiSecurityType.Wpa3SuiteB192:
      return "WPA3";
    case WifiSecurityType.WpaEap:
    case WifiSecurityType.Wpa2Eap:
      return "Enterprise";
    case WifiSecurityType.StaticWep:
    case WifiSecurityType.DynamicWep:
      return "WEP";
    case WifiSecurityType.Leap:
      return "LEAP";
    case WifiSecurityType.Owe:
      return "OWE";
    default:
      return "Secured";
    }
  }

  function submitPsk() {
    if (!root.pendNet || pskInput.text === "")
      return;
    root.pendNet.connectWithPsk(pskInput.text);
    root.pendNet = null;
  }

  ColumnLayout {
    id: contentCol
    anchors.fill: parent
    spacing: Global.format.spacing_large

    Item {
      id: header
      Layout.fillWidth: true
      Layout.preferredHeight: Global.format.module_height
                             + Global.format.spacing_small

      RowLayout {
        id: headerLeft
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Global.format.spacing_medium

        StyledText {
          text: root.connectedWifi ? root.signalGlyph(
                  root.connectedWifi.signalStrength) : root.wiredDevice?.connected
                                           ? "󰈀" : "󰤭"
          color: root.connectedWifi || root.wiredDevice?.connected ?
                 Global.colors.primary : Global.colors.outline
        }

        ClickableText {
          visible: root.wiredDevice
          text: root.wiredDevice?.network?.name || "Ethernet"
          baseColor: Global.colors.on_surface_variant
          hoverColor: Global.colors.on_background
          font.bold: true
          mouseEnabled: root.wiredDevice?.network != null

          onClicked: {
            const net = root.wiredDevice?.network;
            if (!net)
              return;
            if (net.connected)
              net.disconnect();
            else
              net.connect();
          }
        }
      }

      RowLayout {
        id: headerRight
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Global.format.spacing_medium

        ClickableText {
          visible: root.wifiDevice
          text: root.wifiDevice?.autoconnect ? "Autoconnect" : "Manual"
          baseColor: root.wifiDevice?.autoconnect ? Global.colors.primary :
                                                   Global.colors.outline
          hoverColor: Global.colors.on_background

          onClicked: root.wifiDevice.autoconnect = !root.wifiDevice.autoconnect
        }

        ClickableText {
          visible: root.wifiDevice && Networking.wifiEnabled
          text: root.wifiDevice?.scannerEnabled ? "Scanning" : "Scan"
          baseColor: root.wifiDevice?.scannerEnabled ? Global.colors.primary :
                                                      Global.colors.on_surface_variant
          hoverColor: Global.colors.on_background

          onClicked: root.wifiDevice.scannerEnabled
                      = !root.wifiDevice.scannerEnabled
        }

        ClickableText {
          visible: root.wifiDevice
          text: Networking.wifiEnabled ? "On" : "Off"
          baseColor: Networking.wifiEnabled ? Global.colors.primary :
                                             Global.colors.outline
          hoverColor: Global.colors.error

          onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
        }
      }

      StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: root.wifiDevice && !Networking.wifiHardwareEnabled
              ? "HW blocked" : root.wiredDevice?.connected
                                 ? "Connected" : "Disconnected"
        color: root.wifiDevice && !Networking.wifiHardwareEnabled
               ? Global.colors.error : root.wiredDevice?.connected
                                          ? Global.colors.primary :
                                            Global.colors.outline
      }
    }

    Rectangle {
      visible: root.wifiDevice
      Layout.fillWidth: true
      Layout.preferredHeight: 200
      color: "transparent"
      border.color: Global.colors.outline
      border.width: 1

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Global.format.spacing_small
        spacing: Global.format.spacing_small

        ListView {
          id: wifiList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: Global.format.spacing_tiny

          model: root.wifiDevice?.networks

          StyledText {
            anchors.centerIn: parent
            text: !Networking.wifiEnabled ? "Wifi off" :
                   root.wifiDevice?.scannerEnabled ? "Scanning..." :
                   "No networks"
            color: Global.colors.outline
            visible: wifiList.count <= 0
          }

          delegate: Item {
            id: networkItem
            required property WifiNetwork modelData
            width: wifiList.width
            height: Global.format.module_height + Global.format.spacing_small

            MouseArea {
              id: networkRowMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              propagateComposedEvents: true
              onClicked: {
                if (networkItem.modelData.stateChanging)
                  return;
                if (networkItem.modelData.connected)
                  networkItem.modelData.disconnect();
                else
                  networkItem.modelData.connect();
              }

              Item {
                anchors.fill: parent
                anchors.leftMargin: Global.format.spacing_small
                anchors.rightMargin: Global.format.spacing_small

                ClickableText {
                  id: nameText
                  anchors.left: parent.left
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.right: securityText.left
                  anchors.rightMargin: Global.format.spacing_small
                  text: root.signalGlyph(networkItem.modelData.signalStrength)
                        + " " + networkItem.modelData.name
                  baseColor: networkItem.modelData.connected ?
                             Global.colors.primary :
                             Global.colors.on_surface_variant
                  elide: Text.ElideRight
                  mouseEnabled: false
                  hoverOverride: networkRowMouse.containsMouse
                }

                StyledText {
                  id: securityText
                  anchors.horizontalCenter: parent.horizontalCenter
                  anchors.verticalCenter: parent.verticalCenter
                  text: root.securityText(networkItem.modelData.security)
                  color: Global.colors.on_surface_variant
                }

                Item {
                  id: rightControls
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  width: rightRow.implicitWidth
                  height: rightRow.implicitHeight
                  visible: networkItem.modelData.known ||
                           root.netStateText(networkItem.modelData) !== ""

                  Row {
                    id: rightRow
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Global.format.spacing_small

                    StyledText {
                      text: root.netStateText(networkItem.modelData)
                      color: root.netStateColor(networkItem.modelData)
                      visible: text !== ""
                    }

                    ClickableText {
                      visible: networkItem.modelData.known
                      text: "󰅖"
                      baseColor: Global.colors.on_surface_variant
                      hoverColor: Global.colors.error
                      onClicked: networkItem.modelData.forget()
                    }
                  }
                }
              }
            }

            Connections {
              target: networkItem.modelData
              function onConnectionFailed(reason) {
                if (reason !== ConnectionFailReason.NoSecrets)
                  return;
                switch (networkItem.modelData.security) {
                case WifiSecurityType.WpaPsk:
                case WifiSecurityType.Wpa2Psk:
                case WifiSecurityType.Sae:
                  break;
                default:
                  return;
                }
                root.pendNet = networkItem.modelData;
                pskInput.text = "";
                pskInput.forceActiveFocus();
              }
            }
          }
        }

        RowLayout {
          visible: root.pendNet
          Layout.fillWidth: true
          spacing: Global.format.spacing_small

          StyledText {
            text: "Password"
            color: Global.colors.on_surface_variant
          }

          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Global.format.module_height
                                    + Global.format.spacing_small
            color: "transparent"
            border.color: Global.colors.outline
            border.width: 1

            TextInput {
              id: pskInput
              anchors.fill: parent
              anchors.leftMargin: Global.format.spacing_small
              anchors.rightMargin: Global.format.spacing_small
              color: Global.colors.on_background
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: Global.format.text_size
              verticalAlignment: Text.AlignVCenter
              clip: true
              echoMode: TextInput.Password
              passwordCharacter: "*"

              onAccepted: root.submitPsk()
              Keys.onEscapePressed: root.pendNet = null
            }
          }

          ClickableText {
            text: "Connect"
            baseColor: Global.colors.primary
            hoverColor: Global.colors.on_background

            onClicked: root.submitPsk()
          }

          ClickableText {
            text: "Cancel"
            baseColor: Global.colors.outline
            hoverColor: Global.colors.on_background

            onClicked: root.pendNet = null
          }
        }
      }
    }
  }

  implicitHeight: contentCol.implicitHeight
}
