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

  readonly property var filteredEntries: {
    const all = DesktopEntries.applications.values
    if (searchText.trim() === "") return all
    const term = searchText.toLowerCase()
    return all.filter(e => e.name.toLowerCase().includes(term))
  }
  property bool isExpr: false
  property string mathRes: ""

  signal closed

  function open() {
    searchText = ""
    currentIndex = 0
    isExpr = false
    mathRes = ""
    searchInput.text = ""
    searchInput.forceActiveFocus()
  }

  function close() {
    searchInput.text = ""
    isExpr = false
    mathRes = ""
    closed()
  }

  function executeSelected() {
    if (currentIndex >= 0 && currentIndex < filteredEntries.length) {
      filteredEntries[currentIndex].execute()
      close()
    }
  }

  function copyResult() {
    if (mathRes !== "") {
      Quickshell.execDetached(["wl-copy", mathRes])
      close()
    }
  }

  Process {
    id: mathProc
    property string expr: ""
    command: [Global.config.launcher.qalcPath, expr]

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.trim().split("\n")
        if (lines.length === 0) return
        launcherRoot.mathRes = lines[lines.length - 1]
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
          const t = text
          if (t.length > 0 && t[0] === "=") {
            launcherRoot.isExpr = true
            launcherRoot.mathRes = ""
            const expr = t.slice(1).trim()
            if (expr.length > 0) {
              mathProc.expr = expr
              mathProc.running = true
            }
          } else {
            launcherRoot.isExpr = false
            launcherRoot.mathRes = ""
            launcherRoot.searchText = t
            launcherRoot.currentIndex = 0
          }
        }

        Keys.onLeftPressed: {
          if (!launcherRoot.isExpr && launcherRoot.currentIndex > 0)
            launcherRoot.currentIndex--
        }
        Keys.onRightPressed: {
          if (!launcherRoot.isExpr && launcherRoot.currentIndex < launcherRoot.filteredEntries.length - 1)
            launcherRoot.currentIndex++
        }
        Keys.onReturnPressed: {
          if (launcherRoot.isExpr)
            launcherRoot.copyResult()
          else
            launcherRoot.executeSelected()
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

      delegate: Text {
        required property var modelData
        required property int index
        text: index === launcherRoot.currentIndex ? `[${modelData.name}]` : ` ${modelData.name} `
        color: index === launcherRoot.currentIndex ? Global.colors.primary : Global.colors.on_surface_variant
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Global.format.text_size
        verticalAlignment: Text.AlignVCenter
        height: parent ? parent.height : 0

        Behavior on color {
          ColorAnimation { duration: 100 }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton
          onClicked: launcherRoot.currentIndex = index
          onDoubleClicked: {
            modelData.execute()
            launcherRoot.close()
          }
          onWheel: (wheel) => {
            if (wheel.angleDelta.x < 0 || wheel.angleDelta.y < 0) {
              if (launcherRoot.currentIndex < launcherRoot.filteredEntries.length - 1)
                launcherRoot.currentIndex++
            } else {
              if (launcherRoot.currentIndex > 0)
                launcherRoot.currentIndex--
            }
          }
        }
      }
    }
  }
}
