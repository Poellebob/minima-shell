import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components.text
import qs

Item {
  id: launcherRoot

  property string searchText: ""
  property int currentIndex: 0
  property bool isExpr: false
  property bool isCommand: searchText.length > 0 && searchText[0] === ">"
  property string mathRes: ""

  readonly property var commands: [
    {
      name: "Wallpapers",
      description: "Open wallpaper selector",
      execute: function () {
        commandTriggered("Wallpapers");
      }
    },
    {
      name: "Clip",
      description: "Open clipboard manager",
      execute: function () {
        commandTriggered("Clip");
      }
    },
    {
      name: "Lock",
      description: "Lock the session",
      execute: function () {
        Quickshell.execDetached(["hyprlock"]);
      }
    },
    {
      name: "Logout",
      description: "Terminate the current session",
      execute: function () {
        Quickshell.execDetached(["loginctl", "terminate-session", Quickshell.env(
                                   "XDG_SESSION_ID")]);
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
        Quickshell.execDetached(["systemctl", "suspend"]);
      }
    },
    {
      name: "Hibernate",
      description: "Suspend to disk",
      execute: function () {
        Quickshell.execDetached(["systemctl", "hibernate"]);
      }
    }
  ]

  readonly property var filteredEntries: {
    let all;
    if (isCommand) {
      all = commands;
    } else {
      all = DesktopEntries.applications.values;
    }
    if (searchText.trim() === "")
      return all;
    const term = isCommand ? searchText.slice(1).trim().toLowerCase() :
                             searchText.toLowerCase();
    return all.filter(e => e.name.toLowerCase().includes(term));
  }

  signal closed
  signal commandTriggered(string name)

  function open() {
    searchText = "";
    currentIndex = 0;
    isExpr = false;
    mathRes = "";
    searchInput.text = "";
    searchInput.forceActiveFocus();
  }

  function close(skipSignal = false) {
    searchInput.text = "";
    isExpr = false;
    mathRes = "";
    if (!skipSignal)
      closed();
  }

  function executeSelected() {
    if (currentIndex >= 0 && currentIndex < filteredEntries.length) {
      const entry = filteredEntries[currentIndex];
      close(isCommand);
      entry.execute();
    }
  }

  function copyResult() {
    if (mathRes !== "") {
      Quickshell.execDetached(["wl-copy", mathRes]);
      close();
    }
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
      Layout.preferredWidth: 180
      Layout.fillHeight: true

      TextInput {
        id: searchInput
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        color: Global.colors.on_surface_variant
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        clip: true
        focus: true
        visible: true
        verticalAlignment: Text.AlignVCenter

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

        Keys.onLeftPressed: {
          if (!launcherRoot.isExpr && launcherRoot.currentIndex > 0)
            launcherRoot.currentIndex--;
        }
        Keys.onRightPressed: {
          if (!launcherRoot.isExpr && launcherRoot.currentIndex
              < launcherRoot.filteredEntries.length - 1)
            launcherRoot.currentIndex++;
        }
        Keys.onReturnPressed: {
          if (launcherRoot.isExpr)
            launcherRoot.copyResult();
          else
            launcherRoot.executeSelected();
        }
        Keys.onEscapePressed: launcherRoot.close()
      }
    }

    Text {
      text: "|"
      color: Global.colors.outline
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      Layout.alignment: Qt.AlignVCenter
    }

    Text {
      visible: launcherRoot.isExpr
      text: launcherRoot.mathRes
      color: Global.colors.primary
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      verticalAlignment: Text.AlignVCenter
      Layout.fillWidth: true
      Layout.fillHeight: true
    }

    ListView {
      id: appList
      visible: !launcherRoot.isExpr
      Layout.fillWidth: true
      Layout.fillHeight: true
      orientation: ListView.Horizontal
      spacing: Global.format.spacing_large
      clip: true
      currentIndex: launcherRoot.currentIndex
      highlightMoveDuration: 0

      model: launcherRoot.filteredEntries

      delegate: ClickableText {
        required property var modelData
        required property int index
        text: index === launcherRoot.currentIndex ? `[${modelData.name}]` : ` ${modelData.name} `
        baseColor: index === launcherRoot.currentIndex ? Global.colors.primary :
                                                         Global.colors.on_surface_variant
        verticalAlignment: Text.AlignVCenter
        height: parent ? parent.height : 0

        onClicked: launcherRoot.currentIndex = index
        onDoubleClicked: {
          if (launcherRoot.isCommand) {
            launcherRoot.close();
            launcherRoot.commandTriggered(modelData.name);
          } else {
            modelData.execute();
            launcherRoot.close();
          }
        }
        onWheel: wheel => {
                   if (wheel.angleDelta.x < 0 || wheel.angleDelta.y < 0) {
                     if (launcherRoot.currentIndex
                         < launcherRoot.filteredEntries.length - 1)
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
