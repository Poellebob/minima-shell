pragma Singleton
import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import qs.colors
import qs.format
import qs.config

Singleton {
  readonly property Format format: Format {}

  readonly property Colors colors: darkTheme ? colorsRaw.dark : colorsRaw.light

  ConfigAdapter {
    id: configAdapter
  }

  property ColorsAdapter colorsRaw: ColorsAdapter {}

  property bool darkTheme: configAdapter.config.theme.darkTheme

  readonly property var config: configAdapter.config

  signal openSystrayMenu(index: int)
  signal openLauncher()
  signal openClipboard()
}
