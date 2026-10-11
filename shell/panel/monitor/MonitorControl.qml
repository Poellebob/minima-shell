import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components.text
import qs

Item {
  id: root
  implicitWidth: 560

  property var monitors: []
  property var overrides: ({})
  property string selectedName: ""
  property bool busy: false
  property string status: ""

  readonly property var displayList: monitors.map(m => displayMonitor(m))

  readonly property var layoutPreview: {
    const aw = previewArea.width;
    const ah = previewArea.height;
    const items = [];
    for (let i = 0; i < monitors.length; i++) {
      const m = root.displayMonitor(monitors[i]);
      if (!m.enabled)
        continue;
      const swap = m.transform === "90" || m.transform === "270"
        || m.transform === "Flipped90" || m.transform === "Flipped270";
      const s = m.scale && m.scale > 0 ? m.scale : 1;
      items.push({
        name: m.name,
        lx: m.x,
        ly: m.y,
        lw: (swap ? m.height : m.width) / s,
        lh: (swap ? m.width : m.height) / s,
        selected: m.name === root.selectedName
      });
    }
    if (items.length === 0 || aw <= 0 || ah <= 0)
      return [];
    let minX = 0;
    let minY = 0;
    let maxX = 0;
    let maxY = 0;
    for (let i = 0; i < items.length; i++) {
      const it = items[i];
      minX = Math.min(minX, it.lx);
      minY = Math.min(minY, it.ly);
      maxX = Math.max(maxX, it.lx + it.lw);
      maxY = Math.max(maxY, it.ly + it.lh);
    }
    const bw = Math.max(1, maxX - minX);
    const bh = Math.max(1, maxY - minY);
    const k = Math.min(aw / bw, ah / bh);
    const ox = (aw - bw * k) / 2;
    const oy = (ah - bh * k) / 2;
    const out = [];
    for (let i = 0; i < items.length; i++) {
      const it = items[i];
      out.push({
        name: it.name,
        x: ox + (it.lx - minX) * k,
        y: oy + (it.ly - minY) * k,
        w: it.lw * k,
        h: it.lh * k,
        selected: it.selected
      });
    }
    return out;
  }

  readonly property var current: {
    for (let i = 0; i < monitors.length; i++) {
      if (monitors[i].name === selectedName)
        return displayMonitor(monitors[i]);
    }
    return monitors.length > 0 ? displayMonitor(monitors[0]) : null;
  }

  readonly property bool nixManaged: selectedName !== ""
                                     && Wm.isNixManaged(selectedName)

  readonly property string statusText: {
    if (root.status !== "")
      return root.status;
    if (root.dirty)
      return "unsaved changes";
    return root.nixManaged ? "nix-managed · not saved" : "saved";
  }

  readonly property bool statusError: root.status === "save failed"

  function displayMonitor(m): var {
    const patch = overrides[m.name] ?? {};
    const out = {};
    for (const k in m)
      out[k] = m[k];
    for (const k in patch)
      out[k] = patch[k];
    return out;
  }

  function monitorSummary(m): string {
    if (!m.enabled)
      return "Disabled";
    return m.width + "x" + m.height + " · "
      + parseFloat(Number(m.scale).toFixed(2)) + "x";
  }

  function modeLabel(m): string {
    if (!m)
      return "";
    if (m.mode)
      return m.mode;
    let best = "";
    let bestDiff = 0.01;
    for (let i = 0; i < m.modes.length; i++) {
      const mode = m.modes[i];
      if (mode.width === m.width && mode.height === m.height) {
        const diff = Math.abs(mode.refreshHz - m.refreshHz);
        if (diff < bestDiff) {
          bestDiff = diff;
          best = mode.label;
        }
      }
    }
    return best !== "" ? best : Wm.formatMode(m.width, m.height, m.refreshHz);
  }

  function modeSize(): var {
    const m = root.current;
    if (!m)
      return null;
    const p = Wm.parseModeString(root.modeLabel(m));
    return p ? {
      width: p.width,
      height: p.height
    } : {
      width: m.width,
      height: m.height
    };
  }

  function scaleChoices(): var {
    const sz = modeSize();
    return sz ? Wm.scaleOptions(sz.width, sz.height) : [];
  }

  function scaleEntry(): var {
    const m = root.current;
    if (!m)
      return null;
    const sz = modeSize();
    const opts = scaleChoices();
    for (let i = 0; i < opts.length; i++) {
      if (Math.abs(opts[i].scale - m.scale) < 0.001)
        return {
          exact: true,
          label: parseFloat(Number(opts[i].scale).toFixed(2)) + "x · " + opts[i].width + "x" + opts[i].height
        };
    }
    return {
      exact: false,
      label: "~" + parseFloat(Number(m.scale).toFixed(2)) + "x · "
        + (sz ? Math.round(sz.width / m.scale) + "x" + Math.round(sz.height / m.scale) : "")
    };
  }

  function cycleScale(dir: int): real {
    const m = root.current;
    const opts = scaleChoices();
    if (!m || opts.length === 0)
      return m ? m.scale : 1;
    let idx = -1;
    for (let i = 0; i < opts.length; i++) {
      if (Math.abs(opts[i].scale - m.scale) < 0.001) {
        idx = i;
        break;
      }
    }
    if (idx < 0) {
      let best = 0;
      for (let i = 1; i < opts.length; i++) {
        if (Math.abs(opts[i].scale - m.scale) < Math.abs(opts[best].scale - m.scale))
          best = i;
      }
      return opts[best].scale;
    }
    return opts[(idx + dir + opts.length) % opts.length].scale;
  }

  function propsFor(name): var {
    for (let i = 0; i < monitors.length; i++) {
      if (monitors[i].name !== name)
        continue;
      const m = root.displayMonitor(monitors[i]);
      return {
        mode: root.modeLabel(m),
        x: m.x,
        y: m.y,
        scale: m.scale,
        transform: m.transform,
        enabled: m.enabled,
        mirror: m.mirror
      };
    }
    return null;
  }

  readonly property bool dirty: Object.keys(overrides).length > 0

  function apply(patch): void {
    if (!root.current)
      return;
    const name = root.current.name;
    const next = {};
    for (const k in root.overrides)
      next[k] = root.overrides[k];
    next[name] = Object.assign({}, root.overrides[name] ?? {}, patch);
    root.overrides = next;
    root.status = "";
  }

  function applyAll(): void {
    const names = Object.keys(overrides);
    if (names.length === 0)
      return;
    root.busy = true;
    for (let i = 0; i < names.length; i++) {
      const name = names[i];
      const props = root.propsFor(name);
      if (props)
        Wm.applyMonitor(name, props);
    }
    refreshTimer.restart();
  }

  function discard(): void {
    root.overrides = {};
    root.status = "";
    root.syncInputs();
  }

  function syncOverrides(): void {
    const next = {};
    for (const name in overrides) {
      const patch = overrides[name];
      let live = null;
      for (let i = 0; i < monitors.length; i++) {
        if (monitors[i].name === name) {
          live = monitors[i];
          break;
        }
      }
      const remaining = {};
      let dirty = false;
      for (const k in patch) {
        const liveVal = k === "mode" ? modeLabel(live) : live ? live[k] : undefined;
        if (!live || liveVal !== patch[k]) {
          remaining[k] = patch[k];
          dirty = true;
        }
      }
      if (dirty)
        next[name] = remaining;
    }
    overrides = next;
  }

  function refresh(): void {
    queryProc.running = true;
  }

  function syncInputs(): void {
    if (!root.current)
      return;
    if (!xInput.activeFocus) {
      xInput.text = String(root.current.x);
      xInput.committed = xInput.text;
    }
    if (!yInput.activeFocus) {
      yInput.text = String(root.current.y);
      yInput.committed = yInput.text;
    }
  }

  onCurrentChanged: syncInputs()

  signal closed

  function open(): void {
    status = "";
    refresh();
  }

  function mirrorOptions(): var {
    const opts = [""];
    for (let i = 0; i < monitors.length; i++) {
      if (monitors[i].name !== selectedName)
        opts.push(monitors[i].name);
    }
    return opts;
  }

  function nextMirror(): string {
    const opts = mirrorOptions();
    const cur = current ? current.mirror : "";
    const idx = opts.indexOf(cur);
    return opts[(idx + 1) % opts.length];
  }

  function prevMirror(): string {
    const opts = mirrorOptions();
    const cur = current ? current.mirror : "";
    const idx = opts.indexOf(cur);
    return opts[(idx - 1 + opts.length) % opts.length];
  }

  function nextTransform(): string {
    const opts = Wm.transformNames;
    const cur = current ? current.transform : "Normal";
    const idx = opts.indexOf(cur);
    return opts[(idx + 1) % opts.length];
  }

  function prevTransform(): string {
    const opts = Wm.transformNames;
    const cur = current ? current.transform : "Normal";
    const idx = opts.indexOf(cur);
    return opts[(idx - 1 + opts.length) % opts.length];
  }

  Connections {
    target: Wm

    function onMonitorsSaved(ok: bool): void {
      root.busy = false;
      root.status = ok ? "saved" : "save failed";
      root.refresh();
    }
  }

  Connections {
    target: Quickshell

    function onScreensChanged(): void {
      root.refresh();
    }
  }

  Timer {
    id: refreshTimer
    interval: 350
    onTriggered: root.refresh()
  }

  Process {
    id: queryProc
    command: Wm.monitorQueryCommand()

    stdout: StdioCollector {
      onStreamFinished: {
        const list = Wm.parseMonitors(this.text);
        root.monitors = list;
        Wm.monitorsLive = list;
        root.syncOverrides();
        if (list.length > 0) {
          let found = false;
          for (let i = 0; i < list.length; i++) {
            if (list[i].name === root.selectedName) {
              found = true;
              break;
            }
          }
          if (!found)
            root.selectedName = list[0].name;
        } else {
          root.selectedName = "";
        }
        root.busy = false;
      }
    }
  }

  ColumnLayout {
    id: contentCol
    anchors.fill: parent
    spacing: Global.format.spacing_large

    RowLayout {
      Layout.fillWidth: true
      Layout.preferredHeight: Global.format.module_height
      spacing: Global.format.spacing_medium

      StyledText {
        text: "󰍹"
        color: Global.colors.primary
      }

      StyledText {
        Layout.fillWidth: true
        text: "Displays"
        color: Global.colors.on_surface_variant
        font.bold: true
      }

      StyledText {
        visible: root.busy
        text: "…"
        color: Global.colors.outline
      }

      ClickableText {
        text: "Refresh"
        baseColor: Global.colors.on_surface_variant
        hoverColor: Global.colors.on_background

        onClicked: root.refresh()
      }

      ClickableText {
        visible: root.dirty
        text: "Discard"
        baseColor: Global.colors.error
        hoverColor: Global.colors.error

        onClicked: root.discard()
      }

      ClickableText {
        text: "Apply"
        baseColor: root.dirty ? Global.colors.primary : Global.colors.outline
        hoverColor: Global.colors.on_background

        onClicked: {
          if (root.dirty)
            root.applyAll();
        }
      }
    }

    RowLayout {
      Layout.fillWidth: true
      Layout.preferredHeight: detailsCol.implicitHeight + Global.format.spacing_small * 2
      spacing: Global.format.spacing_large

      Rectangle {
        Layout.preferredWidth: 150
        Layout.fillHeight: true
        color: "transparent"
        border.color: Global.colors.outline
        border.width: 1

        ColumnLayout {
          id: monitorCol
          anchors.fill: parent
          anchors.margins: Global.format.spacing_small
          spacing: Global.format.spacing_small

          StyledText {
            text: "Monitors"
            font.bold: true
            color: Global.colors.primary
          }

          ListView {
            id: monitorList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Global.format.spacing_tiny

            model: root.displayList

            StyledText {
              anchors.centerIn: parent
              text: "No displays"
              color: Global.colors.outline
              visible: monitorList.count <= 0
            }

            delegate: Rectangle {
              id: monitorCard
              required property var modelData
              readonly property bool isSelected: modelData.name === root.selectedName

              width: monitorList.width
              height: Global.format.module_height * 2
              color: monitorMouse.containsMouse ? Global.colors.surface_container_high : "transparent"
              border.color: monitorCard.isSelected ? Global.colors.primary : Global.colors.outline
              border.width: monitorCard.isSelected ? 2 : 1

              Behavior on color {
                ColorAnimation {
                  duration: 100
                  easing.type: Easing.OutCubic
                }
              }

              ColumnLayout {
                anchors.fill: parent
                anchors.margins: Global.format.spacing_small
                spacing: Global.format.spacing_tiny

                StyledText {
                  Layout.fillWidth: true
                  text: monitorCard.modelData.name
                  font.bold: true
                  elide: Text.ElideRight
                  color: monitorCard.isSelected ? Global.colors.primary :
                         monitorCard.modelData.enabled ? Global.colors.on_surface : Global.colors.outline
                }

                StyledText {
                  Layout.fillWidth: true
                  text: root.monitorSummary(monitorCard.modelData)
                  font.pixelSize: Global.format.font_size_small
                  elide: Text.ElideRight
                  color: Global.colors.outline
                }
              }

              MouseArea {
                id: monitorMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: root.selectedName = monitorCard.modelData.name
              }
            }
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "transparent"
        border.color: Global.colors.outline
        border.width: 1

        ColumnLayout {
          id: detailsCol
          anchors.fill: parent
          anchors.margins: Global.format.spacing_small
          spacing: Global.format.spacing_medium

          RowLayout {
            Layout.fillWidth: true
            spacing: Global.format.spacing_medium

            StyledText {
              Layout.fillWidth: true
              text: root.current ? (root.current.description || root.current.name) : ""
              color: Global.colors.on_surface
              font.bold: true
              elide: Text.ElideRight
            }

            StyledText {
              text: root.statusText
              color: root.statusError ? Global.colors.error :
                     root.dirty ? Global.colors.primary :
                     root.nixManaged ? Global.colors.outline : Global.colors.primary
            }
          }

          RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Global.format.spacing_large

            Rectangle {
              Layout.preferredWidth: 230
              Layout.fillHeight: true
              implicitHeight: modeCardCol.implicitHeight + Global.format.spacing_small * 2
              color: "transparent"
              border.color: Global.colors.outline
              border.width: 1

              ColumnLayout {
                id: modeCardCol
                anchors.fill: parent
                anchors.margins: Global.format.spacing_small
                spacing: Global.format.spacing_medium

                StyledText {
                  visible: root.current !== null
                  text: "Resolution & refresh"
                  font.bold: true
                  color: Global.colors.primary
                }

                ListView {
                  id: modeList
                  visible: root.current !== null
                  Layout.fillWidth: true
                  Layout.fillHeight: true
                  Layout.preferredHeight: 140
                  clip: true
                  spacing: Global.format.spacing_tiny

                  model: root.current ? root.current.modes : []

                  StyledText {
                    anchors.centerIn: parent
                    text: "No modes"
                    color: Global.colors.outline
                    visible: modeList.count <= 0
                  }

                  delegate: Item {
                    id: modeRow
                    required property var modelData
                    readonly property bool isActive: root.current !== null
                                                    && modelData.label === root.modeLabel(root.current)

                    width: modeList.width
                    height: Global.format.module_height + Global.format.spacing_small

                    Rectangle {
                      anchors.fill: parent
                      color: modeMouse.containsMouse ? Global.colors.surface_container_high : "transparent"

                      Behavior on color {
                        ColorAnimation {
                          duration: 100
                          easing.type: Easing.OutCubic
                        }
                      }

                      RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Global.format.spacing_small
                        anchors.rightMargin: Global.format.spacing_small
                        spacing: Global.format.spacing_medium

                        StyledText {
                          Layout.fillWidth: true
                          text: modeRow.modelData.width + "x" + modeRow.modelData.height
                          font.bold: modeRow.isActive
                          elide: Text.ElideRight
                          color: modeRow.isActive ? Global.colors.primary :
                                 Global.colors.on_surface_variant
                        }

                        StyledText {
                          text: "@" + Number(modeRow.modelData.refreshHz).toFixed(2) + "Hz"
                          color: modeRow.isActive ? Global.colors.primary : Global.colors.outline
                        }

                        StyledText {
                          text: modeRow.isActive ? "●" : ""
                          color: Global.colors.primary
                        }
                      }
                    }

                    MouseArea {
                      id: modeMouse
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor

                      onClicked: {
                        const snapped = Wm.nearestScale(modeRow.modelData.width,
                                                        modeRow.modelData.height,
                                                        root.current.scale);
                        root.apply({
                          mode: modeRow.modelData.label,
                          scale: snapped
                        });
                      }
                    }
                  }
                }
              }
            }

            Rectangle {
              Layout.preferredWidth: 300
              Layout.fillHeight: true
              implicitHeight: propsCardCol.implicitHeight + Global.format.spacing_small * 2
              color: "transparent"
              border.color: Global.colors.outline
              border.width: 1

              ColumnLayout {
                id: propsCardCol
                anchors.fill: parent
                anchors.margins: Global.format.spacing_small
                spacing: Global.format.spacing_medium

                RowLayout {
                  visible: root.current !== null
                  Layout.fillWidth: true
                  spacing: Global.format.spacing_medium

                  StyledText {
                    text: "Scale"
                    color: Global.colors.on_surface_variant
                    Layout.preferredWidth: 70
                  }

                  ClickableText {
                    text: "◀"
                    baseColor: Global.colors.on_surface_variant
                    hoverColor: Global.colors.on_background

                    onClicked: root.apply({
                      scale: root.cycleScale(-1)
                    })
                  }

                  StyledText {
                    Layout.fillWidth: true
                    text: root.scaleEntry() ? root.scaleEntry().label : ""
                    color: root.scaleEntry() && root.scaleEntry().exact ? Global.colors.primary :
                           Global.colors.on_surface_variant
                    horizontalAlignment: Text.AlignHCenter
                  }

                  ClickableText {
                    text: "▶"
                    baseColor: Global.colors.on_surface_variant
                    hoverColor: Global.colors.on_background

                    onClicked: root.apply({
                      scale: root.cycleScale(1)
                    })
                  }
                }

                RowLayout {
                  visible: root.current !== null
                  Layout.fillWidth: true
                  spacing: Global.format.spacing_medium

                  StyledText {
                    text: "Position"
                    color: Global.colors.on_surface_variant
                    Layout.preferredWidth: 70
                  }

                  Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: Global.format.module_height + Global.format.spacing_small
                    color: "transparent"
                    border.color: xInput.activeFocus ? Global.colors.primary : Global.colors.outline
                    border.width: 1

                    RowLayout {
                      anchors.fill: parent
                      anchors.margins: Global.format.spacing_small
                      spacing: Global.format.spacing_small

                      StyledText {
                        text: "X"
                        font.pixelSize: Global.format.font_size_small
                        color: Global.colors.outline
                      }

                      TextInput {
                        id: xInput
                        property string committed: ""
                        Layout.fillWidth: true
                        verticalAlignment: TextInput.AlignVCenter
                        color: Global.colors.on_surface
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Global.format.text_size
                        validator: IntValidator {
                          bottom: -100000
                          top: 100000
                        }

                        function commit(): void {
                          if (text !== committed) {
                            committed = text;
                            root.apply({
                              x: Number(text)
                            });
                          }
                        }

                        onAccepted: focus = false
                        onActiveFocusChanged: {
                          if (!activeFocus)
                            commit();
                        }
                      }
                    }
                  }

                  Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: Global.format.module_height + Global.format.spacing_small
                    color: "transparent"
                    border.color: yInput.activeFocus ? Global.colors.primary : Global.colors.outline
                    border.width: 1

                    RowLayout {
                      anchors.fill: parent
                      anchors.margins: Global.format.spacing_small
                      spacing: Global.format.spacing_small

                      StyledText {
                        text: "Y"
                        font.pixelSize: Global.format.font_size_small
                        color: Global.colors.outline
                      }

                      TextInput {
                        id: yInput
                        property string committed: ""
                        Layout.fillWidth: true
                        verticalAlignment: TextInput.AlignVCenter
                        color: Global.colors.on_surface
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Global.format.text_size
                        validator: IntValidator {
                          bottom: -100000
                          top: 100000
                        }

                        function commit(): void {
                          if (text !== committed) {
                            committed = text;
                            root.apply({
                              y: Number(text)
                            });
                          }
                        }

                        onAccepted: focus = false
                        onActiveFocusChanged: {
                          if (!activeFocus)
                            commit();
                        }
                      }
                    }
                  }
                }

                RowLayout {
                  visible: root.current !== null
                  Layout.fillWidth: true
                  spacing: Global.format.spacing_medium

                  StyledText {
                    text: "Transform"
                    color: Global.colors.on_surface_variant
                    Layout.preferredWidth: 70
                  }

                  ClickableText {
                    text: "◀"
                    baseColor: Global.colors.on_surface_variant
                    hoverColor: Global.colors.on_background

                    onClicked: root.apply({
                      transform: root.prevTransform()
                    })
                  }

                  StyledText {
                    Layout.fillWidth: true
                    text: root.current ? root.current.transform : ""
                    color: root.current && root.current.transform !== "Normal" ? Global.colors.primary :
                           Global.colors.on_surface_variant
                    horizontalAlignment: Text.AlignHCenter
                  }

                  ClickableText {
                    text: "▶"
                    baseColor: Global.colors.on_surface_variant
                    hoverColor: Global.colors.on_background

                    onClicked: root.apply({
                      transform: root.nextTransform()
                    })
                  }
                }

                RowLayout {
                  visible: Wm.hyprland && root.current !== null
                  Layout.fillWidth: true
                  spacing: Global.format.spacing_medium

                  StyledText {
                    text: "Mirror"
                    color: Global.colors.on_surface_variant
                    Layout.preferredWidth: 70
                  }

                  ClickableText {
                    text: "◀"
                    baseColor: Global.colors.on_surface_variant
                    hoverColor: Global.colors.on_background

                    onClicked: root.apply({
                      mirror: root.prevMirror()
                    })
                  }

                  StyledText {
                    Layout.fillWidth: true
                    text: root.current ? (root.current.mirror === "" ? "None" : root.current.mirror) : "None"
                    color: root.current && root.current.mirror !== "" ? Global.colors.primary :
                           Global.colors.on_surface_variant
                    horizontalAlignment: Text.AlignHCenter
                  }

                  ClickableText {
                    text: "▶"
                    baseColor: Global.colors.on_surface_variant
                    hoverColor: Global.colors.on_background

                    onClicked: root.apply({
                      mirror: root.nextMirror()
                    })
                  }
                }

                RowLayout {
                  visible: root.current !== null
                  Layout.fillWidth: true
                  spacing: Global.format.spacing_medium

                  StyledText {
                    text: "Enabled"
                    color: Global.colors.on_surface_variant
                    Layout.preferredWidth: 70
                  }

                  ClickableText {
                    text: "On"
                    baseColor: root.current && root.current.enabled ? Global.colors.primary :
                             Global.colors.outline
                    hoverColor: root.current && root.current.enabled ? Global.colors.on_background :
                             Global.colors.primary

                    onClicked: {
                      if (root.current && !root.current.enabled)
                        root.apply({
                          enabled: true
                        });
                    }
                  }

                  ClickableText {
                    visible: Wm.canDisable(root.selectedName)
                    text: "Off"
                    baseColor: root.current && !root.current.enabled ? Global.colors.primary :
                             Global.colors.on_surface_variant
                    hoverColor: Global.colors.error

                    onClicked: {
                      if (root.current && root.current.enabled)
                        root.apply({
                          enabled: false
                        });
                    }
                  }

                  StyledText {
                    visible: !Wm.canDisable(root.selectedName)
                    text: "(last output)"
                    color: Global.colors.outline
                  }

                  Item {
                    Layout.fillWidth: true
                  }
                }
              }
            }

            Rectangle {
              Layout.fillWidth: true
              Layout.fillHeight: true
              implicitHeight: previewCol.implicitHeight + Global.format.spacing_small * 2
              color: "transparent"
              border.color: Global.colors.outline
              border.width: 1

              ColumnLayout {
                id: previewCol
                anchors.fill: parent
                anchors.margins: Global.format.spacing_small
                spacing: Global.format.spacing_medium

                StyledText {
                  text: "Layout"
                  font.bold: true
                  color: Global.colors.primary
                }

                Item {
                  id: previewArea
                  Layout.fillWidth: true
                  Layout.fillHeight: true
                  Layout.preferredHeight: 160
                  clip: true

                  StyledText {
                    anchors.centerIn: parent
                    text: "No displays"
                    color: Global.colors.outline
                    visible: root.layoutPreview.length <= 0
                  }

                  Repeater {
                    model: root.layoutPreview

                    delegate: Rectangle {
                      id: previewRect
                      required property var modelData

                      x: modelData.x
                      y: modelData.y
                      width: modelData.w
                      height: modelData.h
                      color: "transparent"
                      border.color: previewRect.modelData.selected ? Global.colors.primary : Global.colors.outline
                      border.width: previewRect.modelData.selected ? 2 : 1

                      StyledText {
                        anchors.centerIn: parent
                        width: parent.width - 4
                        text: previewRect.modelData.name
                        font.pixelSize: Global.format.font_size_small
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        color: previewRect.modelData.selected ? Global.colors.primary : Global.colors.on_surface_variant
                      }
                    }
                  }
                }
              }
            }
          }

          StyledText {
            visible: root.current === null
            text: "No displays detected"
            color: Global.colors.outline
          }
        }
      }
    }
  }

  implicitHeight: contentCol.implicitHeight
}
