import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Instantiator {
  model: Quickshell.screens

  delegate: Panel {
    screen: modelData
  }
}
