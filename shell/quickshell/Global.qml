pragma Singleton
import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import qs.colors
import qs.format
import qs.config

Singleton {
  readonly property Colors colors: config.theme.darkTheme ? colorsRaw.dark : colorsRaw.light
  readonly property Format format: Format {}

  readonly property bool panelAlwaysVisible: config.panel.panelAlwaysVisible
  
  property var launcher: null
  property var clipboardManager: null
  property var wallpaperSelector: null

  readonly property string matugenConfigPath: Quickshell.env("MATUGEN_CONFIG") || (Quickshell.env("HOME") + "/.config/minima/matugen/config.toml")

  ConfigAdapter {
    id: configAdapter
  }

  property ColorsAdapter colorsRaw: ColorsAdapter {}

  property bool darkTheme: configAdapter.config.theme.darkTheme
  
  readonly property var config: configAdapter.config
}
