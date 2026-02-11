import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import qs.components.bar
import qs.components.text
import qs

ModuleBase {
  id: pagerRoot
  implicitWidth: row.implicitWidth + Global.format.spacing_medium

  required property var screen
  property bool hyprland: false

  Component.onCompleted: {
    switch (Quickshell.env("XDG_CURRENT_DESKTOP")) {
      case "Hyprland":
        pagerRoot.hyprland = true
        break;
    }
  }

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.margins: Global.format.spacing_small
    spacing: Global.format.spacing_small

    Repeater {
      model: {
        if (pagerRoot.hyprland) {
          return Hyprland.workspaces
        } else {
          return {}
        }
      }
      delegate: Rectangle {
        visible: (pagerRoot.screen.name === modelData.monitor.name) && modelData.id >= 1

        color: modelData.active ? Global.colors.primary : Global.colors.secondary
        
        implicitHeight: Global.format.module_height - Global.format.spacing_small
        implicitWidth: implicitHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: Global.format.module_radius

        StyledText{
          text: modelData.id
          color: Global.colors.on_primary
          anchors.horizontalCenter: parent.horizontalCenter
        }
        
        MouseArea {
          anchors.fill: parent
          onClicked: modelData.activate()
        }
      }
    }
  }

  SocketServer {
    active: true
    path: Quickshell.env("HOME") + "/.local/share/minima/workspace.sock"
    handler: Socket {
      onConnectedChanged: {
        console.log("pager connected: " + connected)
      }
      parser: SplitParser {
        onRead: message => {
          try {
            var data = JSON.parse(message);
            console.log(`parsed workspace: id=${data.id}, name=${data.name}, screen=${data.screen}`);
          } catch(e) {
            console.log(`failed to parse JSON: ${e}`);
          }
        }
      }
    }
  }
}
