import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs
import qs.bar

PanelWindow {
  id: statusBar

  property int activeModuleIndex: -1
  property bool expanded: false

  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "minima-bar"

  anchors {
    top: Global.settings.Interface.position === "top"
    bottom: Global.settings.Interface.position !== "top"
    left: true
    right: true
  }

  implicitHeight: Global.format.panel_height + (expanded ? expandedContainer.implicitHeight : 0)

  color: "transparent"

  Behavior on implicitHeight {
    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
  }

  Rectangle {
    id: barBackground
    anchors.fill: parent
    color: Global.colors.surface
    radius: Global.format.radius_medium

    ColumnLayout {
      anchors.fill: parent
      spacing: 0

      ModuleRow {
        id: moduleRow
        Layout.fillWidth: true
        Layout.preferredHeight: Global.format.panel_height
        Layout.margins: Global.format.spacing_small

        onModuleActivated: (index) => {
          if (statusBar.activeModuleIndex === index && statusBar.expanded) {
            statusBar.collapse()
          } else {
            statusBar.expand(index)
          }
        }

        onModuleFocused: (index) => {
          statusBar.activeModuleIndex = index
        }
      }

      ExpandedPanel {
        id: expandedContainer
        Layout.fillWidth: true
        Layout.preferredHeight: expanded ? implicitHeight : 0
        Layout.margins: Global.format.spacing_small
        Layout.topMargin: 0
        visible: expanded

        Loader {
          id: expandedLoader
          anchors.fill: parent
          source: statusBar.expanded ? statusBar.moduleExpandedUrl(statusBar.activeModuleIndex) : ""
        }
      }
    }
  }

  function expand(index) {
    activeModuleIndex = index
    expanded = true
    moduleRow.setFocused(index)
  }

  function collapse() {
    expanded = false
    activeModuleIndex = -1
    moduleRow.clearFocus()
  }

  function moduleExpandedUrl(index) {
    if (index < 0 || index >= moduleRow.moduleCount) return ""
    var name = moduleRow.moduleName(index)
    return Qt.resolvedUrl("../expanded/" + name + "Expanded.qml")
  }

  focus: true
  Keys.enabled: true
  Keys.onPressed: (event) => handleKeyPress(event)

  function handleKeyPress(event) {
    switch (event.key) {
    case Qt.Key_Tab:
      if (expanded) {
        // Navigate within expanded content
        return
      }
      moduleRow.focusNext()
      event.accepted = true
      break
    case Qt.Key_Backtab:
      if (expanded) return
      moduleRow.focusPrev()
      event.accepted = true
      break
    case Qt.Key_Return:
    case Qt.Key_Enter:
      if (activeModuleIndex >= 0) {
        if (expanded) {
          // Activate item within expanded content
          expandedLoader.item?.activate()
        } else {
          expand(activeModuleIndex)
        }
      }
      event.accepted = true
      break
    case Qt.Key_Escape:
      if (expanded) {
        collapse()
        event.accepted = true
      }
      break
    case Qt.Key_j:
    case Qt.Key_Down:
      if (expanded) {
        expandedLoader.item?.navigateDown()
        event.accepted = true
      } else {
        moduleRow.focusNext()
        event.accepted = true
      }
      break
    case Qt.Key_k:
    case Qt.Key_Up:
      if (expanded) {
        expandedLoader.item?.navigateUp()
        event.accepted = true
      } else {
        moduleRow.focusPrev()
        event.accepted = true
      }
      break
    case Qt.Key_h:
    case Qt.Key_Left:
      if (expanded) {
        collapse()
        event.accepted = true
      }
      break
    case Qt.Key_l:
    case Qt.Key_Right:
      if (!expanded && activeModuleIndex >= 0) {
        expand(activeModuleIndex)
        event.accepted = true
      }
      break
    case Qt.Key_1:
    case Qt.Key_2:
    case Qt.Key_3:
    case Qt.Key_4:
    case Qt.Key_5:
    case Qt.Key_6:
    case Qt.Key_7:
    case Qt.Key_8:
    case Qt.Key_9:
      var idx = event.key - Qt.Key_1
      if (idx < moduleRow.moduleCount) {
        moduleRow.setFocused(idx)
        activeModuleIndex = idx
      }
      event.accepted = true
      break
    }
  }
}
