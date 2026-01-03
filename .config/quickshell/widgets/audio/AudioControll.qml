import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models
import qs.components.widget
import qs

DropdownWindow {
  id: menuRoot
  implicitWidth: 550
  implicitHeight: 200
  color: "transparent" 
  
  Rectangle {
    anchors.margins: Global.format.spacing_large
    anchors.topMargin: Global.format.spacing_medium
    anchors.fill: parent
    radius: Global.format.radius_large
    color: Global.colors.inverse_on_surface
    
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Global.format.spacing_large
      spacing: Global.format.spacing_medium
      
      Tabbar {
        id: tabs
        model: [
          {text: "Devices"},
          {text: "Sourses"}
        ]
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Global.format.spacing_medium

        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          color: Global.colors.surface_variant
          radius: Global.format.radius_large

          ListView {
            id: inputList
            anchors.fill: parent
            anchors.margins: Global.format.spacing_small
            spacing: Global.format.spacing_tiny
            clip: true
            focus: false

            populate: Transition {
              NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
            }

            model: {
              const sources = []
              for (const val in Pipewire.nodes.values) {
                const node = Pipewire.nodes.values[val]
                if (tabs.index == 0 && (!node.isSink && !node.isStream && node.audio) ||
                    tabs.index == 1 && (node.isStream && node.isSink && node.audio)) {
                  sources.push(node)
                }
              }
              return sources
            }

            delegate: Rectangle {
              id: inputItem
              required property var modelData
              property bool selected: inputList.currentItem?.modelData.id === modelData.id
              width: inputList.width - scrollBar2.width
              height: Global.format.module_height + Global.format.spacing_medium
              radius: Global.format.radius_medium
              color: tabs.index == 0 ? 
                     (mouseArea.containsMouse || Pipewire.defaultAudioSource.id == modelData.id ? Global.colors.surface_container_high : "transparent") :
                     Global.colors.surface_container_low
              
              Behavior on color {
                ColorAnimation {
                  duration: 150
                  easing.type: Easing.OutCubic
                }
              }
              
              PwObjectTracker {
                id: nodeTracker
                objects: [modelData]
              }

              RowLayout {
                anchors.fill: parent
                anchors.margins: Global.format.spacing_small
                spacing: Global.format.spacing_medium
                  
                Text {
                  text: (tabs.index == 1 ? "   " : "  ") + (modelData.nickname || modelData.name || "Unnamed Node")
                  color: Global.colors.on_surface_variant
                  font.pixelSize: Global.format.text_size
                  font.bold: true
                  elide: Text.ElideRight
                }
                
                Slider {
                  id: volumeSlider
                  Layout.fillWidth: true
                  visible: tabs.index == 1 && modelData.audio

                  from: 0
                  to: 100
                  value: modelData.audio.volume * 100

                  onValueChanged: {
                    if (modelData.audio)
                      modelData.audio.volume = value / 100
                  }

                  
                  background: Item {
                    implicitWidth: 200
                    implicitHeight: 24   // ← clickable height

                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding
                    width: volumeSlider.availableWidth
                    height: implicitHeight

                    MouseArea {
                      anchors.fill: parent
                      onPressed: (mouse) => {
                        let pos = Math.max(0, Math.min(1, mouse.x / width))
                        volumeSlider.value =
                          volumeSlider.from + pos * (volumeSlider.to - volumeSlider.from)
                      }
                    }

                    Rectangle {
                      anchors.verticalCenter: parent.verticalCenter
                      width: parent.width
                      height: 4
                      radius: 2
                      color: Global.colors.surface_container_highest

                      Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: Global.colors.primary
                      }
                    }
                  }


                  handle: Rectangle {
                    implicitWidth: 16
                    implicitHeight: 16

                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2

                    radius: 8
                    color: Global.colors.secondary
                  }
                }
              }

              MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: tabs.index == 0
                onClicked: {
                  if (tabs.index == 0) Pipewire.preferredDefaultAudioSource = modelData
                }
                propagateComposedEvents: true
              }
            }

            ScrollBar.vertical: ScrollBar {
              id: scrollBar2
              policy: ScrollBar.AsNeeded
            }
          }
        }

        Rectangle {
          Layout.preferredWidth: tabs.index == 0 ? 
                                 parent.width / 2 - Global.format.spacing_medium / 2 : 
                                 0
          Layout.fillHeight: true
          color: Global.colors.surface_variant
          radius: Global.format.radius_large

          visible: Layout.preferredWidth != 0

          Behavior on Layout.preferredWidth {
            NumberAnimation {
              duration: 150
              easing.type: Easing.OutCubic
            }
          }

          ListView {
            id: outputList
            anchors.fill: parent
            anchors.margins: Global.format.spacing_small
            spacing: Global.format.spacing_tiny
            clip: true
            focus: false
            visible: tabs.index == 0
            populate: Transition {
              NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
            }
            model: {
              const sinks = []
              for (const val in Pipewire.nodes.values) {
                const node = Pipewire.nodes.values[val]
                if (node.isSink && !node.isStream) {
                  sinks.push(node)
                }
              }
              return sinks
            }

            delegate: Rectangle {
              id: outputItem
              required property var modelData
              property bool selected: outputList.currentItem?.modelData.id === modelData.id
              width: outputList.width - scrollBar.width
              height: Global.format.module_height + Global.format.spacing_medium
              radius: Global.format.radius_medium
              color: mouseArea.containsMouse || Pipewire.defaultAudioSink.id == modelData.id ? Global.colors.surface_container_high : "transparent"
              Behavior on color {
                ColorAnimation {
                  duration: 150
                  easing.type: Easing.OutCubic
                }
              }
              RowLayout {
                anchors.fill: parent
                anchors.margins: Global.format.spacing_small
                spacing: Global.format.spacing_medium
                ColumnLayout {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  spacing: 0
                  Text {
                    Layout.fillWidth: true
                    text: "  " + (modelData.nickname || modelData.name || "Unnamed Node")
                    color: Global.colors.on_surface_variant
                    font.pixelSize: Global.format.text_size
                    font.bold: true
                    elide: Text.ElideRight
                  }
                }
              }
              MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Pipewire.preferredDefaultAudioSink = modelData
              }
            }
            ScrollBar.vertical: ScrollBar {
              id: scrollBar
              policy: ScrollBar.AsNeeded
            }
          }
        }
      }
    }
  } 
}
