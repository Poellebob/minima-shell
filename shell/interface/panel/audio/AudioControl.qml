import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.components.widget
import qs.components.text
import qs

Item {
  id: root
  implicitWidth: 550
  implicitHeight: 200

  PwObjectTracker { objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource] }

  readonly property real columnWidth: (width - Global.format.spacing_large * 2) / 3

  RowLayout {
    anchors.fill: parent
    spacing: Global.format.spacing_large

    Rectangle {
      Layout.preferredWidth: root.columnWidth
      Layout.fillHeight: true
      color: "transparent"
      border.color: Global.colors.outline
      border.width: 1

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Global.format.spacing_small
        spacing: Global.format.spacing_small

        StyledText {
          text: "Inputs"
          font.bold: true
          color: Global.colors.primary
        }

        ListView {
          id: inputList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: Global.format.spacing_tiny

          model: {
            const sources = []
            for (const val in Pipewire.nodes.values) {
              const node = Pipewire.nodes.values[val]
              if (!node.isSink && !node.isStream && node.audio)
                sources.push(node)
            }
            return sources
          }

          StyledText {
            anchors.centerIn: parent
            text: "No inputs detected"
            color: Global.colors.outline
            visible: inputList.count <= 0
          }

          delegate: Item {
            required property var modelData
            width: inputList.width
            height: Global.format.module_height + Global.format.spacing_small

            property bool isDefault: Pipewire.defaultAudioSource?.id === modelData.id

            MouseArea {
              id: inputMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Pipewire.preferredDefaultAudioSource = modelData
              propagateComposedEvents: true

              RowLayout {
                anchors.fill: parent
                spacing: Global.format.spacing_small

                StyledText {
                  Layout.preferredWidth: parent.width * 0.4
                  text: "  " + (modelData.nickname || modelData.name || "Unnamed")
                  color: inputMouseArea.containsMouse
                    ? Global.colors.on_surface
                    : isDefault
                      ? Global.colors.primary
                      : Global.colors.on_surface_variant
                  elide: Text.ElideRight
                }

                StyledSlider {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  visible: modelData.ready
                  from: 0
                  to: 100
                  value: modelData.audio ? modelData.audio.volume * 100 : 0
                  onMoved: (val) => {
                    if (modelData.audio)
                      modelData.audio.volume = val / 100
                  }
                }
              }
            }
          }
        }
      }
    }

    Rectangle {
      Layout.preferredWidth: root.columnWidth
      Layout.fillHeight: true
      color: "transparent"
      border.color: Global.colors.outline
      border.width: 1

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Global.format.spacing_small
        spacing: Global.format.spacing_small

        StyledText {
          text: "Outputs"
          font.bold: true
          color: Global.colors.primary
        }

        ListView {
          id: outputList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: Global.format.spacing_tiny

          model: {
            const sinks = []
            for (const val in Pipewire.nodes.values) {
              const node = Pipewire.nodes.values[val]
              if (node.isSink && !node.isStream)
                sinks.push(node)
            }
            return sinks
          }

          StyledText {
            anchors.centerIn: parent
            text: "No outputs detected"
            color: Global.colors.outline
            visible: outputList.count <= 0
          }

          delegate: Item {
            required property var modelData
            width: outputList.width
            height: Global.format.module_height + Global.format.spacing_small

            property bool isDefault: Pipewire.defaultAudioSink?.id === modelData.id

            MouseArea {
              id: outputMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Pipewire.preferredDefaultAudioSink = modelData
              propagateComposedEvents: true

              RowLayout {
                anchors.fill: parent
                spacing: Global.format.spacing_small

                StyledText {
                  Layout.preferredWidth: parent.width * 0.4
                  text: "󰓃  " + (modelData.nickname || modelData.name || "Unnamed")
                  color: outputMouseArea.containsMouse
                    ? Global.colors.on_surface
                    : isDefault
                      ? Global.colors.primary
                      : Global.colors.on_surface_variant
                  elide: Text.ElideRight
                }

                StyledSlider {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  visible: modelData.ready
                  from: 0
                  to: 100
                  value: modelData.audio ? modelData.audio.volume * 100 : 0
                  onMoved: (val) => {
                    if (modelData.audio)
                      modelData.audio.volume = val / 100
                  }
                }
              }

            }
          }
        }
      }
    }

    Rectangle {
      Layout.preferredWidth: root.columnWidth
      Layout.fillHeight: true
      color: "transparent"
      border.color: Global.colors.outline
      border.width: 1

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Global.format.spacing_small
        spacing: Global.format.spacing_small

        StyledText {
          text: "Sources"
          font.bold: true
          color: Global.colors.primary
        }

        ListView {
          id: sourceList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: Global.format.spacing_tiny

          model: {
            const sources = []
            for (const val in Pipewire.nodes.values) {
              const node = Pipewire.nodes.values[val]
              if (node.isStream && node.isSink && node.audio)
                sources.push(node)
            }
            return sources
          }

          StyledText {
            anchors.centerIn: parent
            text: "No programs currently\nplaying audio"
            color: Global.colors.outline
            visible: sourceList.count <= 0
            horizontalAlignment: Text.AlignHCenter
          }

          delegate: Item {
            required property var modelData
            width: sourceList.width
            height: Global.format.module_height + Global.format.spacing_small

            PwObjectTracker { objects: [modelData] }

            RowLayout {
              anchors.fill: parent
              spacing: Global.format.spacing_small

              StyledText {
                Layout.preferredWidth: parent.width * 0.4
                text: "󰕾  " + (modelData.nickname || modelData.name || "Unnamed")
                elide: Text.ElideRight
              }

              StyledSlider {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                visible: modelData.ready
                from: 0
                to: 100
                value: modelData.audio ? modelData.audio.volume * 100 : 0
                onMoved: (val) => {
                  if (modelData.audio)
                    modelData.audio.volume = val / 100
                }
              }
            }
          }
        }
      }
    }
  }
}
