import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

Item {
  id: homeRoot

  implicitWidth: 540
  implicitHeight: 600

  property string fetchString
  property string fetchPath: Quickshell.shellDir + "/scripts/sysfetch.sh"

  Process {
    id: fetchRunner
    command: [fetchPath]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        homeRoot.fetchString = this.text
      }
    }
  }

  Timer {
    id: fetchTimer
    interval: Global.format.interval_xlong
    running: true
    repeat: true
    onTriggered: {
      fetchRunner.running = true
    }
  }

  Item {
    anchors.fill: parent
    anchors.margins: Global.format.spacing_small

    RowLayout {
      spacing: Global.format.spacing_large
      anchors.fill: parent

      ColumnLayout {
        spacing: Global.format.spacing_large
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width * 0.8

        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: parent.height * 0.14
          color: Global.colors.inverse_on_surface
          radius: Global.format.radius_large

          DateDisplay {
            anchors.fill: parent
          }
        }

        // Large middle rectangle
        Rectangle {
          id: mediaControls
          Layout.fillWidth: true
          Layout.fillHeight: true
          color: Global.colors.inverse_on_surface
          radius: Global.format.radius_large

          MediaPlayer {
            anchors.fill: parent
          }
        }

        // Bottom rectangle with logout buttons
        Rectangle {
          id: logoutArea
          Layout.fillWidth: true
          Layout.preferredHeight: 80
          color: Global.colors.inverse_on_surface
          radius: Global.format.radius_large

          RowLayout {
            anchors.fill: parent
            anchors.margins: Global.format.spacing_small
            spacing: Global.format.spacing_small

            Item { Layout.fillWidth: true }

            Rectangle {
              Layout.preferredWidth: 56
              Layout.preferredHeight: 56
              radius: Global.format.radius_large
              color: mouseArea1.containsPress ? Global.colors.surface_container_highest
                   : mouseArea1.containsMouse ? Global.colors.surface_container_high
                   : Global.colors.surface

              Text {
                anchors.centerIn: parent
                text: "󰍃"
                font.family: "CommitMono Nerd Font Mono"
                font.pixelSize: Global.format.font_size_large
                font.bold: true
                color: Global.colors.on_surface_variant
              }

              MouseArea {
                id: mouseArea1
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  Quickshell.execDetached([
                    "sh",
                    "-c",
                    "pid=$(cat /tmp/.hyprland-systemd-inhibit 2>/dev/null); [ -n \"$pid\" ] && kill \"$pid\" && rm -f /tmp/.hyprland-systemd-inhibit"
                  ])
                  Quickshell.execDetached(["loginctl", "terminate-session", Quickshell.env("XDG_SESSION_ID")])
                }
              }
            }

            Rectangle {
              Layout.preferredWidth: 56
              Layout.preferredHeight: 56
              radius: Global.format.radius_large
              color: mouseArea2.containsPress ? Global.colors.surface_container_highest
                   : mouseArea2.containsMouse ? Global.colors.surface_container_high
                   : Global.colors.surface

              Text {
                anchors.centerIn: parent
                text: "󰐥"
                font.family: "CommitMono Nerd Font Mono"
                font.pixelSize: Global.format.font_size_large
                font.bold: true
                color: Global.colors.on_surface_variant
              }

              MouseArea {
                id: mouseArea2
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  Quickshell.execDetached(["systemctl", "poweroff"])
                }
              }
            }

            Rectangle {
              Layout.preferredWidth: 56
              Layout.preferredHeight: 56
              radius: Global.format.radius_large
              color: mouseArea3.containsPress ? Global.colors.surface_container_highest
                   : mouseArea3.containsMouse ? Global.colors.surface_container_high
                   : Global.colors.surface

              Text {
                anchors.centerIn: parent
                text: "󰜉"
                font.family: "CommitMono Nerd Font Mono"
                font.pixelSize: Global.format.font_size_large
                font.bold: true
                color: Global.colors.on_surface_variant
              }

              MouseArea {
                id: mouseArea3
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  Quickshell.execDetached(["systemctl", "reboot"])
                }
              }
            }

            Rectangle {
              Layout.preferredWidth: 56
              Layout.preferredHeight: 56
              radius: Global.format.radius_large
              color: mouseArea4.containsPress ? Global.colors.surface_container_highest
                   : mouseArea4.containsMouse ? Global.colors.surface_container_high
                   : Global.colors.surface

              Text {
                anchors.centerIn: parent
                text: "󰒲"
                font.family: "CommitMono Nerd Font Mono"
                font.pixelSize: Global.format.font_size_large
                font.bold: true
                color: Global.colors.on_surface_variant
              }

              MouseArea {
                id: mouseArea4
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  Quickshell.execDetached(["systemctl", "suspend"])
                }
              }
            }

            Rectangle {
              Layout.preferredWidth: 56
              Layout.preferredHeight: 56
              radius: Global.format.radius_large
              color: mouseArea5.containsPress ? Global.colors.surface_container_highest
                   : mouseArea5.containsMouse ? Global.colors.surface_container_high
                   : Global.colors.surface

              Text {
                anchors.centerIn: parent
                text: "󰌾"
                font.family: "CommitMono Nerd Font Mono"
                font.pixelSize: Global.format.font_size_large
                font.bold: true
                color: Global.colors.on_surface_variant
              }

              MouseArea {
                id: mouseArea5
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  Quickshell.execDetached(["hyprlock"])
                }
              }
            }

            Rectangle {
              Layout.preferredWidth: 56
              Layout.preferredHeight: 56
              radius: Global.format.radius_large
              color: mouseArea6.containsPress ? Global.colors.surface_container_highest
                   : mouseArea6.containsMouse ? Global.colors.surface_container_high
                   : Global.colors.surface

              Text {
                anchors.centerIn: parent
                text: "󰤄"
                font.family: "CommitMono Nerd Font Mono"
                font.pixelSize: Global.format.font_size_large
                font.bold: true
                color: Global.colors.on_surface_variant
              }

              MouseArea {
                id: mouseArea6
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  Quickshell.execDetached(["systemctl", "hibernate"])
                }
              }
            }

            Item { Layout.fillWidth: true }
          }
        }

        // Sysfetch output
        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 140
          color: Global.colors.inverse_on_surface
          radius: Global.format.radius_large

          Text {
            anchors.fill: parent
            anchors.margins: Global.format.spacing_medium
            text: homeRoot.fetchString
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.bold: true
            wrapMode: Text.WrapAnywhere
            textFormat: Text.RichText
            color: Global.colors.on_surface_variant
          }
        }
      }

      // Right tall rectangle with audio and brightness controls
      Rectangle {
        id: audioAndBrightness
        Layout.fillHeight: true
        Layout.preferredWidth: parent.height * 0.235
        color: Global.colors.inverse_on_surface
        radius: Global.format.radius_large

        SystemUsage {
          anchors.fill: parent
        }
      }
    }
  }
}
