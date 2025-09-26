import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
  id: sysUsageRoot
  property real cpuPercent: 0
  property real ramPercent: 0
  property real diskPercent: 0

  RowLayout {
    anchors.fill: parent
    anchors.rightMargin: panel.format.spacing_large
    anchors.leftMargin: panel.format.spacing_large
    anchors.topMargin: 24
    anchors.bottomMargin: 24
    spacing: 0

    // CPU Usage Process
    Process {
      id: cpuUsage
      command: ["/bin/bash", "-c", "LC_ALL=C top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}'"]
      stdout: StdioCollector {
        onStreamFinished: {
          sysUsageRoot.cpuPercent = parseFloat(this.text)
        }
      }
    }

    // RAM Usage Process
    Process {
      id: ramUsage
      command: ["/bin/bash", "-c", "free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'"]
      stdout: StdioCollector {
        onStreamFinished: {
          sysUsageRoot.ramPercent = parseFloat(this.text)
        }
      }
    }

    // Disk Usage Process
    Process {
      id: diskUsage
      command: ["/bin/bash", "-c", "df / | tail -1 | awk '{print $5}' | sed 's/%//'"]
      stdout: StdioCollector {
        onStreamFinished: {
          sysUsageRoot.diskPercent = parseFloat(this.text)
        }
      }
    }

    Timer {
      id: usageTimer
      interval: panel.format.interval_short
      running: true
      repeat: true
      onTriggered: {
        cpuUsage.running = true
        ramUsage.running = true
        diskUsage.running = true
      }
    }

    // First column - CPU
    ColumnLayout {
      Layout.fillHeight: true
      Layout.preferredWidth: parent.width * (1 / 3)
      spacing: panel.format.spacing_large

      Rectangle {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: panel.format.spacing_large
        color: panel.colors.dark_background
        radius: panel.format.radius_medium

        Rectangle {
          anchors.bottom: parent.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          color: panel.colors.dark_primary
          implicitWidth: parent.width
          height: (parent.height / 100) * sysUsageRoot.cpuPercent
          radius: parent.radius

          Behavior on height {
            NumberAnimation {
              duration: 100
              easing.type: Easing.OutCubic
            }
          }
        }
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: panel.format.font_size_small
        Layout.bottomMargin: panel.format.font_size_small
        horizontalAlignment: Text.AlignHCenter
        text: ""
        font.family: "CommitMono Nerd Font Mono"
        font.pixelSize: panel.format.font_size_xlarge
        font.bold: true
        color: panel.colors.dark_on_surface_variant
      }
    }

    // Second column - RAM
    ColumnLayout {
      Layout.fillHeight: true
      Layout.preferredWidth: parent.width * (1 / 3)
      spacing: panel.format.spacing_large

      Rectangle {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: panel.format.spacing_large
        color: panel.colors.dark_background
        radius: panel.format.radius_medium

        Rectangle {
          anchors.bottom: parent.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          color: panel.colors.dark_secondary
          implicitWidth: parent.width
          height: (parent.height / 100) * sysUsageRoot.ramPercent
          radius: parent.radius

          Behavior on height {
            NumberAnimation {
              duration: 100
              easing.type: Easing.OutCubic
            }
          }
        }
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: panel.format.font_size_small
        Layout.bottomMargin: panel.format.font_size_small
        horizontalAlignment: Text.AlignHCenter
        text: ""
        font.family: "CommitMono Nerd Font Mono"
        font.pixelSize: panel.format.font_size_xlarge
        font.bold: true
        color: panel.colors.dark_on_surface_variant
      }
    }

    // Third column - Disk
    ColumnLayout {
      Layout.fillHeight: true
      Layout.preferredWidth: parent.width * (1 / 3)
      spacing: panel.format.spacing_large

      Rectangle {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: panel.format.spacing_large
        color: panel.colors.dark_background
        radius: panel.format.radius_medium

        Rectangle {
          anchors.bottom: parent.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          color: panel.colors.dark_tertiary
          implicitWidth: parent.width
          height: (parent.height / 100) * sysUsageRoot.diskPercent
          radius: parent.radius

          Behavior on height {
            NumberAnimation {
              duration: 100
              easing.type: Easing.OutCubic
            }
          }
        }
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: panel.format.font_size_small
        Layout.bottomMargin: panel.format.font_size_small
        horizontalAlignment: Text.AlignHCenter
        text: "󰋊"
        font.family: "CommitMono Nerd Font Mono"
        font.pixelSize: panel.format.font_size_large
        font.bold: true
        color: panel.colors.dark_on_surface_variant
      }
    }
  }
}