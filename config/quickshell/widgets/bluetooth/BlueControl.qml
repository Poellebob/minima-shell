import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.components.widget
import qs.components.text
import qs

DropdownWindow {
  id: menuRoot
  
  implicitWidth: 600
  implicitHeight: 400

  ColumnLayout {
    spacing: Global.format.spacing_large

    Tabbar {
      id: tabs
      visible: count > 1
      model: Bluetooth.adapters

      delegate: Tab {
        text: modelData.name
      }
    }

    Rectangle {
      anchors.fill: parent
      anchors.margins: Global.format.spacing_large
      radius: Global.format.radius_large
      color: Global.colors.surface_variant

    }
  }
}
