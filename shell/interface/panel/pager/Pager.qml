import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.I3
import qs.components.widget
import qs.components.text
import qs

Item {
  id: pagerRoot
  required property var screen
  property bool hyprland: false
  property bool i3: false

  implicitHeight: Global.format.module_height
  implicitWidth: row.implicitWidth + Global.format.spacing_medium

  Component.onCompleted: {
    switch (Global.config.system.wm) {
    case "hyprland":
      pagerRoot.hyprland = true;
      break;
    case "sway":
    case "swayfx":
    case "scroll":
      pagerRoot.i3 = true;
      break;
    }
  }

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.margins: Global.format.spacing_tiny
    spacing: 0

    Repeater {
      model: {
        if (pagerRoot.hyprland) {
          return Hyprland.workspaces;
        }
        if (pagerRoot.i3) {
          return I3.workspaces;
        }
        return [];
      }

      delegate: ClickableText {
        property int wsId: {
          if (pagerRoot.hyprland) {
            return modelData.id;
          }
          if (pagerRoot.i3) {
            return modelData.number;
          }
        }
        property string wsOutput: {
          if (pagerRoot.hyprland) {
            return modelData.monitor.name;
          }
          if (pagerRoot.i3) {
            return modelData.monitor.name;
          }
        }
        property bool wsActive: {
          if (pagerRoot.hyprland) {
            return modelData.active;
          }
          if (pagerRoot.i3) {
            return modelData.focused && (wsOutput.toString()
                                         === pagerRoot.screen.name.toString());
          }
        }
        property string wsLabel: {
          if (pagerRoot.hyprland) {
            return wsId.toString();
          }
          if (pagerRoot.i3) {
            return modelData.name;
          }
          return "";
        }

        property string displayLabel: wsActive ? `[${wsLabel}]` : ` ${wsLabel} `

        text: displayLabel
        baseColor: wsActive ? Global.colors.primary : Global.colors.outline
        verticalAlignment: Text.AlignVCenter

        visible: (wsId > 0 && wsOutput.toString()
                  === pagerRoot.screen.name.toString()) || (wsId < 0
                                                            && pagerRoot.i3)
        Layout.fillWidth: false
        Layout.fillHeight: true

        onClicked: {
          if (pagerRoot.i3) {
            if (wsId >= 0) {
              I3.dispatch(`workspace ${wsLabel}`);
            } else {
              I3.dispatch(`[workspace=${wsLabel}] move workspace to output current; workspace 
${wsLabel}`);
            }
            return;
          }
          modelData.activate();
        }
      }
    }
  }
}
