import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs
import qs.components.widget
import qs.components.text
import qs.panel.systray
import qs.panel.pager
import qs.panel.audio
import qs.panel.bluetooth
import qs.panel.network
import qs.panel.clock
import qs.panel.launcher

PanelWindow {
  id: panel
  anchors {
    left: true
    right: true
    top: Global.config.panel.top
    bottom: !Global.config.panel.top
  }

  height: content.height + (barMenu.visible ? barMenu.implicitHeight : 0)
  exclusiveZone: height
  color: Global.colors.background
  aboveWindows: true

  property Item activeBarContent: statusContent

  function openBarMenu(barContent: Item) {
    activeBarContent.visible = false
    activeBarContent = barContent
    barContent.visible = true
    content.forceActiveFocus()
    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
  }

  function closeBarMenu() {
    activeBarContent.visible = false
    activeBarContent = statusContent
    statusContent.visible = true
    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
  }

  Item {
    id: content
    anchors {
      left: parent.left
      right: parent.right
      top: Global.config.panel.top ? parent.top : undefined
      bottom: Global.config.panel.top ? undefined : parent.bottom
    }
    height: barRow.height
    focus: true
    Keys.onEscapePressed: (event) => {
      if (barMenu.visible) {
        barMenu.hideContent()
        panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
      } else if (activeBarContent !== statusContent) {
        closeBarMenu()
      } else {
        event.accepted = false
      }
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
                id: systray
                Layout.alignment: Qt.AlignVCenter
                onShowMenu: (items) => {
                  barMenu.showMenu(items)
                  content.forceActiveFocus()
                  panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                }
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
                onAudioMenuTriggered: {
                  barMenu.showContent(audioContent)
                  content.forceActiveFocus()
                  panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                }
              }
              Bluetooth {
                Layout.alignment: Qt.AlignVCenter
                onBluetoothMenuTriggered: {
                  barMenu.showContent(btContent)
                  content.forceActiveFocus()
                  panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                }
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

      Launcher {
        id: launcherContent
        anchors.fill: parent
        visible: false
        onClosed: panel.closeBarMenu()
      }
    }

    BarMenu {
      id: barMenu
      anchors {
        left: parent.left
        right: parent.right
        top: Global.config.panel.top ? barRow.bottom : undefined
        bottom: Global.config.panel.top ? undefined : barRow.top
      }

      onItemTriggered: panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None

      Connections {
        target: Global
        function onOpenSystrayMenu(index: int) {
          systray.triggerItem(index)
        }
        function onOpenLauncher() {
          panel.openBarMenu(launcherContent)
          launcherContent.open()
        }
      }

      AudioControl {
        id: audioContent
        visible: false
      }

      BluetoothControl {
        id: btContent
        visible: false
      }

      NetworkControl {
        id: netContent
        visible: false
      }
    }
  }
}
