import QtQuick
import Quickshell
import qs

DropdownWindow {
  id: root

  enum Edge { Left, Center, Right }
  property int edge: BarMenu.Left
  property int round: 0
  property int leftRound: round
  property int rightRound: round

  topLeftRadius: 0
  topRightRadius: 0
  bottomLeftRadius: edge === BarMenu.Left ? 0 : radius
  bottomRightRadius: edge === BarMenu.Right ? 0 : radius

  readonly property bool _leftSpacerActive: leftRound > 0
    && (edge === BarMenu.Right || edge === BarMenu.Center)
  readonly property bool _rightSpacerActive: rightRound > 0
    && (edge === BarMenu.Left || edge === BarMenu.Center)

  leftOffset: _leftSpacerActive ? leftRound : 0
  rightOffset: _rightSpacerActive ? rightRound : 0
  showLeftCorner: _leftSpacerActive
  showRightCorner: _rightSpacerActive

  x: {
    const contentW = implicitWidth - leftOffset - rightOffset
    const contentX = edge === BarMenu.Left
      ? 0
      : edge === BarMenu.Right
        ? window.width - contentW
        : (window.width - contentW) / 2
    return contentX - leftOffset
  }

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
    root.hideTimer.restart()
    builtinMenu.visible = true
    if (_activeContent !== builtinMenu)
      _activeContent.visible = false
    _activeContent = builtinMenu
    visible = true
  }

  function showContent(item) {
    root.hideTimer.restart()
    if (_activeContent === builtinMenu)
      builtinMenu.visible = false
    else if (_activeContent !== item)
      _activeContent.visible = false
    _activeContent = item
    item.visible = true
    visible = true
  }
}
