import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

PopupWindow {
  id: menuRoot

  required property var window
  anchor.window: window
  required property real x
  anchor.rect.x: x
  anchor.rect.y: window.height
}
