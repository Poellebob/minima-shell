import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs

Item {
  id: root

  implicitWidth: 300
  implicitHeight: 200

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Global.format.spacing_large
    spacing: Global.format.spacing_medium

    StyledText {
      text: "Bluetooth Control"
      font.pixelSize: Global.format.font_size_large
      color: Global.colors.on_surface
      Layout.alignment: Qt.AlignHCenter
    }

    StyledText {
      text: "TODO: Bluetooth adapter list, device discovery, connect/disconnect"
      color: Global.colors.outline
      Layout.alignment: Qt.AlignHCenter
    }
  }
}
