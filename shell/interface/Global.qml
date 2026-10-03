pragma Singleton
import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.colors
import qs.format
import qs.config

Singleton {
  readonly property Format format: Format {}

  readonly property Colors colors: darkTheme ? colorsRaw.dark : colorsRaw.light

  readonly property NotificationServer notifServer: _notifServer

  ConfigAdapter {
    id: configAdapter
  }

  property ColorsAdapter colorsRaw: ColorsAdapter {}

  property bool darkTheme: configAdapter.config.theme.darkTheme

  readonly property var config: configAdapter.config

  NotificationServer {
    id: _notifServer

    actionsSupported: true
    bodySupported: true
    imageSupported: true
    keepOnReload: true

    onNotification: notif => notif.tracked = true
  }

  signal openSystrayMenu(index: int)
  signal openLauncher
  signal openClipboard
  signal openNotifications
  signal openLogoutMenu
  signal closeLogoutMenu
  signal openLockScreen
}
