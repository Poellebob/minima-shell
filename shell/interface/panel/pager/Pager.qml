import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components.widget
import qs.components.text

Item {
  id: pagerRoot
  required property var screen

  implicitHeight: Global.format.module_height
  implicitWidth: row.implicitWidth + Global.format.spacing_medium

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.margins: Global.format.spacing_tiny
    spacing: 0

    Repeater {
      model: Wm.workspaces

      delegate: ClickableText {
        property int wsId: Wm.hyprland ? modelData.id : modelData.number
        property string wsOutput: {
          const m = modelData.monitor;
          return m ? m.name.toString() : "";
        }
        property bool wsSpecial: Wm.hyprland && modelData.id < 0 && modelData.name.startsWith("special:")
        property bool wsActive: Wm.hyprland
          ? (modelData.active && (!modelData.monitor || modelData.monitor.name.toString() === pagerRoot.screen.name.toString()))
          : (modelData.focused && wsOutput === pagerRoot.screen.name.toString())
        property string wsLabel: Wm.hyprland
          ? (wsSpecial ? modelData.name.slice(8) : modelData.id.toString())
          : modelData.name

        property string displayLabel: wsActive ? `[${wsLabel}]` : ` ${wsLabel} `

        text: displayLabel
        baseColor: wsActive ? Global.colors.primary : Global.colors.outline
        verticalAlignment: Text.AlignVCenter

        visible: wsSpecial
          || (Wm.hyprland && wsOutput === pagerRoot.screen.name.toString())
          || (!Wm.hyprland && ((wsId > 0 && wsOutput === pagerRoot.screen.name.toString()) || wsId < 0))
        Layout.fillWidth: false
        Layout.fillHeight: true

        onClicked: {
          if (wsSpecial)
            Wm.toggleSpecial(modelData.name.slice(8));
          else
            Wm.activateWs(modelData);
        }
      }
    }
  }
}
