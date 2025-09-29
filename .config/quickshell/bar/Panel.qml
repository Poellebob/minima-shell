import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.format
import qs.colors
import qs.widgets

PanelWindow {
  id: panel
  readonly property Format format: Format {}
  required property Colors colors
  implicitHeight: format.panel_height
  aboveWindows: true
  focusable: WlrKeyboardFocus.Exclusive

  anchors {
    top: true
    left: true
    right: true
  }

  HyprlandFocusGrab {
    id: grab
    windows: [panel]
    active: launcher.open
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
    color: panel.colors.surface
    
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
      color: panel.colors.surface_variant
      bottomRightRadius: panel.format.radius_large
      
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
        }
      }
      
      Item{
        id: icon
        anchors {
          right: parent.right
          top: parent.top
          bottom: parent.bottom
          rightMargin: 6
        }
        implicitWidth: iconText.width
        
        Text {
          id: iconText
          text: "󰣇"
          color: panel.colors.on_background
          font.pixelSize: panel.format.icon_size
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
        leftMargin: panel.format.spacing_medium
        verticalCenter: parent.verticalCenter
      }
      spacing: panel.format.spacing_medium
      
      Systray {
        Layout.alignment: Qt.AlignVCenter
      }
    }
    
    Item {
      id: itemsCenterWrapper
      anchors.centerIn: parent
      implicitWidth: itemsCenter.width
      implicitHeight: parent.height
      
      MouseArea {
        onClicked: (event) => {
          if (event.button == Qt.LeftButton) {
            centerMenu.visible = !centerMenu.visible
          }
        }
        anchors.fill: parent
        
        RowLayout {
          id: itemsCenter
          anchors.centerIn: parent
          spacing: panel.format.spacing_medium
          
          Audio {
            Layout.alignment: Qt.AlignCenter
          }
          Battery {
            Layout.alignment: Qt.AlignVCenter
          }
          Bluetooth {
            Layout.alignment: Qt.AlignVCenter
          }
          Network {
            Layout.alignment: Qt.AlignVCenter
          }
          Clock {
            Layout.alignment: Qt.AlignVCenter
          }
        }
      }
    }
    
    RowLayout {
      id: itemsRight
      anchors {
        right: parent.right
        rightMargin: panel.format.spacing_medium
        verticalCenter: parent.verticalCenter
      }
      spacing: panel.format.spacing_medium
      
      Pager {
        Layout.alignment: Qt.AlignVCenter
      }
    }
  }
  
  CenterMenu {
    id: centerMenu
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