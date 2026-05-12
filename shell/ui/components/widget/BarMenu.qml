import QtQuick
import Quickshell
import qs

DropdownWindow {
  id: root

  enum Edge { Left, Center, Right }
  property int edge: BarMenu.Left

  topLeftRadius: 0
  topRightRadius: 0
  bottomLeftRadius: edge === BarMenu.Left ? 0 : radius
  bottomRightRadius: edge === BarMenu.Right ? 0 : radius

  x: edge === BarMenu.Left
    ? 0
    : edge === BarMenu.Right
      ? window.width - width
      : (window.width - width) / 2

  signal itemTriggered

  Menu {
    id: builtinMenu
    model: []
    onItemTriggered: {
      root.itemTriggered()
      root.visible = false
    }
  }

  property Item _activeContent: builtinMenu
  contentItem: _activeContent

  function showMenu(model) {
    builtinMenu.model = model
    builtinMenu.visible = true
    if (_activeContent !== builtinMenu)
      _activeContent.visible = false
    _activeContent = builtinMenu
    visible = true
  }

  function showContent(item) {
    if (_activeContent === builtinMenu)
      builtinMenu.visible = false
    _activeContent = item
    item.visible = true
    visible = true
  }
}
