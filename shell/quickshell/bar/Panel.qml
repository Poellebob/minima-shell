import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.components.widget
import qs.widgets.homeMenu
import qs.widgets.audio
import qs.widgets.bluetooth
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

  property bool unifyLeft: (panel.width / 2) < (centerRect.width / 2) + leftRect.width + 12
  property bool unifyRight: (panel.width / 2) < (centerRect.width / 2) + rightRect.width + 12

  readonly property real _centerWidth: itemsCenterWrapper.implicitWidth + Global.format.spacing_medium * 2
  readonly property bool _menuWider: centerMenu.implicitWidth > _centerWidth

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
      bottomRightRadius: unifyLeft ? 0 : leftMenu.visible ? 0 : Global.format.radius_medium
      color: Global.colors.surface
      visible: parent.containsMouse || Global.panelAlwaysVisible

      RowLayout {
        id: itemsLeft
        anchors {
          left: parent.left
          leftMargin: Global.format.spacing_medium
          verticalCenter: parent.verticalCenter
        }
        spacing: Global.format.spacing_medium

        Text {
          text: "󰋜"
          font.family: "CommitMono Nerd Font Mono"
          font.pixelSize: Global.format.font_size_large
          font.bold: true
          color: Global.colors.on_surface_variant
          Layout.alignment: Qt.AlignVCenter

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: leftMenu.showContent(homeContent)
          }
        }

        Systray {
          id: systray
          Layout.alignment: Qt.AlignCenter
          onMenuShow: (items) => leftMenu.showMenu(items)
        }
      }
    }
  }

  function openHome() {
    switch (Global.settings["System"]["wm"]) {
    case "hyprland":
      if (Hyprland.monitorFor(screen).focused) leftMenu.showContent(homeContent);
      break;
    case "sway":
    case "swayfx":
    case "scroll":
      if (I3.monitorFor(screen).focused) leftMenu.showContent(homeContent);
      break;
    }
  }

  Rectangle {
    id: leftBrige
    color: Global.colors.surface
    anchors {
      top: parent.top
      left: leftMouseArea.right
      right: centerMouseArea.left
    }
    implicitHeight: 6
    visible: leftRect.visible && centerRect.visible && !unifyLeft
  }

  InnerCorner {
    fillColor: Global.colors.surface
    corner: "topLeft"
    width: Global.format.radius_medium
    height: Global.format.radius_medium
    visible: leftBrige.visible
    anchors {
      left: leftBrige.left
      top: leftBrige.bottom
    }
  }
  InnerCorner {
    fillColor: Global.colors.surface
    corner: "topRight"
    width: Global.format.radius_medium
    height: Global.format.radius_medium
    visible: leftBrige.visible
    anchors {
      right: leftBrige.right
      top: leftBrige.bottom
    }
  }

  BarMenu {
    id: leftMenu
    window: panel
    edge: BarMenu.Left
    padding: Global.format.radius_medium
    round: unifyLeft ? Global.format.radius_large : 0

    HomeMenu {
      id: homeContent
      visible: false
    }
  }

  BarMenu {
    id: centerMenu
    window: panel
    edge: BarMenu.Center
    padding: Global.format.spacing_large
    leftRound: unifyLeft
      ? Global.format.radius_large
      : (_menuWider ? 0 : Global.format.radius_large)
    rightRound: unifyRight
      ? Global.format.radius_large
      : (_menuWider ? 0 : Global.format.radius_large)

    AudioControl {
      id: audioContent
      visible: false
    }

    BlueControl {
      id: btContent
      visible: false
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

    implicitWidth: centerMenu.visible && _menuWider
      ? centerMenu.implicitWidth
      : _centerWidth

    Rectangle {
      id: centerRect
      anchors.fill: parent
      bottomRightRadius: centerMenu.visible && _menuWider ? 0 : unifyRight ? 0 : Global.format.radius_medium
      bottomLeftRadius:  centerMenu.visible && _menuWider ? 0 : unifyLeft ? 0 : Global.format.radius_medium
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

          Audio {
            Layout.alignment: Qt.AlignVCenter
            onAudioMenuTriggered: centerMenu.showContent(audioContent)
          }
          Battery   { Layout.alignment: Qt.AlignVCenter }
          Bluetooth {
            Layout.alignment: Qt.AlignVCenter
            onBluetoothMenuTriggered: centerMenu.showContent(btContent)
          }
          Network   { Layout.alignment: Qt.AlignVCenter }
          Clock     { Layout.alignment: Qt.AlignVCenter }
        }
      }
    }
  }

  Rectangle {
    id: rightBrige
    color: Global.colors.surface
    anchors {
      top: parent.top
      left: centerMouseArea.right
      right: rightMouseArea.left
    }
    implicitHeight: 6
    visible: centerRect.visible && rightRect.visible && !unifyRight
  }

  InnerCorner {
    fillColor: Global.colors.surface
    corner: "topLeft"
    width: Global.format.radius_medium
    height: Global.format.radius_medium
    visible: rightBrige.visible
    anchors {
      left: rightBrige.left
      top: rightBrige.bottom
    }
  }
  InnerCorner {
    fillColor: Global.colors.surface
    corner: "topRight"
    width: Global.format.radius_medium
    height: Global.format.radius_medium
    visible: rightBrige.visible
    anchors {
      right: rightBrige.right
      top: rightBrige.bottom
    }
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
      bottomLeftRadius: unifyRight ? 0 : Global.format.radius_medium
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

}
