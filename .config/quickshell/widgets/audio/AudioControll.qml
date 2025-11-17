import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.components.widget
import qs

DropdownWindow {
  id: menuRoot
  implicitWidth: 450
  implicitHeight: 300
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
            id: audioList
            anchors.fill: parent
            anchors.margins: Global.format.spacing_small
            spacing: Global.format.spacing_tiny
            clip: true
            focus: false

            populate: Transition {
              NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
            }

            model: {
              return Pipewire.nodes.filter(n => n.isSink)
            }

            delegate: Rectangle {
              id: audioItem
              required property var modelData
              property bool selected: audioList.currentItem?.modelData === modelData

              width: audioList.width - scrollBar.width
              height: Global.format.module_height + Global.format.spacing_medium
              radius: Global.format.radius_medium

              color: mouseArea.containsMouse || audioList.currentItem?.modelData === modelData ? Global.colors.surface_container_high : "transparent"

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
                    text: modelData.nickname || "Unnamed Node"
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
              }
            }

            ScrollBar.vertical: ScrollBar {
              id: scrollBar
              policy: ScrollBar.AsNeeded
            }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          color: Global.colors.surface_variant
          radius: Global.format.radius_large

          ListView {
            id: audioList2
            anchors.fill: parent
            anchors.margins: Global.format.spacing_small
            spacing: Global.format.spacing_tiny
            clip: true
            focus: false

            populate: Transition {
              NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
            }

            model: Pipewire.nodes

            delegate: Rectangle {
              id: audioItem2
              required property var modelData
              property bool selected: audioList2.currentItem?.modelData === modelData

              width: audioList2.width - scrollBar2.width
              height: Global.format.module_height + Global.format.spacing_medium
              radius: Global.format.radius_medium

              color: mouseArea2.containsMouse || audioList2.currentItem?.modelData === modelData ? Global.colors.surface_container_high : "transparent"

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
                    text: modelData.nickname|| "Unnamed Node"
                    color: Global.colors.on_surface_variant
                    font.pixelSize: Global.format.text_size
                    font.bold: true
                    elide: Text.ElideRight
                  }
                }
              }

              MouseArea {
                id: mouseArea2
                anchors.fill: parent
                hoverEnabled: true
              }
            }

            ScrollBar.vertical: ScrollBar {
              id: scrollBar2
               policy: ScrollBar.AsNeeded
            }
          }
        }
      }
    }
  }
}
