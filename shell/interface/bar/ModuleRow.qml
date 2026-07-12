import QtQuick
import QtQuick.Layouts
import qs
import qs.bar.modules

RowLayout {
  id: moduleRow

  property int focusedIndex: -1
  property int moduleCount: modules.length
  property var modules: [
    { name: "Workspace", icon: "󰖨", component: "WorkspaceModule" },
    { name: "Audio", icon: "󰕾", component: "AudioModule" },
    { name: "Battery", icon: "󰁹", component: "BatteryModule" },
    { name: "Network", icon: "󰤨", component: "NetworkModule" },
    { name: "Bluetooth", icon: "󰂯", component: "BluetoothModule" },
    { name: "Clock", icon: "", component: "ClockModule" }
  ]

  signal moduleActivated(int index)
  signal moduleFocused(int index)

  spacing: Global.format.spacing_small

  Repeater {
    model: moduleRow.modules

    ModuleBase {
      Layout.fillHeight: true
      Layout.preferredWidth: implicitWidth
      icon: modelData.icon
      label: modelData.name === "Clock" ? Qt.formatDateTime(new Date(), "HH:mm") : modelData.name
      isFocused: moduleRow.focusedIndex === index

      onActivated: moduleRow.moduleActivated(index)
    }
  }

  function focusNext() {
    if (moduleCount === 0) return
    var next = focusedIndex + 1
    if (next >= moduleCount) next = 0
    setFocused(next)
  }

  function focusPrev() {
    if (moduleCount === 0) return
    var prev = focusedIndex - 1
    if (prev < 0) prev = moduleCount - 1
    setFocused(prev)
  }

  function setFocused(index) {
    focusedIndex = index
    moduleFocused(index)
  }

  function clearFocus() {
    focusedIndex = -1
  }

  function moduleName(index) {
    if (index < 0 || index >= moduleCount) return ""
    return modules[index].name
  }
}
