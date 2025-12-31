import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.widgets.centerMenu
import qs.widgets.launcher
import qs.widgets.audio
import qs

PanelWindow {
  id: panel
  implicitHeight: Global.format.panel_height
  aboveWindows: true
  focusable: WlrKeyboardFocus.OnDemand

  anchors {
    top: true
    left: true
    right: true
  }

  HyprlandFocusGrab {
    id: grab
    windows: [launcherMenu, panel]
    active: launcher.open
    /*onActiveChanged: {
      if (!active) {
        launcher.open = false
        launcherCommand.focus = false
      }
    }*/
  }

  GlobalShortcut {
    id: launcherShortcut
    appid: "minima"
    name: "launcher"
    description: "Opens the minima-shell launcher"

    onPressed: {
      if (panel.screen.name == Hyprland.focusedMonitor?.name) {
        launcher.open = !launcher.open
        launcherCommand.focus = launcher.open
      }
    }
  }

  Rectangle {
    anchors.fill: parent
    color: Global.colors.surface
    
    Rectangle {
      id: launcher
      readonly property int maxwidth: 400
      property bool open: false
      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
      }
      implicitWidth: open ? (maxwidth > (panel.width/2 - itemsLeft.width - itemsCenter.width/2) ? ( panel.width/2 - itemsLeft.width - itemsCenter.width/2 - 16) : maxwidth) : panel.height
      color: Global.colors.surface_variant
      bottomRightRadius: Global.format.radius_large
      
      Behavior on implicitWidth {
        NumberAnimation {
          duration: 200
          easing.type: Easing.OutCubic
        }
      }
      
      Item {
        anchors {
          left: parent.left
          top: parent.top
          bottom: parent.bottom
          right: icon.left
        }
        
        Launcher {
          id: launcherCommand
          visible: launcher.open
          anchors.fill: parent

          onUp: launcherMenu.up()
          onDown: launcherMenu.down()
          onLaunch: launcherMenu.launch()
          onExit: {
            launcher.open = false
            launcherCommand.focus = false
          }
        }
      }
      
      Item{
        id: icon
        anchors {
          right: parent.right
          top: parent.top
          bottom: parent.bottom
          left: launcherCommand.right
        }
        implicitWidth: panel.height
        
        Text {
          id: iconText
          text: "󰣇"
          color: Global.colors.on_background
          font.family: "JetBrainsMono Nerd Font Propo"
          font.pixelSize: Global.format.icon_size
          anchors.centerIn: parent
        }
        
        MouseArea {
          anchors.fill: parent
          onClicked: (event) => {
            if (event.button == Qt.LeftButton) {
              launcher.open = !launcher.open
              launcherCommand.focus = launcher.open
            }
          }
        }
      }
    }
    
    RowLayout {
      id: itemsLeft
      anchors {
        left: launcher.right
        leftMargin: Global.format.spacing_medium
        verticalCenter: parent.verticalCenter
      }
      spacing: Global.format.spacing_medium
      
      Systray {
        Layout.alignment: Qt.AlignVCenter
      }
    }
    
    Item {
      id: itemsCenterWrapper
      anchors.centerIn: parent
      implicitWidth: itemsCenter.implicitWidth
      implicitHeight: itemsCenter.implicitHeight

      MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.RightButton

        onClicked: (event) => {
          if (event.button === Qt.RightButton)
            centerMenu.visible = !centerMenu.visible
        }

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
      }
    }
  }
  
  CenterMenu {
    id: centerMenu
    window: panel
  }
  
  LauncherMenu {
    id: launcherMenu
    visible: launcher.open
    command: launcherCommand.text

    onExecuted: {
      launcher.open = false
      launcherCommand.focus = false
    }
  }
}
