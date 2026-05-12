import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.components.widget
import qs.widgets.centerMenu
import qs.widgets.audio
import qs

PanelWindow {
  id: panel
  aboveWindows: true
  focusable: true
  color: "transparent"
  property bool inside:
    leftMouseArea.containsMouse ||
    centerMouseArea.containsMouse ||
    rightMouseArea.containsMouse ||
    Global.panelAlwaysVisible

  implicitHeight: Global.panelAlwaysVisible
    ? Global.format.panel_height
    : (inside ? Global.format.panel_height : 1)

  exclusiveZone: Global.panelAlwaysVisible
    ? 3
    : 0

  exclusionMode: Global.panelAlwaysVisible
    ? ExclusionMode.Auto
    : ExclusionMode.None

  anchors {
    top: true
    left: true
    right: true
  }

  MouseArea {
    id: leftMouseArea
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    propagateComposedEvents: true
    preventStealing: true

    anchors {
      top: parent.top
      bottom: parent.bottom
      left: parent.left
    }

    implicitWidth: leftMenu.visible ? leftMenu.width : itemsLeft.width + Global.format.spacing_medium * 2

    Rectangle {
      id: leftRect
      anchors.fill: parent
      bottomRightRadius: leftMenu.visible ? 0 : Global.format.radius_medium
      color: Global.colors.surface
      visible: systray.visible && (parent.containsMouse || Global.panelAlwaysVisible)

      RowLayout {
        id: itemsLeft
        anchors {
          left: parent.left
          leftMargin: Global.format.spacing_medium
          verticalCenter: parent.verticalCenter
        }
        spacing: Global.format.spacing_medium

        Systray {
          id: systray
          Layout.alignment: Qt.AlignCenter
          onMenuShow: (items) => leftMenu.showMenu(items)
        }
      }
    }
  }

  // Left connector bridge
  Rectangle {
    color: Global.colors.surface
    anchors {
      top: parent.top
      left: leftMouseArea.right
      right: centerMouseArea.left
    }
    implicitHeight: 6
    visible: leftRect.visible && centerRect.visible
  }

  BarMenu {
    id: leftMenu
    window: panel
    edge: BarMenu.Left
    padding: Global.format.radius_medium

    Item {
      id: startItem
      implicitWidth: 300
      implicitHeight: 400
    }
  }

  MouseArea {
    id: centerMouseArea
    hoverEnabled: true
    acceptedButtons: Qt.RightButton
    propagateComposedEvents: true
    preventStealing: true

    anchors {
      top: parent.top
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
    }

    implicitWidth: itemsCenterWrapper.implicitWidth + Global.format.spacing_medium * 2

    onClicked: (event) => {
      if (event.button === Qt.RightButton)
        centerMenu.visible = !centerMenu.visible
    }

    Rectangle {
      id: centerRect
      anchors.fill: parent
      bottomRightRadius: Global.format.radius_medium
      bottomLeftRadius: Global.format.radius_medium
      color: Global.colors.surface
      visible: parent.containsMouse || Global.panelAlwaysVisible

      Item {
        id: itemsCenterWrapper
        anchors.centerIn: parent
        implicitWidth: itemsCenter.implicitWidth
        implicitHeight: itemsCenter.implicitHeight

        RowLayout {
          id: itemsCenter
          anchors.centerIn: parent
          spacing: Global.format.spacing_medium

          Audio { Layout.alignment: Qt.AlignVCenter }
          Battery { Layout.alignment: Qt.AlignVCenter }
          Bluetooth { Layout.alignment: Qt.AlignVCenter }
          Network { Layout.alignment: Qt.AlignVCenter }
          Clock { Layout.alignment: Qt.AlignVCenter }
        }
      }
    }
  }

  // Right connector bridge
  Rectangle {
    color: Global.colors.surface
    anchors {
      top: parent.top
      left: centerMouseArea.right
      right: rightMouseArea.left
    }
    implicitHeight: 6
    visible: centerRect.visible && rightRect.visible
  }

  MouseArea {
    id: rightMouseArea
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    propagateComposedEvents: true
    preventStealing: true

    anchors {
      top: parent.top
      bottom: parent.bottom
      right: parent.right
    }

    implicitWidth: itemsRight.implicitWidth + Global.format.spacing_medium * 2

    Rectangle {
      id: rightRect
      anchors.fill: parent
      bottomLeftRadius: Global.format.radius_medium
      color: Global.colors.surface
      visible: parent.containsMouse || Global.panelAlwaysVisible

      RowLayout {
        id: itemsRight
        anchors {
          right: parent.right
          rightMargin: Global.format.spacing_medium
          verticalCenter: parent.verticalCenter
        }
        spacing: Global.format.spacing_medium

        Pager {
          Layout.alignment: Qt.AlignVCenter
          screen: panel.screen
        }
      }
    }
  }

  CenterMenu {
    id: centerMenu
    window: panel
  }
}
