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

    anchors{
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
      visible: systray.visible && ( parent.containsMouse || Global.panelAlwaysVisible )

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
          Layout.alignment: Qt.AlignVCenter
          onMenuShow: (items) => leftMenu.showMenu(items)
        }
      }
    }
  }
  
  DropdownWindow {
    id: leftMenu
    window: panel
    x: 0
    color: "transparent"

    // Using ternary logic to keep the bindings clean and reactive
    implicitWidth: menuItems.visible ? (menuItems.implicitWidth + Global.format.radius_medium * 2) :
                   startMenu.visible ? (startMenu.implicitWidth + Global.format.radius_medium * 2) : 1

    implicitHeight: menuItems.visible ? (menuItems.implicitHeight + Global.format.radius_medium * 2) :
                    startMenu.visible ? (startMenu.implicitHeight + Global.format.radius_medium * 2) : 1

    function showMenu(items) {
      leftMenu.visible = true
      startMenu.visible = false
      menuItems.visible = true
      menuItems.model = items
    }

    function showStartMenu() {
      leftMenu.visible = true
      menuItems.visible = false
      startMenu.visible = true
    }

    Menu {
      id: menuItems
      implicitWidth: 300
      anchors.fill: parent
      x: Global.format.radius_medium
      y: Global.format.radius_medium
      visible: false
      model: []
    }

    Item {
      id: startMenu
      x: Global.format.radius_medium
      y: Global.format.radius_medium
      implicitWidth: 300
      implicitHeight: 400
      visible: false
    }
  }

  MouseArea {
    id: centerMouseArea
    hoverEnabled: true
    acceptedButtons: Qt.RightButton
    propagateComposedEvents: true
    preventStealing: true

    anchors{
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


  MouseArea {
    id: rightMouseArea
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    propagateComposedEvents: true
    preventStealing: true

    anchors{
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
