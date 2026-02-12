import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.I3
import Quickshell.Io
import qs.components.bar
import qs.components.text
import qs

ModuleBase {
  id: pagerRoot
  implicitWidth: row.implicitWidth + Global.format.spacing_medium

  required property var screen
  property bool hyprland: false
  property bool i3: false

  Component.onCompleted: {
    switch (Quickshell.env("XDG_CURRENT_DESKTOP")) {
      case "Hyprland":
        pagerRoot.hyprland = true
        break
      case "sway":
      case "i3":
      case "scroll":
        pagerRoot.i3 = true
        break
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
        }
        if (pagerRoot.i3) {
          return I3.workspaces
        }
        return []
      }

      delegate: Rectangle {

        property int wsId: {
          if (pagerRoot.hyprland) {
            return modelData.id
          }

          if (pagerRoot.i3) {
            return modelData.number
          }
        }

        property bool wsActive: {
          if (pagerRoot.hyprland) {
            return modelData.active
          }

          if (pagerRoot.i3) {
            return modelData.focused
          }
        }

        property string wsOutput: {
          if (pagerRoot.hyprland) {
            return modelData.monitor.name
          }

          if (pagerRoot.i3) {
            return modelData.monitor.name          
          }
        }

        property string wsLabel: {
          if (pagerRoot.hyprland) {
            return wsId.toString()
          }

          if (pagerRoot.i3) {
            return modelData.name
          }

          return ""
        }

        visible: (wsId > 0
          && wsOutput.toString() === pagerRoot.screen.name.toString())
          || (wsId < 0 && pagerRoot.i3)

        color: wsActive
          ? Global.colors.primary
          : Global.colors.secondary

        implicitHeight: Global.format.module_height - Global.format.spacing_small
        implicitWidth: Math.max(implicitHeight, text.width + Global.format.spacing_small)
        anchors.verticalCenter: parent.verticalCenter
        radius: Global.format.module_radius

        StyledText {
          id: text
          text: wsLabel
          color: Global.colors.on_primary
          anchors.horizontalCenter: parent.horizontalCenter
        }

        MouseArea {
          anchors.fill: parent
          onClicked: {
            if (pagerRoot.i3) {
              if (wsId >= 0) {
                I3.dispatch(`workspace ${wsLabel}`)
              } else {
                I3.dispatch(`[workspace=${wsLabel}] move workspace to output current; workspace ${wsLabel}`)
              }
              return
            }

            modelData.activate()
          }
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
