import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.I3
import qs
import qs.components.widget
import qs.components.text
import qs.panel.systray
import qs.panel.pager
import qs.panel.audio
import qs.panel.bluetooth
import qs.panel.network
import qs.panel.battery
import qs.panel.clock
import qs.panel.launcher
import qs.panel.clipboard
import qs.panel.wallpaper

PanelWindow {
  id: panel
  anchors {
    left: true
    right: true
    top: Global.config.panel.top
    bottom: !Global.config.panel.top
  }

  implicitHeight: content.height + (barMenu.visible ? barMenu.implicitHeight : 0)
  exclusiveZone: height
  color: Global.colors.background
  aboveWindows: true

  property Item activeBarContent: statusContent

  function openBarMenu(barContent: Item) {
    if (!(screen.name == I3.focusedMonitor.name)) return
    activeBarContent.visible = false
    activeBarContent = barContent
    barContent.visible = true
    content.forceActiveFocus()
    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
  }

  function openBarContent(barContent: Item) {
    if (!(screen.name == I3.focusedMonitor.name)) return
    barMenu.showContent(barContent)
    content.forceActiveFocus()
    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
  }

  function closeBarMenu() {
    activeBarContent.visible = false
    activeBarContent = statusContent
    statusContent.visible = true
    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
  }

  function openWallpapers() {
    openBarMenu(wallpaperSearchContent)
    wallpaperSearchInput.text = ""
    wallpaperSearchInput.forceActiveFocus()
    wallpaperContent.open()
    barMenu.showContent(wallpaperContent)
  }

  function closeWallpapers() {
    barMenu.hideContent()
    wallpaperContent.close()
    closeBarMenu()
  }

  function openClipboard() {
    openBarMenu(clipboardContent)
    clipboardContent.open()
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
                  if (!(screen.name == I3.focusedMonitor.name)) return
                  if (barMenu.isSameMenu(items)) {
                    barMenu.hideContent()
                    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
                  } else {
                    barMenu.showMenu(items)
                    content.forceActiveFocus()
                    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
                  }
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
                onAudioMenuTriggered: openBarContent(audioContent)
              }
              Battery {
                Layout.alignment: Qt.AlignVCenter
              }
              Bluetooth {
                Layout.alignment: Qt.AlignVCenter
                onBluetoothMenuTriggered: openBarContent(btContent)
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
        onCommandTriggered: (name) => {
          if (name === "Wallpapers")
            openWallpapers()
          else if (name === "Clip")
            openClipboard()
        }
      }

      Clipboard {
        id: clipboardContent
        anchors.fill: parent
        visible: false
        onClosed: panel.closeBarMenu()
      }

      Item {
        id: wallpaperSearchContent
        anchors.fill: parent
        visible: false

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: Global.format.spacing_medium
          anchors.rightMargin: Global.format.spacing_medium

          TextInput {
            id: wallpaperSearchInput
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Global.colors.on_surface_variant
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            verticalAlignment: Text.AlignVCenter
            clip: true
            focus: true
            onTextChanged: wallpaperContent.searchText = text
            Keys.onLeftPressed: wallpaperContent.movePrev()
            Keys.onRightPressed: wallpaperContent.moveNext()
            Keys.onReturnPressed: wallpaperContent.selectCurrent()
            Keys.onEscapePressed: closeWallpapers()
            Keys.onPressed: (event) => {
              if (event.modifiers & Qt.ControlModifier) {
                if (event.key === Qt.Key_F) {
                  wallpaperContent.toggleFavoriteCurrent()
                  event.accepted = true
                } else if (event.key === Qt.Key_R) {
                  wallpaperContent.reload()
                  event.accepted = true
                }
              }
            }
          }
        }
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
        function onOpenClipboard() {
          panel.openClipboard()
        }
      }

      AudioControl {
        id: audioContent
        anchors.fill: parent
        anchors.margins: Global.format.spacing_large
        visible: false
      }

      BluetoothControl {
        id: btContent
        anchors.fill: parent
        anchors.margins: Global.format.spacing_large
        visible: false
      }

      NetworkControl {
        id: netContent
        anchors.fill: parent
        anchors.margins: Global.format.spacing_large
        visible: false
      }

      WallpaperPicker {
        id: wallpaperContent
        anchors.fill: parent
        anchors.margins: Global.format.spacing_large
        visible: false
      }
    }
  }
}
