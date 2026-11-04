import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.components.widget
import qs.components.text
import qs

Item {
  id: root

  readonly property UPowerDevice battery: UPower.displayDevice
  readonly property bool charging: battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge
                                   || battery.state === UPowerDeviceState.FullyCharged
  readonly property real columnWidth: (width - Global.format.spacing_large) / 2
  readonly property bool hasBattery: battery.ready && battery.isLaptopBattery
  property bool showUnknown: false
  property bool powerProfilesAvailable: false

  // Do not touch the singleton until the daemon owns its name: QS 0.3.0
  // does not retry if its initial D-Bus activation fails.
  Process {
    id: powerProfilesCheck

    command: ["busctl", "--system", "--timeout=2s", "call", "org.freedesktop.DBus",
      "/org/freedesktop/DBus", "org.freedesktop.DBus", "NameHasOwner", "s",
      "org.freedesktop.UPower.PowerProfiles"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.powerProfilesAvailable = text.trim() === "b true"
    }
    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0 || exitStatus !== 0)
        root.powerProfilesAvailable = false;
    }
  }

  Timer {
    interval: 2000
    repeat: true
    running: true
    onTriggered: {
      if (!powerProfilesCheck.running)
        powerProfilesCheck.running = true;
    }
  }

  function formatDuration(seconds) {
    if (seconds <= 0)
      return "—";
    const totalMinutes = Math.round(seconds / 60);
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    if (hours > 0)
      return `${hours}h ${minutes}m`;
    return `${minutes}m`;
  }
  function getBatteryIcon(name) {
    switch (name) {
    case "battery-empty-symbolic":
      return "󰂎";
    case "battery-caution-symbolic":
      return "󰂃";
    case "battery-low-symbolic":
      return "󱊡";
    case "battery-good-symbolic":
      return "󱊢";
    case "battery-full-symbolic":
      return "󱊣";
    case "battery-full-charging-symbolic":
      return "󰂄";
    case "battery-charging-symbolic":
      return "󰂄";
    case "battery-low-charging-symbolic":
      return "󰂄";
    default:
      return "󰁹";
    }
  }

  implicitHeight: contentCol.implicitHeight
  implicitWidth: 600

  ColumnLayout {
    id: contentCol

    anchors.fill: parent
    spacing: Global.format.spacing_large

    RowLayout {
      Layout.fillWidth: true
      Layout.preferredHeight: Global.format.module_height
      spacing: Global.format.spacing_medium

      StyledText {
        color: root.battery.percentage * 100 < 15 && !root.charging ? Global.colors.error : Global.colors.on_surface
        font.bold: true
        text: `${Math.round(root.battery.percentage * 100)}%`
        visible: root.hasBattery
      }

      StyledText {
        color: root.charging ? Global.colors.primary : Global.colors.on_surface_variant
        text: UPower.onBattery ? "On battery" : "Plugged in"
      }

      Item {
        Layout.fillWidth: true
      }

      Loader {
        id: profileControls

        active: root.powerProfilesAvailable
        visible: false
        sourceComponent: QtObject {

          // Like dux-shell's PowerProfileWatcher, only offer supported profiles
          // and validate requests again when applying them.
          readonly property var availableProfiles: [PowerProfile.PowerSaver, PowerProfile.Balanced]
            .concat(PowerProfiles.hasPerformanceProfile ? [PowerProfile.Performance] : [])
          readonly property int currentProfile: PowerProfiles.profile
          readonly property string degradationText: PowerProfiles.degradationReason
            !== PerformanceDegradationReason.None
            ? PerformanceDegradationReason.toString(PowerProfiles.degradationReason) : ""

          function applyProfile(profile) {
            if (!root.powerProfilesAvailable || availableProfiles.indexOf(profile) === -1)
              return;
            PowerProfiles.profile = profile;
          }
        }
      }

      Repeater {
        model: [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]

        delegate: ClickableText {
          required property var modelData
          readonly property bool isAvailable: root.powerProfilesAvailable && profileControls.item !== null
            && profileControls.item.availableProfiles.indexOf(modelData) !== -1
          readonly property bool isActive: isAvailable && modelData === profileControls.item.currentProfile

          baseColor: !isAvailable ? Global.colors.outline
            : isActive ? Global.colors.primary : Global.colors.on_surface_variant
          mouseEnabled: isAvailable
          opacity: isAvailable ? 1 : 0.5
          text: PowerProfile.toString(modelData)

          onClicked: {
            if (isAvailable)
              profileControls.item.applyProfile(modelData);
          }
        }
      }

      Item {
        Layout.fillWidth: true
      }

      StyledText {
        color: root.charging ? Global.colors.primary : Global.colors.on_surface_variant
        text: UPowerDeviceState.toString(root.battery.state)
        visible: root.hasBattery
      }
    }

    StyledText {
      color: Global.colors.error
      text: profileControls.item ? profileControls.item.degradationText : ""
      visible: text !== ""
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: Global.format.spacing_large

      Rectangle {
        Layout.fillHeight: true
        Layout.preferredWidth: root.columnWidth
        border.color: Global.colors.outline
        border.width: 1
        color: "transparent"
        implicitHeight: batteryCol.implicitHeight + Global.format.spacing_small * 2

        ColumnLayout {
          id: batteryCol

          spacing: Global.format.spacing_small
          width: parent.width - Global.format.spacing_small * 2
          x: Global.format.spacing_small
          y: Global.format.spacing_small

          StyledText {
            color: Global.colors.primary
            font.bold: true
            text: "Battery"
          }

          StyledText {
            color: Global.colors.outline
            text: "No battery detected"
            visible: !root.hasBattery
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Global.format.spacing_medium
            visible: root.hasBattery

            StyledText {
              color: Global.colors.on_surface_variant
              text: root.battery.timeToFull > 0 ? "Time to full" : "Time to empty"
            }

            StyledText {
              Layout.fillWidth: true
              color: Global.colors.on_surface
              horizontalAlignment: Text.AlignRight
              text: root.formatDuration(root.battery.timeToFull > 0 ? root.battery.timeToFull :
                                                                      root.battery.timeToEmpty)

            }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Global.format.spacing_medium
            visible: root.hasBattery

            StyledText {
              color: Global.colors.on_surface_variant
              text: "Energy"
            }

            StyledText {
              Layout.fillWidth: true
              color: Global.colors.on_surface
              horizontalAlignment: Text.AlignRight
              text: `${root.battery.energy.toFixed(1)} / ${root.battery.energyCapacity.toFixed(1)} Wh`
            }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Global.format.spacing_medium
            visible: root.hasBattery

            StyledText {
              color: Global.colors.on_surface_variant
              text: "Rate"
            }

            StyledText {
              Layout.fillWidth: true
              color: Global.colors.on_surface
              horizontalAlignment: Text.AlignRight
              text: root.battery.changeRate !== 0 ? `${root.battery.changeRate.toFixed(1)} W` : "—"
            }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Global.format.spacing_medium
            visible: root.hasBattery && root.battery.healthSupported

            StyledText {
              color: Global.colors.on_surface_variant
              text: "Health"
            }

            StyledText {
              Layout.fillWidth: true
              color: Global.colors.on_surface
              horizontalAlignment: Text.AlignRight
              text: `${Math.round(root.battery.healthPercentage * 100)}%`
            }
          }
        }
      }

      Rectangle {
        Layout.fillHeight: true
        Layout.preferredWidth: root.columnWidth
        border.color: Global.colors.outline
        border.width: 1
        color: "transparent"
        implicitHeight: batteryCol.implicitHeight + Global.format.spacing_small * 2

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: Global.format.spacing_small
          spacing: Global.format.spacing_small

          RowLayout {
            Layout.fillWidth: true
            spacing: Global.format.spacing_medium

            StyledText {
              color: Global.colors.primary
              font.bold: true
              text: "Devices"
            }

            Item {
              Layout.fillWidth: true
            }

            ClickableText {
              baseColor: root.showUnknown ? Global.colors.primary : Global.colors.on_surface_variant
              hoverColor: Global.colors.on_background
              text: root.showUnknown ? "Hide unknown" : "Show unknown"

              onClicked: root.showUnknown = !root.showUnknown
            }
          }

          ListView {
            id: deviceList

            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            model: {
              const devices = [];
              for (const val in UPower.devices.values) {
                const device = UPower.devices.values[val];
                if (root.showUnknown || (device.type !== UPowerDeviceType.Unknown && device.state
                                         !== UPowerDeviceState.Unknown))
                  devices.push(device);
              }
              return devices;
            }
            spacing: 0

            delegate: Item {
              id: deviceItem

              required property UPowerDevice modelData

              height: Global.format.module_height + Global.format.spacing_small
              width: deviceList.width

              RowLayout {
                anchors.fill: parent
                spacing: Global.format.spacing_small

                StyledText {
                  color: Global.colors.on_surface_variant
                  text: deviceItem.modelData.powerSupply && !deviceItem.modelData.isLaptopBattery ? "󰚥" : root.getBatteryIcon(
                                                                                                      deviceItem.modelData.iconName)
                }

                StyledText {
                  Layout.fillWidth: true
                  color: Global.colors.on_surface_variant
                  elide: Text.ElideRight
                  text: deviceItem.modelData.model || deviceItem.modelData.nativePath
                }

                StyledText {
                  color: Global.colors.on_surface_variant
                  text: `${Math.round(deviceItem.modelData.percentage * 100)}%`
                  visible: deviceItem.modelData.percentage > 0
                }

                StyledText {
                  color: deviceItem.modelData.state === UPowerDeviceState.Charging || deviceItem.modelData.state
                         === UPowerDeviceState.FullyCharged ? Global.colors.primary : Global.colors.outline
                  text: UPowerDeviceState.toString(deviceItem.modelData.state)
                }
              }
            }

            StyledText {
              anchors.centerIn: parent
              color: Global.colors.outline
              text: "No devices"
              visible: deviceList.count <= 0
            }
          }
        }
      }
    }
  }
}
