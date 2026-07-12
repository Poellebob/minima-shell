import QtQuick
import qs

ModuleBase {
  id: workspaceModule

  property var workspaces: []
  property int activeWorkspace: 0

  label: (activeWorkspace + 1).toString()

  Timer {
    interval: Global.format.interval_medium
    running: true
    repeat: true
    onTriggered: workspaceModule.updateWorkspaces()
  }

  function updateWorkspaces() {
    // Placeholder: will be connected to compositor IPC
  }
}
