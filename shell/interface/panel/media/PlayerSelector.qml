import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs
import qs.components.text
import qs.components.widget

MenuWidget {
  id: root

  property MprisPlayer activePlayer: null

  signal playerSelected(MprisPlayer player)

  implicitHeight: contentRow.implicitHeight

  RowLayout {
    id: contentRow
    Layout.alignment: Qt.AlignLeft
    spacing: Global.format.spacing_small

    Repeater {
      model: Mpris.players

      delegate: Item {
        required property MprisPlayer modelData

        implicitWidth: row.implicitWidth + Global.format.spacing_small * 2
        implicitHeight: Global.format.module_height

        property bool isActive: modelData === root.activePlayer

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.playerSelected(modelData)

          RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Global.format.spacing_small

            StyledText {
              text: "󰎆"
              color: isActive ? Global.colors.primary : Global.colors.on_surface_variant
            }

            StyledText {
              text: modelData.identity || "Unknown Player"
              color: parent.containsMouse
                ? Global.colors.on_surface
                : isActive
                  ? Global.colors.primary
                  : Global.colors.on_surface_variant
              elide: Text.ElideRight
            }
          }
        }
      }
    }
  }
}
