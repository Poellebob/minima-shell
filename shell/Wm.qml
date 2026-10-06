pragma Singleton
import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Hyprland
import qs
import qs.config

Singleton {
  readonly property bool hyprland: Global.config.system.wm === "hyprland"

  readonly property var workspaces: hyprland ? Hyprland.workspaces : I3.workspaces

  readonly property string focusedMonitorName: {
    if (hyprland) {
      const m = Hyprland.focusedMonitor;
      return m ? m.name.toString() : "";
    }
    const m = I3.focusedMonitor;
    return m ? m.name.toString() : "";
  }

  readonly property string primaryScreenName: {
    const configured = Global.config.system.primaryOutput;
    if (configured) {
      for (let i = 0; i < Quickshell.screens.length; i++) {
        if (Quickshell.screens[i].name === configured)
          return configured;
      }
    }
    for (let i = 0; i < Quickshell.screens.length; i++) {
      const s = Quickshell.screens[i];
      if (s.x === 0 && s.y === 0)
        return s.name;
    }
    return Quickshell.screens.length > 0 ? Quickshell.screens[0].name : "";
  }

  function isFocused(name: string): bool {
    const focused = focusedMonitorName;
    return !focused || name == focused;
  }

  function isPrimaryScreen(name: string): bool {
    return name === primaryScreenName;
  }

  function escapeLua(s: string): string {
    return s.replace(/\\/g, "\\\\").replace(/"/g, "\\\"");
  }

  function activateWs(ws): void {
    if (hyprland) {
      ws.activate();
      return;
    }
    if (ws.number >= 0) {
      I3.dispatch(`workspace ${ws.name}`);
    } else {
      I3.dispatch(`[workspace=${ws.name}] move workspace to output current; workspace ${ws.name}`);
    }
  }

  function toggleSpecial(name: string): void {
    if (!hyprland)
      return;
    if (Hyprland.usingLua) {
      Hyprland.dispatch(`hl.dsp.workspace.toggle_special("${escapeLua(name)}")`);
    } else {
      Hyprland.dispatch(`togglespecialworkspace ${name}`);
    }
  }
}
