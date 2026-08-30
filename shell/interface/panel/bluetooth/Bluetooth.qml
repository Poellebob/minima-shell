import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.components.widget
import qs.components.text
import qs

BarWidget {
  id: root

  signal bluetoothMenuTriggered

  visible: Bluetooth.adapters.values.length !== 0

  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property bool adapterEnabled: adapter?.state
                                         === BluetoothAdapterState.Enabled

  onClicked: mouse => {
               if (mouse.button === Qt.LeftButton)
               bluetoothMenuTriggered();
             }

  RowLayout {
    anchors.centerIn: parent
    spacing: Global.format.spacing_small

    StyledText {
      text: root.adapterEnabled ? "󰂯" : "󰂲"
      color: root.adapterEnabled ? Global.colors.on_surface_variant :
                                   Global.colors.outline
    }
  }
}
