import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.format
import qs.colors

PanelWindow {
  id: panel

  readonly property Format format: Format {}
  readonly property Colors colors: Colors {}

  implicitHeight: format.panel_hight
  aboveWindows: true

  anchors {
    top: true
    left: true
    right: true
  }
  
  Rectangle {
    anchors.fill: parent
    color: panel.colors.dark_background

    Rectangle {
      id: leftMenu
      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
      }

      implicitWidth: format.panel_hight + 2
      color: panel.colors.dark_surface_variant

      bottomRightRadius: panel.format.radius_large
      //topRightRadius: panel.format.radius_large

      Text {
        text: "󰣇  "
        color: panel.colors.dark_on_background
        font.pixelSize: panel.format.icon_size
        anchors.centerIn: parent
      }
    }


    RowLayout {
      anchors {
        left: leftMenu.right
        leftMargin: panel.format.spacing_medium
        verticalCenter: parent.verticalCenter
      }
      spacing: panel.format.spacing_medium


      Systray {
        Layout.alignment: Qt.AlignVCenter
      }
    }

    RowLayout {
      anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
      }
      spacing: panel.format.spacing_medium

      Audio {
        Layout.alignment: Qt.AlignCenter
      }

      Battery {
        Layout.alignment: Qt.AlignVCenter
      }

      Bluetooth {
        Layout.alignment: Qt.AlignVCenter
      }

      Network {
        Layout.alignment: Qt.AlignVCenter
      }

      Clock {
        Layout.alignment: Qt.AlignVCenter
      }

      MouseArea {
        onClicked: (event) => {
          if (event.button == Qt.LeftButton) {
            centerMenu.visible = !centerMenu.visible
          }
        }
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: panel.height
      }
    }

    RowLayout {
      anchors {
        right: parent.right
        rightMargin: panel.format.spacing_medium
        verticalCenter: parent.verticalCenter
      }
      spacing: panel.format.spacing_medium

      Pager {
        Layout.alignment: Qt.AlignVCenter
      }
    }
  }

  CenterMenu {
    id: centerMenu
  }
}
