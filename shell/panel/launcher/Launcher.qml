import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components.text
import qs

Item {
  id: launcherRoot

  readonly property var commands: [
    {
      name: "Wallpapers",
      description: "Open wallpaper selector",
      execute: function () {
        openWallpaperSelector();
      }
    },
    {
      name: "Clip",
      description: "Open clipboard manager",
      execute: function () {
        openClipboard();
      }
    },
    {
      name: "Lock",
      description: "Lock the session",
      execute: function () {
        Global.openLockScreen();
      }
    },
    {
      name: "Logout",
      description: "Terminate the current session",
      execute: function () {
        Quickshell.execDetached(["loginctl", "terminate-session", Quickshell.env("XDG_SESSION_ID")]);
      }
    },
    {
      name: "Shutdown",
      description: "Power off the machine",
      execute: function () {
        Quickshell.execDetached(["systemctl", "poweroff"]);
      }
    },
    {
      name: "Reboot",
      description: "Restart the machine",
      execute: function () {
        Quickshell.execDetached(["systemctl", "reboot"]);
      }
    },
    {
      name: "Suspend",
      description: "Suspend to RAM",
      execute: function () {
        Global.openLockScreen();
        Quickshell.execDetached(["systemctl", "suspend"]);
      }
    },
    {
      name: "Hibernate",
      description: "Suspend to disk",
      execute: function () {
        Global.openLockScreen();
        Quickshell.execDetached(["systemctl", "hibernate"]);
      }
    }
  ]
  property int currentIndex: 0
  readonly property var filteredEntries: {
    let all;
    if (isCommand) {
      all = commands;
    } else {
      all = DesktopEntries.applications.values;
    }
    if (searchText.trim() === "")
      return all;
    const term = isCommand ? searchText.slice(1).trim().toLowerCase() : searchText.toLowerCase();
    return all.filter(e => e.name.toLowerCase().includes(term));
  }
  property bool isCommand: searchText.length > 0 && searchText[0] === ">"
  property bool isExpr: false
  property string mathRes: ""
  property string searchText: ""

  signal closed
  signal openClipboard
  signal openWallpaperSelector

  function close(skipSignal = false) {
    searchInput.text = "";
    isExpr = false;
    mathRes = "";
    if (!skipSignal)
      closed();
  }
  function copyResult() {
    if (mathRes !== "") {
      Quickshell.execDetached(["wl-copy", mathRes]);
      close();
    }
  }
  function executeSelected() {
    if (currentIndex >= 0 && currentIndex < filteredEntries.length) {
      const entry = filteredEntries[currentIndex];
      close(isCommand);
      entry.execute();
    }
  }
  function open() {
    searchText = "";
    currentIndex = 0;
    isExpr = false;
    mathRes = "";
    searchInput.text = "";
    searchInput.forceActiveFocus();
  }

  Process {
    id: mathProc

    property string expr: ""

    command: [Global.config.launcher.qalcPath, expr]

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.trim().split("\n");
        if (lines.length === 0)
          return;
        launcherRoot.mathRes = lines[lines.length - 1];
      }
    }
  }

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: Global.format.spacing_medium
    anchors.rightMargin: Global.format.spacing_medium
    spacing: Global.format.spacing_large

    Item {
      Layout.fillHeight: true
      Layout.preferredWidth: 180

      TextInput {
        id: searchInput

        anchors.verticalCenter: parent.verticalCenter
        clip: true
        color: Global.colors.on_surface_variant
        focus: true
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        verticalAlignment: Text.AlignVCenter
        visible: true
        width: parent.width

        Keys.onEscapePressed: launcherRoot.close()
        Keys.onLeftPressed: {
          if (!launcherRoot.isExpr && launcherRoot.currentIndex > 0)
            launcherRoot.currentIndex--;
          if (launcherRoot.isExpr && !(cursorPosition <= 1))
            cursorPosition--;
        }
        Keys.onReturnPressed: {
          if (launcherRoot.isExpr)
            launcherRoot.copyResult();
          else
            launcherRoot.executeSelected();
        }
        Keys.onRightPressed: {
          if (!launcherRoot.isExpr && launcherRoot.currentIndex < launcherRoot.filteredEntries.length - 1)
            launcherRoot.currentIndex++;
          if (launcherRoot.isExpr)
            cursorPosition++;
        }
        onTextChanged: {
          const t = text;
          if (t.length > 0 && t[0] === "=") {
            launcherRoot.isExpr = true;
            launcherRoot.mathRes = "";
            const expr = t.slice(1).trim();
            if (expr.length > 0) {
              mathProc.expr = expr;
              mathProc.running = true;
            }
          } else {
            launcherRoot.isExpr = false;
            launcherRoot.mathRes = "";
            launcherRoot.searchText = t;
            launcherRoot.currentIndex = 0;
          }
        }
      }
    }

    Text {
      Layout.alignment: Qt.AlignVCenter
      color: Global.colors.outline
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      text: "|"
    }

    Text {
      Layout.fillHeight: true
      Layout.fillWidth: true
      color: Global.colors.primary
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      text: launcherRoot.mathRes
      verticalAlignment: Text.AlignVCenter
      visible: launcherRoot.isExpr
    }

    ListView {
      id: appList

      Layout.fillHeight: true
      Layout.fillWidth: true
      clip: true
      currentIndex: launcherRoot.currentIndex
      highlightMoveDuration: 0
      model: launcherRoot.filteredEntries
      orientation: ListView.Horizontal
      spacing: Global.format.spacing_large
      visible: !launcherRoot.isExpr

      delegate: ClickableText {
        required property int index
        required property var modelData

        baseColor: index === launcherRoot.currentIndex ? Global.colors.primary : Global.colors.on_surface_variant
        height: parent ? parent.height : 0
        text: index === launcherRoot.currentIndex ? `[${modelData.name}]` : ` ${modelData.name} `
        verticalAlignment: Text.AlignVCenter

        onClicked: launcherRoot.currentIndex = index
        onDoubleClicked: {
          modelData.execute();
          launcherRoot.close();
        }
        onWheel: wheel => {
          if (wheel.angleDelta.x < 0 || wheel.angleDelta.y < 0) {
            if (launcherRoot.currentIndex < launcherRoot.filteredEntries.length - 1)
              launcherRoot.currentIndex++;
          } else {
            if (launcherRoot.currentIndex > 0)
              launcherRoot.currentIndex--;
          }
        }
      }
    }
  }
}
