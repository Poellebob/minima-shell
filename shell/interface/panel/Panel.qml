import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components.widget
import qs.components.text
import qs.panel.systray
import qs.panel.pager
import qs.panel.audio
import qs.panel.bluetooth
import qs.panel.network
import qs.panel.clock

PanelWindow {
  id: panel
  anchors {
    left: true
    right: true
    top: Global.config.panel.top
    bottom: !Global.config.panel.top
  }

  height: barRow.height + (activeMenu ? activeMenu.implicitHeight : 0)
  exclusiveZone: Global.format.panel_height
  color: "transparent"
  aboveWindows: true

  property Item activeMenu: null
  property Item activeBarContent: statusContent

  function toggleMenu(menu: Item) {
    if (activeMenu === menu) {
      activeMenu = null
      menu.visible = false
    } else {
      if (activeMenu !== null)
        activeMenu.visible = false
      activeMenu = menu
      menu.visible = true
    }
  }

  function closeMenu() {
    if (activeMenu !== null) {
      activeMenu.visible = false
      activeMenu = null
    }
  }

  function switchBarContent(content: Item) {
    if (activeBarContent === content) return
    activeBarContent.visible = false
    activeBarContent = content
    content.visible = true
  }

  Item {
    id: barRow
    anchors {
      left: parent.left
      right: parent.right
      top: Global.config.panel.top ? parent.top : undefined
      bottom: Global.config.panel.top ? undefined : parent.bottom
    }
    height: Global.format.panel_height

    Item {
      id: statusContent
      anchors.fill: parent

      RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true

          RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: Global.format.spacing_medium
            anchors.verticalCenter: parent.verticalCenter
            spacing: Global.format.spacing_medium

            Systray {
              Layout.alignment: Qt.AlignVCenter
            }
          }
        }

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true

          RowLayout {
            anchors.centerIn: parent
            spacing: Global.format.spacing_medium

            Pager {
              Layout.alignment: Qt.AlignVCenter
              screen: panel.screen
            }
          }
        }

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true

          RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: Global.format.spacing_medium
            anchors.verticalCenter: parent.verticalCenter
            spacing: Global.format.spacing_medium

            Audio {
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
          }
        }
      }
    }

    Item {
      id: launcherContent
      anchors.fill: parent
      visible: false

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Global.format.spacing_medium
        anchors.rightMargin: Global.format.spacing_medium
        spacing: Global.format.spacing_medium

        StyledText {
          text: ">"
        }

        TextInput {
          Layout.fillWidth: true
          color: Global.colors.on_surface_variant
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: Global.format.text_size
          focus: visible
        }
      }
    }
  }

  MenuWidget {
    id: homeMenu
    visible: false
    anchors {
      left: parent.left
      right: parent.right
      top: Global.config.panel.top ? barRow.bottom : undefined
      bottom: Global.config.panel.top ? undefined : barRow.top
    }

    Item {
      width: parent.width
      height: 100
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    propagateComposedEvents: true
    onClicked: (mouse) => {
      panel.closeMenu()
      mouse.accepted = false
    }
  }
}
