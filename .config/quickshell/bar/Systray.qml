import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

Item {
  id: systray

  implicitHeight: rect.implicitHeight
  implicitWidth: rect.implicitWidth

  Rectangle {
    id: rect
    color: panel.colors.dark_surface_variant
    radius: panel.format.radius_small
    anchors.centerIn: parent

    // Let size follow RowLayout + margins
    implicitWidth: rowLayout.implicitWidth + panel.format.spacing_medium
    implicitHeight: panel.format.module_height

    RowLayout {
      id: rowLayout
      anchors.margins: panel.format.spacing_small
      anchors.fill: parent
      spacing: panel.format.spacing_small

      Repeater {
        model: SystemTray.items
        SysTrayItem {
          required property SystemTrayItem modelData
          item: modelData
          bar: panel
        }
      }

      Text {
        Layout.alignment: Qt.AlignVCenter
        font.pixelSize: Appearance.font.pixelSize.larger
        color: Appearance.colors.colSubtext
        visible: SystemTray.items.values.length > 0
      }
    }
  }
}
