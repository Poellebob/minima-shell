import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.colors

Instantiator {
  model: Quickshell.screens
  required property bool isDarkTheme

  delegate: Panel {
    required property ShellScreen modelData
    readonly property Colors darkTheme: ColorsDark {}
    readonly property Colors lightTheme: ColorsLight {}

    screen: modelData
    colors: isDarkTheme ? darkTheme : lightTheme
  }
}
