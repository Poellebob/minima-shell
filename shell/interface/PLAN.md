# Minima Interface: TUI-Style Keyboard-Driven Shell

A vim-statusline-inspired horizontal bar that replaces quickshell. Modules are
discrete square blocks. When focused via keyboard, the bar expands vertically
inline to reveal full module content. Everything is keyboard-driven.

## Design

- **Visual**: Status bar with square modules (vim-style statusline)
- **Interaction**: Always keyboard-driven (no modal system)
- **Expansion**: Inline - the bar itself grows taller
- **Position**: Configurable (top/bottom) via `settings.Interface.position`
- **Relationship**: Replaces quickshell entirely

## Keyboard Navigation

| Key           | Action                                    |
|---------------|-------------------------------------------|
| `Tab` / `S-Tab` | Cycle focus through modules           |
| `j` / `k` or `↑` / `↓` | Navigate within expanded content |
| `l` / `→` / `Enter` | Expand focused module / activate item |
| `h` / `←` / `Escape` | Collapse expanded module / go back  |
| `g` / `G`     | Jump to first / last item                 |
| `1-9`          | Direct access to module by index          |
| `/`            | Search mode (in launcher, clipboard)      |
| `Super+<key>`  | Global shortcuts (Nix config)             |

## Architecture

```
shell/interface/
├── shell.qml                          # Entry point, IPC handlers
├── Global.qml                         # Singleton: settings, colors, format
├── settings/
│   └── ConfigAdapter.qml              # JSON config adapter
├── colors/
│   ├── Colors.qml                     # Material Design 3 palette
│   └── ColorsAdapter.qml              # Live theme loader from colors.json
├── format/
│   └── Format.qml                     # Design tokens
├── components/
│   ├── ModuleBase.qml                 # Base for collapsed module blocks
│   ├── ExpandedPanel.qml              # Base for expanded content
│   └── StyledText.qml                 # Text component
├── bar/
│   ├── StatusBar.qml                  # Main bar with keyboard nav
│   ├── ModuleRow.qml                  # Row of module blocks
│   └── modules/
│       ├── WorkspaceModule.qml        # Workspace switcher
│       ├── AudioModule.qml            # Volume display
│       ├── BatteryModule.qml          # Battery display
│       ├── NetworkModule.qml          # Network status
│       ├── BluetoothModule.qml        # Bluetooth status
│       └── ClockModule.qml            # Clock display
└── expanded/
    ├── LauncherExpanded.qml           # App search + >commands + =calc
    ├── ClipboardExpanded.qml          # Clipboard history (cliphist)
    ├── WallpaperExpanded.qml          # Wallpaper selector grid
    ├── NotificationExpanded.qml       # Notification list
    ├── HomeExpanded.qml               # System info + power actions
    ├── AudioExpanded.qml              # Volume slider + devices
    ├── BatteryExpanded.qml            # Battery details
    ├── NetworkExpanded.qml            # WiFi list + connect
    ├── BluetoothExpanded.qml          # BT device list + scan
    ├── ClockExpanded.qml              # Calendar + time
    └── WorkspaceExpanded.qml          # Workspace grid
```

## Config (config.json / Nix)

```json
{
  "System": {
    "wm": "sway",
    "matugenConfigPath": ""
  },
  "Theme": {
    "darkTheme": true
  },
  "Panel": {
    "enabled": true,
    "panelAlwaysVisible": true
  },
  "Launcher": {
    "enabled": true,
    "qalcPath": ""
  },
  "Clipboard": {
    "enabled": true
  },
  "Wallpaper": {
    "enabled": true,
    "engineEnabled": false,
    "enginePath": "",
    "workshopPath": "",
    "fps": 25,
    "fill": true,
    "matureContent": false
  },
  "Interface": {
    "position": "bottom",
    "modules": ["workspace", "audio", "battery", "network", "bluetooth", "clock"],
    "expandedHeight": 400
  }
}
```

## Implementation Phases

### Phase 1: Core Framework ✅

- [x] Port Colors.qml and ColorsAdapter.qml from quickshell
- [x] Port Format.qml with TUI tokens (bar_width, module_min_width, etc.)
- [x] Create ModuleBase.qml (collapsed module block)
- [x] Create ExpandedPanel.qml (expanded content container)
- [x] Create StyledText.qml
- [x] Build StatusBar.qml with keyboard navigation
- [x] Build ModuleRow.qml
- [x] Update shell.qml with IPC handlers
- [x] Update ConfigAdapter.qml with Interface section

### Phase 2: Essential Modules (Placeholder) ✅

- [x] WorkspaceModule + WorkspaceExpanded
- [x] AudioModule + AudioExpanded
- [x] BatteryModule + BatteryExpanded
- [x] NetworkModule + NetworkExpanded
- [x] BluetoothModule + BluetoothExpanded
- [x] ClockModule + ClockExpanded

### Phase 3: Feature Modules (Placeholder) ✅

- [x] LauncherExpanded (app search, >commands, =calculator)
- [x] ClipboardExpanded (cliphist integration)
- [x] WallpaperExpanded (wallpaper selector + matugen)
- [x] NotificationExpanded (notification center)
- [x] HomeExpanded (sysfetch, media player, power actions)

### Phase 4: Real Implementations (TODO)

- [ ] Connect WorkspaceModule to compositor IPC (Hyprland/Sway)
- [ ] Connect AudioModule to PipeWire
- [ ] Connect BatteryModule to UPower
- [ ] Connect NetworkModule to nmcli
- [ ] Connect BluetoothModule to bluetoothctl
- [ ] Implement LauncherExpanded with app discovery
- [ ] Implement ClipboardExpanded with cliphist
- [ ] Implement WallpaperExpanded with file scanning
- [ ] Implement NotificationExpanded with NotificationServer
- [ ] Implement HomeExpanded with sysfetch.sh

### Phase 5: Polish & Config (TODO)

- [ ] Add SystemTrayModule
- [ ] Add NetworkManagerExpanded (new networking feature)
- [ ] Add Nix config integration for keybinds
- [ ] Add animation polish (150ms OutCubic transitions)
- [ ] Add panelAlwaysVisible support
- [ ] Add IPC handlers for external keybind scripts
- [ ] Add multi-monitor support

## Design Decisions

1. **Inline expansion** - the bar itself grows taller, no dropdowns
2. **Single expanded module** - only one module can be expanded at a time
3. **Keyboard-first** - all interactions via keyboard; mouse optional for systray
4. **Config-driven** - module order, position, shortcuts all from config.json
5. **Shared components** - ModuleBase and ExpandedPanel provide consistent styling
6. **IPC compatibility** - same IPC handlers as quickshell for keybind scripts

## Reference: quickshell Features

### Status Bar Modules
- Audio (PipeWire volume, mute toggle, device display)
- Battery (UPower, charge states, critical alerts)
- Bluetooth (bluetoothctl, connected device cycling)
- Network (nmcli, signal strength, ethernet detection)
- Clock (SystemClock HH:mm)
- Pager (Hyprland/I3 workspace switcher)
- SystemTray (DBus tray icons)

### Feature Panels
- Launcher (app search, >commands, =calculator via qalc)
- Clipboard Manager (cliphist, search, delete)
- Wallpaper Selector (static + wallpaper engine, favorites, matugen)
- Notification Center (NotificationServer, actions, urgency)
- Home Menu (sysfetch, MediaPlayer MPRIS, power actions, SystemUsage)
- Audio Control (device switching, per-stream volume)
- BlueControl (scan, connect/disconnect, device info)

### Components
- MenuPanel (overlay base)
- DropdownWindow (bar dropdowns)
- BarMenu (bar dropdown with edge detection)
- InnerCorner (quarter-circle for bar bridges)
- StyledButton, IconButton, Toggle, Tabbar, StyledSlider
