pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.I3
import Quickshell.Hyprland
import qs
import qs.config

Singleton {
  id: root

  readonly property bool hyprland: Global.config.system.wm === "hyprland"

  readonly property var workspaces: hyprland ? Hyprland.workspaces : I3.workspaces

  readonly property string homeDir: Quickshell.env("HOME")
  readonly property string minimaConfigDir: homeDir + "/.config/minima"
  readonly property string monitorsConfPath: minimaConfigDir + "/monitors.conf"
  readonly property string hyprFragmentPath: minimaConfigDir + "/monitors.lua"
  readonly property string swayFragmentPath: minimaConfigDir + "/monitors-sway.conf"

  property var savedMonitors: ({})
  property bool _confLoaded: false

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

  readonly property var transformNames: ["Normal", "90", "180", "270", "Flipped", "Flipped90", "Flipped180", "Flipped270"]
  readonly property var swayTransformNames: ["normal", "90", "180", "270", "flipped", "flipped-90", "flipped-180", "flipped-270"]

  function transformIndex(name: string): int {
    const i = transformNames.indexOf(name);
    return i < 0 ? 0 : i;
  }

  function transformName(index: int): string {
    return transformNames[index] ?? "Normal";
  }

  function isNixManaged(name: string): bool {
    const list = Global.config.system.nixDisplays ?? [];
    for (let i = 0; i < list.length; i++) {
      if (list[i] === "*" || list[i] === "" || list[i] === name)
        return true;
    }
    return false;
  }

  function monitorQueryCommand(): list<string> {
    return hyprland ? ["hyprctl", "monitors", "all", "-j"] : ["swaymsg", "-t", "get_outputs"];
  }

  function formatMode(width: real, height: real, refreshHz: real): string {
    return width + "x" + height + "@" + Number(refreshHz).toFixed(3);
  }

  function parseModeString(label: string): var {
    const m = /^(\d+)x(\d+)@([\d.]+)$/.exec(label);
    if (!m)
      return null;
    return {
      width: Number(m[1]),
      height: Number(m[2]),
      refreshHz: Number(m[3])
    };
  }

  function parseMonitors(jsonText: string): var {
    let arr;
    try {
      arr = JSON.parse(jsonText);
    } catch (e) {
      return [];
    }
    if (!Array.isArray(arr))
      return [];
    const out = [];
    for (let i = 0; i < arr.length; i++) {
      out.push(hyprland ? _parseHyprMonitor(arr[i]) : _parseSwayOutput(arr[i]));
    }
    return out;
  }

  function _parseHyprMonitor(m): var {
    const modes = [];
    const seen = {};
    const raw = m.availableModes ?? [];
    for (let i = 0; i < raw.length; i++) {
      const p = /^(\d+)x(\d+)@([\d.]+)Hz?$/.exec(raw[i]);
      if (p) {
        const label = formatMode(Number(p[1]), Number(p[2]), Number(p[3]));
        if (!seen[label]) {
          seen[label] = true;
          modes.push({
            label: label,
            width: Number(p[1]),
            height: Number(p[2]),
            refreshHz: Number(p[3])
          });
        }
      }
    }
    let mirror = m.mirrorOf ?? "none";
    if (mirror === "none" || mirror === "")
      mirror = "";
    return {
      name: m.name ?? "",
      description: m.description ?? "",
      x: m.x ?? 0,
      y: m.y ?? 0,
      width: m.width ?? 0,
      height: m.height ?? 0,
      refreshHz: m.refreshRate ?? 0,
      scale: m.scale ?? 1,
      transform: transformName(m.transform ?? 0),
      enabled: m.disabled !== true,
      mirror: mirror,
      modes: modes
    };
  }

  function _parseSwayOutput(m): var {
    const modes = [];
    const seen = {};
    const raw = m.modes ?? [];
    for (let i = 0; i < raw.length; i++) {
      const label = formatMode(raw[i].width, raw[i].height, raw[i].refresh / 1000);
      if (!seen[label]) {
        seen[label] = true;
        modes.push({
          label: label,
          width: raw[i].width,
          height: raw[i].height,
          refreshHz: raw[i].refresh / 1000
        });
      }
    }
    const t = (m.transform ?? "normal").toString();
    const ti = swayTransformNames.indexOf(t);
    const cur = m.current_mode;
    return {
      name: m.name ?? "",
      description: [m.model, m.make].filter(p => !!p).join(" - "),
      x: m.rect ? (m.rect.x ?? 0) : 0,
      y: m.rect ? (m.rect.y ?? 0) : 0,
      width: cur ? (cur.width ?? 0) : (m.rect ? (m.rect.width ?? 0) : 0),
      height: cur ? (cur.height ?? 0) : (m.rect ? (m.rect.height ?? 0) : 0),
      refreshHz: cur ? ((cur.refresh ?? 0) / 1000) : 0,
      scale: m.scale ?? 1,
      transform: transformName(ti < 0 ? 0 : ti),
      enabled: m.active !== false,
      mirror: "",
      modes: modes
    };
  }

  function hyprRuleLua(name: string, props): string {
    const n = escapeLua(name);
    if (props.enabled === false)
      return `hl.monitor({ output = "${n}", disabled = true })`;
    const mode = props.mode && props.mode !== "" ? props.mode : "preferred";
    const pos = (props.x ?? 0) + "x" + (props.y ?? 0);
    const parts = [`output = "${n}"`, `mode = "${escapeLua(mode)}"`, `position = "${pos}"`, `scale = ${Number(props.scale ?? 1)}`];
    const t = transformIndex(props.transform ?? "Normal");
    parts.push(`transform = ${t}`);
    if (props.mirror && props.mirror !== "")
      parts.push(`mirror = "${escapeLua(props.mirror)}"`);
    return `hl.monitor({ ${parts.join(", ")} })`;
  }

  function swayOutputCmd(name: string, props): string {
    const n = escapeLua(name);
    if (props.enabled === false)
      return `output "${n}" disable`;
    const parts = [`output "${n}"`];
    const mode = props.mode ?? "";
    if (mode !== "" && mode !== "preferred")
      parts.push(`resolution ${mode}Hz`);
    parts.push(`position ${props.x ?? 0},${props.y ?? 0}`);
    parts.push(`scale ${Number(props.scale ?? 1)}`);
    const t = transformIndex(props.transform ?? "Normal");
    parts.push(`transform ${swayTransformNames[t] ?? "normal"}`);
    parts.push("enable");
    return parts.join(" ");
  }

  function applyMonitor(name: string, props): void {
    if (isNixManaged(name)) {
      if (hyprland) {
        Quickshell.execDetached(["hyprctl", "eval", hyprRuleLua(name, props)]);
      } else {
        I3.dispatch(swayOutputCmd(name, props));
      }
      _refreshTimer.restart();
    } else {
      persistMonitor(name, props);
    }
  }

  function persistMonitor(name: string, props): void {
    const next = {};
    for (const k in savedMonitors)
      next[k] = savedMonitors[k];
    next[name] = {
      mode: props.mode ?? "",
      x: props.x ?? 0,
      y: props.y ?? 0,
      scale: props.scale ?? 1,
      transform: props.transform ?? "Normal",
      enabled: props.enabled !== false,
      mirror: props.mirror ?? ""
    };
    savedMonitors = next;
    _writeState();
  }

  function _writeState(): void {
    const luaLines = ["-- Auto-generated by minima — do not edit manually"];
    const swayLines = ["# Auto-generated by minima — do not edit manually"];
    for (const name in savedMonitors) {
      luaLines.push(hyprRuleLua(name, savedMonitors[name]));
      swayLines.push(swayOutputCmd(name, savedMonitors[name]));
    }
    _writeProc.luaText = luaLines.join("\n") + "\n";
    _writeProc.swayText = swayLines.join("\n") + "\n";
    _writeProc.confText = JSON.stringify(savedMonitors, null, 2) + "\n";
    _writeProc.running = true;
  }

  function reloadWm(): void {
    if (hyprland) {
      Quickshell.execDetached(["hyprctl", "reload"]);
    } else {
      I3.dispatch("reload");
    }
    _refreshTimer.restart();
  }

  function canDisable(name: string): bool {
    let enabled = 0;
    for (let i = 0; i < monitorsLive.length; i++) {
      if (monitorsLive[i].enabled && monitorsLive[i].name !== name)
        enabled++;
    }
    return enabled >= 1;
  }

  function scaleOptions(width: real, height: real): var {
    const opts = [];
    if (!width || !height)
      return opts;
    for (let n = 10; n <= 60; n++) {
      const s = n / 20;
      const lw = width / s;
      const lh = height / s;
      if (Math.abs(lw - Math.round(lw)) < 0.001 && Math.abs(lh - Math.round(lh)) < 0.001) {
        opts.push({
          scale: s,
          width: Math.round(lw),
          height: Math.round(lh)
        });
      }
    }
    return opts;
  }

  function nearestScale(width: real, height: real, scale: real): real {
    const opts = scaleOptions(width, height);
    if (opts.length === 0)
      return scale;
    let best = opts[0].scale;
    for (let i = 0; i < opts.length; i++) {
      if (Math.abs(opts[i].scale - scale) < Math.abs(best - scale))
        best = opts[i].scale;
    }
    return best;
  }

  function ensureFragments(): void {
    _ensureProc.running = true;
  }

  property var monitorsLive: []
  signal monitorsSaved(bool ok)

  Timer {
    id: _refreshTimer
    interval: 250
    onTriggered: {
      if (Wm.hyprland)
        Hyprland.refreshMonitors();
      else
        I3.refreshMonitors();
    }
  }

  Process {
    id: _ensureProc
    command: ["/bin/sh", "-c", "mkdir -p \"$HOME/.config/minima\" && "
      + "for f in monitors.lua monitors-sway.conf; do "
      + "p=\"$HOME/.config/minima/$f\"; "
      + "if [ ! -f \"$p\" ]; then "
      + "case \"$f\" in *.lua) h='-- Auto-generated by minima — do not edit manually';; *) h='# Auto-generated by minima — do not edit manually';; esac; "
      + "printf '%s\\n' \"$h\" > \"$p\"; fi; done"]
    onExited: code => {
      if (code !== 0)
        console.warn("Wm: failed to ensure monitor fragments");
    }
  }

  Process {
    id: _writeProc
    property string luaText: ""
    property string swayText: ""
    property string confText: ""
    command: ["/bin/sh", "-c", "mkdir -p \"$HOME/.config/minima\" && "
      + "cat > \"$HOME/.config/minima/monitors.lua\" << 'MINIMA_EOF'\n" + luaText + "MINIMA_EOF\n"
      + "cat > \"$HOME/.config/minima/monitors-sway.conf\" << 'MINIMA_EOF'\n" + swayText + "MINIMA_EOF\n"
      + "cat > \"$HOME/.config/minima/monitors.conf\" << 'MINIMA_EOF'\n" + confText + "MINIMA_EOF\n"
      + "test -s \"$HOME/.config/minima/monitors.lua\" && "
      + "test -s \"$HOME/.config/minima/monitors-sway.conf\" && "
      + "test -s \"$HOME/.config/minima/monitors.conf\""]
    onExited: code => {
      const ok = code === 0;
      if (ok)
        reloadWm();
      monitorsSaved(ok);
      if (!ok)
        console.warn("Wm: failed to write monitor state");
    }
  }

  FileView {
    id: _confFile
    path: root.monitorsConfPath
    blockLoading: false
    watchChanges: true

    onLoaded: {
      let parsed = {};
      try {
        const t = text();
        if (t.trim() !== "")
          parsed = JSON.parse(t);
      } catch (e) {
        parsed = {};
      }
      root.savedMonitors = parsed;
      root._confLoaded = true;
    }
    onFileChanged: reload()
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
