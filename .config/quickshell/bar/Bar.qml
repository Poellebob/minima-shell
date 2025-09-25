import QtQuick
import QtQuick.Layouts
import Quickshell

Instantiator {
  model: Quickshell.screens

  delegate: Panel {
    screen: modelData
  }
}