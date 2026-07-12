pragma Singleton
import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import qs.colors
import qs.format
import qs.settings

Singleton {
  readonly property Colors colors: settings.Theme.darkTheme ? colorsRaw.dark : colorsRaw.light
  readonly property Format format: Format {}

  readonly property bool panelAlwaysVisible: settings.Panel.panelAlwaysVisible

  property var launcher: null
  property var clipboardManager: null
  property var wallpaperSelector: null

  readonly property string matugenConfigPath: settings.System.matugenConfigPath

  property ColorsAdapter colorsRaw: ColorsAdapter {}
  property ConfigAdapter configAdapter: ConfigAdapter {}

  readonly property var settings: configAdapter.settings

  property bool darkTheme: settings.Theme.darkTheme
}
