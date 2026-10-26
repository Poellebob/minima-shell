import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components.text
import qs

Item {
  id: root

  property bool busy: false
  readonly property var current: {
    for (let i = 0; i < monitors.length; i++) {
      if (monitors[i].name === selectedName)
        return displayMonitor(monitors[i]);
    }
    return monitors.length > 0 ? displayMonitor(monitors[0]) : null;
  }
  readonly property bool dirty: Object.keys(overrides).length > 0
  readonly property var displayList: monitors.map(m => displayMonitor(m))
  readonly property var layoutPreview: {
    const aw = previewArea.width;
    const ah = previewArea.height;
    const items = [];
    for (let i = 0; i < monitors.length; i++) {
      const m = root.displayMonitor(monitors[i]);
      if (!m.enabled)
        continue;
      const swap = m.transform === "90" || m.transform === "270" || m.transform === "Flipped90" || m.transform
            === "Flipped270";

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
  property var monitors: []
  readonly property bool nixManaged: selectedName !== "" && Wm.isNixManaged(selectedName)
  property var overrides: ({})
  property string selectedName: ""
  property string status: ""
  readonly property bool statusError: root.status === "save failed"
  readonly property string statusText: {
    if (root.status !== "")
      return root.status;
    if (root.dirty)
      return "unsaved changes";
    return root.nixManaged ? "nix-managed · not saved" : "saved";
  }

  signal closed

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
  function discard(): void {
  root.overrides = {};
  root.status = "";
  root.syncInputs();
}
  function displayMonitor(m): var {
                                const patch = overrides[m.name] ?? {};
                                const out = {};
                                for (const k in m)
                                out[k] = m[k];
                                for (const k in patch)
                                out[k] = patch[k];
                                return out;
                              }
  function mirrorOptions(): var {
  const opts = [""];
  for (let i = 0; i < monitors.length; i++) {
    if (monitors[i].name !== selectedName)
    opts.push(monitors[i].name);
  }
    return opts;
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
      function monitorSummary(m): string {
        if (!m.enabled)
          return "Disabled";
        return m.width + "x" + m.height + " · " + parseFloat(Number(m.scale).toFixed(2)) + "x";
      }
      function nextMirror(): string {
        const opts = mirrorOptions();
        const cur = current ? current.mirror : "";
        const idx = opts.indexOf(cur);
        return opts[(idx + 1) % opts.length];
      }
      function nextTransform(): string {
        const opts = Wm.transformNames;
        const cur = current ? current.transform : "Normal";
        const idx = opts.indexOf(cur);
        return opts[(idx + 1) % opts.length];
      }
      function open(): void {
      status = "";
      refresh();
    }
      function prevMirror(): string {
        const opts = mirrorOptions();
        const cur = current ? current.mirror : "";
        const idx = opts.indexOf(cur);
        return opts[(idx - 1 + opts.length) % opts.length];
      }
        function prevTransform(): string {
          const opts = Wm.transformNames;
          const cur = current ? current.transform : "Normal";
          const idx = opts.indexOf(cur);
          return opts[(idx - 1 + opts.length) % opts.length];
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
          function refresh(): void {
          queryProc.running = true;
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
          label: "~" + parseFloat(Number(m.scale).toFixed(2)) + "x · " + (sz ? Math.round(sz.width / m.scale) + "x"
                                                                               + Math.round(sz.height / m.scale) : "")
        };
      }
      function syncInputs(): void {
      if (!root.current)
      return;
      if (!modeInput.activeFocus || modeInput.monitorName !== root.current.name) {
        modeInput.monitorName = root.current.name;
        modeInput.text = root.modeLabel(root.current);
        modeInput.committed = modeInput.text;
      }
        if (!xInput.activeFocus) {
          xInput.text = String(root.current.x);
          xInput.committed = xInput.text;
        }
          if (!yInput.activeFocus) {
            yInput.text = String(root.current.y);
            yInput.committed = yInput.text;
          }
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

            implicitHeight: contentCol.implicitHeight
            implicitWidth: 560

            onCurrentChanged: syncInputs()

            Connections {
              function onMonitorsSaved(ok: bool): void {
              root.busy = false;
              root.status = ok ? "saved" : "save failed";
              root.refresh();
            }

              target: Wm
            }

            Connections {
              function onScreensChanged(): void {
              root.refresh();
            }

              target: Quickshell
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
                  color: Global.colors.primary
                  text: "󰍹"
                }

                StyledText {
                  Layout.fillWidth: true
                  color: Global.colors.on_surface_variant
                  font.bold: true
                  text: "Displays"
                }

                StyledText {
                  color: Global.colors.outline
                  text: "…"
                  visible: root.busy
                }

                ClickableText {
                  baseColor: Global.colors.on_surface_variant
                  hoverColor: Global.colors.on_background
                  text: "Refresh"

                  onClicked: root.refresh()
                }

                ClickableText {
                  baseColor: Global.colors.error
                  hoverColor: Global.colors.error
                  text: "Discard"
                  visible: root.dirty

                  onClicked: root.discard()
                }

                ClickableText {
                  baseColor: root.dirty ? Global.colors.primary : Global.colors.outline
                  hoverColor: Global.colors.on_background
                  text: "Apply"

                  onClicked: {
                    modeInput.commit();
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
                  Layout.fillHeight: true
                  Layout.preferredWidth: 150
                  border.color: Global.colors.outline
                  border.width: 1
                  color: "transparent"

                  ColumnLayout {
                    id: monitorCol

                    anchors.fill: parent
                    anchors.margins: Global.format.spacing_small
                    spacing: Global.format.spacing_small

                    StyledText {
                      color: Global.colors.primary
                      font.bold: true
                      text: "Monitors"
                    }

                    ListView {
                      id: monitorList

                      Layout.fillHeight: true
                      Layout.fillWidth: true
                      clip: true
                      model: root.displayList
                      spacing: Global.format.spacing_tiny

                      delegate: Rectangle {
                        id: monitorCard

                        readonly property bool isSelected: modelData.name === root.selectedName
                        required property var modelData

                        border.color: monitorCard.isSelected ? Global.colors.primary : Global.colors.outline
                        border.width: monitorCard.isSelected ? 2 : 1
                        color: monitorMouse.containsMouse ? Global.colors.surface_container_high : "transparent"
                        height: Global.format.module_height * 2
                        width: monitorList.width

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
                            color: monitorCard.isSelected ? Global.colors.primary : monitorCard.modelData.enabled
                                                            ? Global.colors.on_surface : Global.colors.outline
                            elide: Text.ElideRight
                            font.bold: true
                            text: monitorCard.modelData.name
                          }

                          StyledText {
                            Layout.fillWidth: true
                            color: Global.colors.outline
                            elide: Text.ElideRight
                            font.pixelSize: Global.format.font_size_small
                            text: root.monitorSummary(monitorCard.modelData)
                          }
                        }

                        MouseArea {
                          id: monitorMouse

                          anchors.fill: parent
                          cursorShape: Qt.PointingHandCursor
                          hoverEnabled: true

                          onClicked: root.selectedName = monitorCard.modelData.name
                        }
                      }

                      StyledText {
                        anchors.centerIn: parent
                        color: Global.colors.outline
                        text: "No displays"
                        visible: monitorList.count <= 0
                      }
                    }
                  }
                }

                Rectangle {
                  Layout.fillHeight: true
                  Layout.fillWidth: true
                  border.color: Global.colors.outline
                  border.width: 1
                  color: "transparent"

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
                        color: Global.colors.on_surface
                        elide: Text.ElideRight
                        font.bold: true
                        text: root.current ? (root.current.description || root.current.name) : ""
                      }

                      StyledText {
                        color: root.statusError ? Global.colors.error : root.dirty ? Global.colors.primary :
                                                                                     root.nixManaged
                                                                                     ? Global.colors.outline :
                                                                                       Global.colors.primary
                        text: root.statusText
                      }
                    }

                    RowLayout {
                      Layout.fillHeight: true
                      Layout.fillWidth: true
                      spacing: Global.format.spacing_large

                      Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 230
                        border.color: Global.colors.outline
                        border.width: 1
                        color: "transparent"
                        implicitHeight: modeCardCol.implicitHeight + Global.format.spacing_small * 2

                        ColumnLayout {
                          id: modeCardCol

                          anchors.fill: parent
                          anchors.margins: Global.format.spacing_small
                          spacing: Global.format.spacing_medium

                          StyledText {
                            color: Global.colors.primary
                            font.bold: true
                            text: "Resolution & refresh"
                            visible: root.current !== null
                          }

                          ListView {
                            id: modeList

                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 140
                            clip: true
                            model: root.current ? root.current.modes : []
                            spacing: Global.format.spacing_tiny
                            visible: root.current !== null

                            delegate: Item {
                              id: modeRow

                              readonly property bool isActive: root.current !== null && modelData.label
                                                               === root.modeLabel(root.current)
                              required property var modelData

                              height: Global.format.module_height + Global.format.spacing_small
                              width: modeList.width

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
                                    color: modeRow.isActive ? Global.colors.primary : Global.colors.on_surface_variant
                                    elide: Text.ElideRight
                                    font.bold: modeRow.isActive
                                    text: modeRow.modelData.width + "x" + modeRow.modelData.height
                                  }

                                  StyledText {
                                    color: modeRow.isActive ? Global.colors.primary : Global.colors.outline
                                    text: "@" + Number(modeRow.modelData.refreshHz).toFixed(2) + "Hz"
                                  }

                                  StyledText {
                                    color: Global.colors.primary
                                    text: modeRow.isActive ? "●" : ""
                                  }
                                }
                              }

                              MouseArea {
                                id: modeMouse

                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                  const snapped = Wm.nearestScale(modeRow.modelData.width, modeRow.modelData.height,
                                                                  root.current.scale);
                                  root.apply({
                                               mode: modeRow.modelData.label,
                                               scale: snapped
                                             });
                                }
                              }
                            }

                            StyledText {
                              anchors.centerIn: parent
                              color: Global.colors.outline
                              text: "No modes"
                              visible: modeList.count <= 0
                            }
                          }

                          Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Global.format.module_height + Global.format.spacing_small
                            border.color: modeInput.activeFocus && !modeInput.acceptableInput ? Global.colors.error :
                                                                                                modeInput.activeFocus
                                                                                                ? Global.colors.primary :
                                                                                                  Global.colors.outline
                            border.width: 1
                            color: "transparent"
                            visible: root.current !== null

                            TextInput {
                              id: modeInput

                              property string committed: ""
                              property string monitorName: ""

                              function commit(): void {
                              if (!root.current || monitorName !== root.current.name || text === committed)
                              return;
                              const label = text.indexOf("@") < 0 ? text + "@" + Wm.parseModeString(root.modeLabel(
                              root.current)).refreshHz : text;
                              const mode = acceptableInput ? Wm.parseModeString(label) : null;
                              if (!mode || !isFinite(mode.width) || !isFinite(mode.height) || !isFinite(mode.refreshHz)
                              || mode.refreshHz <= 0) {
                                text = committed;
                                return;
                              }
                                text = Wm.formatMode(mode.width, mode.height, mode.refreshHz);
                                committed = text;
                                root.apply({
                                  mode: text,
                                  scale: Wm.nearestScale(mode.width, mode.height, root.current.scale)
                                });
                              }

                              anchors.fill: parent
                              anchors.margins: Global.format.spacing_small
                              clip: true
                              color: Global.colors.on_surface
                              font.family: "JetBrainsMono Nerd Font"
                              font.pixelSize: Global.format.text_size
                              selectByMouse: true
                              verticalAlignment: TextInput.AlignVCenter

                              validator: RegularExpressionValidator {
                                regularExpression: /[1-9][0-9]*x[1-9][0-9]*(@[0-9]+(\.[0-9]+)?)?/
                              }

                              onAccepted: {
                                commit();
                                focus = false;
                              }
                              onActiveFocusChanged: {
                                if (!activeFocus)
                                  commit();
                              }
                            }
                          }
                        }
                      }

                      Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 300
                        border.color: Global.colors.outline
                        border.width: 1
                        color: "transparent"
                        implicitHeight: propsCardCol.implicitHeight + Global.format.spacing_small * 2

                        ColumnLayout {
                          id: propsCardCol

                          anchors.fill: parent
                          anchors.margins: Global.format.spacing_small
                          spacing: Global.format.spacing_medium

                          RowLayout {
                            Layout.fillWidth: true
                            spacing: Global.format.spacing_medium
                            visible: root.current !== null

                            StyledText {
                              Layout.preferredWidth: 70
                              color: Global.colors.on_surface_variant
                              text: "Scale"
                            }

                            ClickableText {
                              baseColor: Global.colors.on_surface_variant
                              hoverColor: Global.colors.on_background
                              text: "◀"

                              onClicked: root.apply({
                                                      scale: root.cycleScale(-1)
                                                    })
                            }

                            StyledText {
                              Layout.fillWidth: true
                              color: root.scaleEntry() && root.scaleEntry().exact ? Global.colors.primary :
                                                                                    Global.colors.on_surface_variant
                              horizontalAlignment: Text.AlignHCenter
                              text: root.scaleEntry() ? root.scaleEntry().label : ""
                            }

                            ClickableText {
                              baseColor: Global.colors.on_surface_variant
                              hoverColor: Global.colors.on_background
                              text: "▶"

                              onClicked: root.apply({
                                                      scale: root.cycleScale(1)
                                                    })
                            }
                          }

                          RowLayout {
                            Layout.fillWidth: true
                            spacing: Global.format.spacing_medium
                            visible: root.current !== null

                            StyledText {
                              Layout.preferredWidth: 70
                              color: Global.colors.on_surface_variant
                              text: "Position"
                            }

                            Rectangle {
                              Layout.preferredHeight: Global.format.module_height + Global.format.spacing_small
                              Layout.preferredWidth: 80
                              border.color: xInput.activeFocus ? Global.colors.primary : Global.colors.outline
                              border.width: 1
                              color: "transparent"

                              RowLayout {
                                anchors.fill: parent
                                anchors.margins: Global.format.spacing_small
                                spacing: Global.format.spacing_small

                                StyledText {
                                  color: Global.colors.outline
                                  font.pixelSize: Global.format.font_size_small
                                  text: "X"
                                }

                                TextInput {
                                  id: xInput

                                  property string committed: ""

                                  function commit(): void {
                                  if (text !== committed) {
                                    committed = text;
                                    root.apply({
                                      x: Number(text)
                                    });
                                  }
                                }

                                Layout.fillWidth: true
                                color: Global.colors.on_surface
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Global.format.text_size
                                verticalAlignment: TextInput.AlignVCenter

                                validator: IntValidator {
                                  bottom: -100000
                                  top: 100000
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
                            Layout.preferredHeight: Global.format.module_height + Global.format.spacing_small
                            Layout.preferredWidth: 80
                            border.color: yInput.activeFocus ? Global.colors.primary : Global.colors.outline
                            border.width: 1
                            color: "transparent"

                            RowLayout {
                              anchors.fill: parent
                              anchors.margins: Global.format.spacing_small
                              spacing: Global.format.spacing_small

                              StyledText {
                                color: Global.colors.outline
                                font.pixelSize: Global.format.font_size_small
                                text: "Y"
                              }

                              TextInput {
                                id: yInput

                                property string committed: ""

                                function commit(): void {
                                if (text !== committed) {
                                  committed = text;
                                  root.apply({
                                    y: Number(text)
                                  });
                                }
                              }

                              Layout.fillWidth: true
                              color: Global.colors.on_surface
                              font.family: "JetBrainsMono Nerd Font"
                              font.pixelSize: Global.format.text_size
                              verticalAlignment: TextInput.AlignVCenter

                              validator: IntValidator {
                                bottom: -100000
                                top: 100000
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
                        Layout.fillWidth: true
                        spacing: Global.format.spacing_medium
                        visible: root.current !== null

                        StyledText {
                          Layout.preferredWidth: 70
                          color: Global.colors.on_surface_variant
                          text: "Transform"
                        }

                        ClickableText {
                          baseColor: Global.colors.on_surface_variant
                          hoverColor: Global.colors.on_background
                          text: "◀"

                          onClicked: root.apply({
                                                  transform: root.prevTransform()
                                                })
                        }

                        StyledText {
                          Layout.fillWidth: true
                          color: root.current && root.current.transform !== "Normal" ? Global.colors.primary :
                                                                                       Global.colors.on_surface_variant
                          horizontalAlignment: Text.AlignHCenter
                          text: root.current ? root.current.transform : ""
                        }

                        ClickableText {
                          baseColor: Global.colors.on_surface_variant
                          hoverColor: Global.colors.on_background
                          text: "▶"

                          onClicked: root.apply({
                                                  transform: root.nextTransform()
                                                })
                        }
                      }

                      RowLayout {
                        Layout.fillWidth: true
                        spacing: Global.format.spacing_medium
                        visible: Wm.hyprland && root.current !== null

                        StyledText {
                          Layout.preferredWidth: 70
                          color: Global.colors.on_surface_variant
                          text: "Mirror"
                        }

                        ClickableText {
                          baseColor: Global.colors.on_surface_variant
                          hoverColor: Global.colors.on_background
                          text: "◀"

                          onClicked: root.apply({
                                                  mirror: root.prevMirror()
                                                })
                        }

                        StyledText {
                          Layout.fillWidth: true
                          color: root.current && root.current.mirror !== "" ? Global.colors.primary :
                                                                              Global.colors.on_surface_variant
                          horizontalAlignment: Text.AlignHCenter
                          text: root.current ? (root.current.mirror === "" ? "None" : root.current.mirror) : "None"
                        }

                        ClickableText {
                          baseColor: Global.colors.on_surface_variant
                          hoverColor: Global.colors.on_background
                          text: "▶"

                          onClicked: root.apply({
                                                  mirror: root.nextMirror()
                                                })
                        }
                      }

                      RowLayout {
                        Layout.fillWidth: true
                        spacing: Global.format.spacing_medium
                        visible: root.current !== null

                        StyledText {
                          Layout.preferredWidth: 70
                          color: Global.colors.on_surface_variant
                          text: "Enabled"
                        }

                        ClickableText {
                          baseColor: root.current && root.current.enabled ? Global.colors.primary :
                                                                            Global.colors.outline
                          hoverColor: root.current && root.current.enabled ? Global.colors.on_background :
                                                                             Global.colors.primary
                          text: "On"

                          onClicked: {
                            if (root.current && !root.current.enabled)
                              root.apply({
                                           enabled: true
                                         });
                          }
                        }

                        ClickableText {
                          baseColor: root.current && !root.current.enabled ? Global.colors.primary :
                                                                             Global.colors.on_surface_variant

                          hoverColor: Global.colors.error
                          text: "Off"
                          visible: Wm.canDisable(root.selectedName)

                          onClicked: {
                            if (root.current && root.current.enabled)
                              root.apply({
                                           enabled: false
                                         });
                          }
                        }

                        StyledText {
                          color: Global.colors.outline
                          text: "(last output)"
                          visible: !Wm.canDisable(root.selectedName)
                        }

                        Item {
                          Layout.fillWidth: true
                        }
                      }
                    }
                  }

                  Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: Global.colors.outline
                    border.width: 1
                    color: "transparent"
                    implicitHeight: previewCol.implicitHeight + Global.format.spacing_small * 2

                    ColumnLayout {
                      id: previewCol

                      anchors.fill: parent
                      anchors.margins: Global.format.spacing_small
                      spacing: Global.format.spacing_medium

                      StyledText {
                        color: Global.colors.primary
                        font.bold: true
                        text: "Layout"
                      }

                      Item {
                        id: previewArea

                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        clip: true

                        StyledText {
                          anchors.centerIn: parent
                          color: Global.colors.outline
                          text: "No displays"
                          visible: root.layoutPreview.length <= 0
                        }

                        Repeater {
                          model: root.layoutPreview

                          delegate: Rectangle {
                            id: previewRect

                            required property var modelData

                            border.color: previewRect.modelData.selected ? Global.colors.primary : Global.colors.outline
                            border.width: previewRect.modelData.selected ? 2 : 1
                            color: "transparent"
                            height: modelData.h
                            width: modelData.w
                            x: modelData.x
                            y: modelData.y

                            StyledText {
                              anchors.centerIn: parent
                              color: previewRect.modelData.selected ? Global.colors.primary :
                                                                      Global.colors.on_surface_variant
                              elide: Text.ElideRight
                              font.pixelSize: Global.format.font_size_small
                              horizontalAlignment: Text.AlignHCenter
                              text: previewRect.modelData.name
                              width: parent.width - 4
                            }
                          }
                        }
                      }
                    }
                  }
                }

                StyledText {
                  color: Global.colors.outline
                  text: "No displays detected"
                  visible: root.current === null
                }
              }
            }
          }
        }
      }
