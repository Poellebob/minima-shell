import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ExpandedPanel {
  id: homeExpanded

  function activate() {}
  function navigateUp() {}
  function navigateDown() {}

  RowLayout {
    anchors.fill: parent
    spacing: Global.format.spacing_large

    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: Global.format.spacing_medium

      Text {
        text: Qt.formatDateTime(new Date(), "HH:mm:ss")
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.font_size_xlarge
        font.bold: true
        color: Global.colors.primary
      }

      Text {
        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.font_size_medium
        color: Global.colors.on_surface
      }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Global.colors.outline_variant
      }

      ColumnLayout {
        spacing: Global.format.spacing_small

        Text {
          text: "Power"
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: Global.format.font_size_small
          font.bold: true
          color: Global.colors.on_surface_variant
        }

        RowLayout {
          spacing: Global.format.spacing_medium

          Rectangle {
            width: 36
            height: 36
            radius: Global.format.radius_small
            color: Global.colors.surface_variant

            Text {
              anchors.centerIn: parent
              text: "󰍃"
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: Global.format.font_size_large
              color: Global.colors.on_surface
            }
          }

          Rectangle {
            width: 36
            height: 36
            radius: Global.format.radius_small
            color: Global.colors.surface_variant

            Text {
              anchors.centerIn: parent
              text: "󰐥"
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: Global.format.font_size_large
              color: Global.colors.error
            }
          }

          Rectangle {
            width: 36
            height: 36
            radius: Global.format.radius_small
            color: Global.colors.surface_variant

            Text {
              anchors.centerIn: parent
              text: "󰜉"
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: Global.format.font_size_large
              color: Global.colors.on_surface
            }
          }
        }
      }
    }

    ColumnLayout {
      Layout.preferredWidth: 100
      Layout.fillHeight: true
      spacing: Global.format.spacing_small

      Text {
        text: "System"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.font_size_small
        font.bold: true
        color: Global.colors.on_surface_variant
      }

      Repeater {
        model: [
          { label: "CPU", value: "0%", color: Global.colors.primary },
          { label: "RAM", value: "0%", color: Global.colors.secondary },
          { label: "Disk", value: "0%", color: Global.colors.tertiary }
        ]

        ColumnLayout {
          spacing: 2

          Text {
            text: modelData.label
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.font_size_small
            color: Global.colors.on_surface_variant
          }

          Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: Global.format.radius_small
            color: Global.colors.surface_variant

            Rectangle {
              anchors.bottom: parent.bottom
              width: parent.width
              height: parent.height * 0.5
              radius: parent.radius
              color: modelData.color
              opacity: 0.3
            }

            Text {
              anchors.centerIn: parent
              text: modelData.value
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: Global.format.text_size
              color: Global.colors.on_surface
            }
          }
        }
      }
    }
  }
}
