import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

Item {
  id: root

  property real padding: Global.format.spacing_large
  property Item _activeContent: null
  signal itemTriggered

  implicitHeight: _activeContent ? _activeContent.implicitHeight + padding * 2 : 0
  visible: _activeContent !== null

  function showMenu(model) {
    hideContent()
    builtinMenu.model = model
    _activeContent = builtinMenu
    visible = true
  }

  function showContent(item) {
    if (_activeContent === builtinMenu) {
      builtinMenu.model = []
    } else if (_activeContent !== null && _activeContent !== item) {
      _activeContent.visible = false
    }
    _activeContent = item
    item.visible = true
    visible = true
  }

  function hideContent() {
    if (_activeContent === builtinMenu) {
      builtinMenu.model = []
    } else if (_activeContent !== null) {
      _activeContent.visible = false
    }
    _activeContent = null
    visible = false
  }

  MenuContent {
    id: builtinMenu
    x: root.padding
    y: root.padding
    width: parent.width - root.padding * 2
    model: []
    visible: false
    onItemTriggered: {
      root.itemTriggered()
      root.hideContent()
    }
  }
}
