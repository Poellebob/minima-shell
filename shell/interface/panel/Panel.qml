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
import qs.panel.battery
import qs.panel.clock
import qs.panel.calendar
import qs.panel.launcher
import qs.panel.clipboard
import qs.panel.wallpaper
import qs.panel.notification

PanelWindow {
  id: panel

  property Item activeBarContent: statusContent

  function closeAudioMedia() {
    barMenu.hideContent();
    closeBarMenu();
  }
  function closeBarMenu() {
    activeBarContent.visible = false;
    activeBarContent = statusContent;
    statusContent.visible = true;
    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
  }
  function closeWallpapers() {
    barMenu.hideContent();
    wallpaperContent.close();
    closeBarMenu();
  }
  function isFocusedScreen(): bool {
    return Wm.isFocused(screen.name);
  }
  function openAudioMedia() {
    openBarMenu(mediaContent);
    mediaContent.open();
    barMenu.showContent(audioContent);
  }
  function openBarContent(barContent: Item) {
    if (!panel.isFocusedScreen())
      return;
    barMenu.showContent(barContent);
    if (barMenu.visible) {
      content.forceActiveFocus();
      panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
    } else {
      panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
    }
  }
  function openBarMenu(barContent: Item) {
    if (!panel.isFocusedScreen())
      return;
    activeBarContent.visible = false;
    activeBarContent = barContent;
    barContent.visible = true;
    content.forceActiveFocus();
    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
  }
  function openClipboard() {
    openBarMenu(clipboardContent);
    clipboardContent.open();
  }
  function openWallpapers() {
    openBarMenu(wallpaperSearchContent);
    wallpaperSearchInput.text = "";
    wallpaperSearchInput.forceActiveFocus();
    wallpaperContent.open();
    barMenu.showContent(wallpaperContent);
  }

  aboveWindows: true
  color: Global.colors.background
  exclusiveZone: Global.format.panel_height
  implicitHeight: content.height + (barMenu.visible ? barMenu.implicitHeight : 0)

  anchors {
    bottom: true
    left: true
    right: true
    top: false
  }

  Item {
    id: content

    focus: true
    height: barRow.height

    Keys.onEscapePressed: event => {
      if (activeBarContent === mediaContent && barMenu.visible) {
        closeAudioMedia();
      } else if (barMenu.visible) {
        barMenu.hideContent();
        panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
      } else if (activeBarContent !== statusContent) {
        closeBarMenu();
      } else {
        event.accepted = false;
      }
    }

    anchors {
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      top: undefined
    }

    MouseArea {
      acceptedButtons: Qt.NoButton
      anchors.fill: parent
      hoverEnabled: true
      propagateComposedEvents: true

      onContainsMouseChanged: {
        if (containsMouse && (barMenu.visible || activeBarContent !== statusContent) && activeBarContent
            !== wallpaperSearchContent) {
          content.forceActiveFocus();
          panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
        }
      }
    }

    Item {
      id: barRow

      height: Global.format.panel_height

      anchors {
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        top: undefined
      }

      Item {
        id: statusContent

        anchors.fill: parent

        RowLayout {
          anchors.fill: parent
          spacing: 0

          Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            RowLayout {
              anchors.left: parent.left
              anchors.leftMargin: Global.format.spacing_tiny
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: Global.format.spacing_medium

              Systray {
                id: systray

                Layout.alignment: Qt.AlignVCenter

                onShowMenu: items => {
                  if (!panel.isFocusedScreen())
                    return;
                  if (barMenu.isSameMenu(items)) {
                    barMenu.hideContent();
                    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
                  } else {
                    barMenu.showMenu(items);
                    content.forceActiveFocus();
                    panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
                  }
                }
              }
            }
          }

          Item {
            Layout.fillHeight: true
            Layout.preferredWidth: midrow.width

            RowLayout {
              id: midrow

              anchors.centerIn: parent
              spacing: Global.format.spacing_medium

              Pager {
                Layout.alignment: Qt.AlignVCenter
                screen: panel.screen
              }
            }
          }

          Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            RowLayout {
              anchors.right: parent.right
              anchors.rightMargin: Global.format.spacing_medium
              anchors.verticalCenter: parent.verticalCenter
              spacing: 0

              Audio {
                Layout.alignment: Qt.AlignVCenter

                onAudioMenuTriggered: openAudioMedia()
              }

              Battery {
                Layout.alignment: Qt.AlignVCenter
              }

              Bluetooth {
                Layout.alignment: Qt.AlignVCenter

                onBluetoothMenuTriggered: openBarContent(bluetoothContent)
              }

              Network {
                Layout.alignment: Qt.AlignVCenter

                onNetworkMenuTriggered: openBarContent(netContent)
              }

              Clock {
                Layout.alignment: Qt.AlignVCenter

                onCalendarMenuTriggered: openBarContent(calendarContent)
              }

              Notification {
                id: notifWidget

                Layout.alignment: Qt.AlignVCenter

                onNotificationMenuTriggered: openBarContent(notifContent)
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
        onOpenClipboard: panel.openClipboard()
      }

      Clipboard {
        id: clipboardContent

        anchors.fill: parent
        visible: false

        onClosed: panel.closeBarMenu()
      }

      Media {
        id: mediaContent

        anchors.fill: parent
        visible: false

        onClosed: panel.closeAudioMedia()
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

            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            color: Global.colors.on_surface_variant
            focus: true
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Global.format.text_size
            verticalAlignment: Text.AlignVCenter

            Keys.onEscapePressed: closeWallpapers()
            Keys.onLeftPressed: wallpaperContent.movePrev()
            Keys.onPressed: event => {
              if (event.modifiers & Qt.ControlModifier) {
                if (event.key === Qt.Key_F) {
                  wallpaperContent.toggleFavoriteCurrent();
                  event.accepted = true;
                } else if (event.key === Qt.Key_R) {
                  wallpaperContent.reload();
                  event.accepted = true;
                }
              }
            }
            Keys.onReturnPressed: wallpaperContent.selectCurrent()
            Keys.onRightPressed: wallpaperContent.moveNext()
            onTextChanged: wallpaperContent.searchText = text
          }
        }
      }
    }

    BarMenu {
      id: barMenu

      onItemTriggered: panel.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None

      anchors {
        bottom: barRow.top
        left: parent.left
        right: parent.right
        top: undefined
      }

      Connections {
        function onOpenClipboard() {
          panel.openClipboard();
        }
        function onOpenLauncher() {
          panel.openBarMenu(launcherContent);
          launcherContent.open();
        }
        function onOpenLockScreen() {
          panel.closeBarMenu();
          barMenu.hideContent();
        }
        function onOpenLogoutMenu() {
          panel.closeBarMenu();
          barMenu.hideContent();
        }
        function onOpenNotifications() {
          panel.openBarContent(notifContent);
        }
        function onOpenSystrayMenu(index: int) {
          systray.triggerItem(index);
        }

        target: Global
      }

      AudioControl {
        id: audioContent

        activePlayer: mediaContent.player
        anchors.fill: parent
        anchors.margins: Global.format.spacing_large
        visible: false

        onPlayerSelected: p => mediaContent.player = p
      }

      NotificationControl {
        id: notifContent

        anchors.fill: parent
        anchors.margins: Global.format.spacing_large
        notifServer: notifWidget.notifServer
        visible: false
      }

      CalendarControl {
        id: calendarContent

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

      BluetoothControl {
        id: bluetoothContent

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

  NotificationPopups {
    panel: panel
  }
}
