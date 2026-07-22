import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs

Item {
  id: clipboardRoot

  property string searchText: ""
  property int currentIndex: 0
  property var clipboardEntries: []

  readonly property var filteredEntries: {
    if (searchText.trim() === "") return clipboardEntries
    const search = searchText.toLowerCase()
    return clipboardEntries.filter(entry => {
      const content = entry.replace(/^\d+\t/, "").toLowerCase()
      return content.includes(search)
    })
  }

  signal closed

  function open() {
    searchText = ""
    currentIndex = 0
    searchInput.text = ""
    refresh()
    searchInput.forceActiveFocus()
  }

  function close() {
    searchInput.text = ""
    closed()
  }

  function refresh() {
    readProc.running = true
  }

  function selectEntry(entry) {
    Quickshell.execDetached(["bash", "-c", "echo \"" + entry + "\" | cliphist decode | wl-copy"])
  }

  function deleteEntry(entry) {
    deleteProc.entry = entry
    deleteProc.running = true
  }

  function wipeAll() {
    wipeProc.running = true
  }

  function isImageEntry(entry) {
    return /^\d+\t\[\[.*binary data.*\d+x\d+.*\]\]$/.test(entry)
  }

  Process {
    id: readProc
    property var buffer: []
    command: ["cliphist", "list"]
    stdout: SplitParser {
      onRead: (line) => readProc.buffer.push(line)
    }
    onExited: (exitCode, _) => {
      if (exitCode === 0) {
        clipboardRoot.clipboardEntries = readProc.buffer
        readProc.buffer = []
      }
    }
  }

  Process {
    id: deleteProc
    property string entry: ""
    command: ["bash", "-c", "echo \"" + entry + "\" | cliphist delete"]
    onExited: (_, __) => clipboardRoot.refresh()
  }

  Process {
    id: wipeProc
    command: ["cliphist", "wipe"]
    onExited: (_, __) => clipboardRoot.refresh()
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
        verticalAlignment: Text.AlignVCenter

        onTextChanged: {
          clipboardRoot.searchText = text
          clipboardRoot.currentIndex = 0
        }

        Keys.onLeftPressed: {
          if (clipboardRoot.currentIndex > 0)
            clipboardRoot.currentIndex--
        }
        Keys.onRightPressed: {
          if (clipboardRoot.currentIndex < clipboardRoot.filteredEntries.length - 1)
            clipboardRoot.currentIndex++
        }
        Keys.onReturnPressed: {
          if (clipboardRoot.filteredEntries.length > 0) {
            clipboardRoot.selectEntry(clipboardRoot.filteredEntries[clipboardRoot.currentIndex])
            clipboardRoot.close()
          }
        }
        Keys.onEscapePressed: clipboardRoot.close()
        Keys.onDeletePressed: {
          if (clipboardRoot.filteredEntries.length > 0)
            clipboardRoot.deleteEntry(clipboardRoot.filteredEntries[clipboardRoot.currentIndex])
        }
        Keys.onPressed: (event) => {
          if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_D) {
            if (clipboardRoot.filteredEntries.length > 0)
              clipboardRoot.deleteEntry(clipboardRoot.filteredEntries[clipboardRoot.currentIndex])
            event.accepted = true
          }
        }
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
      visible: clipboardRoot.filteredEntries.length === 0
      text: clipboardRoot.searchText ? "No matching entries" : "Clipboard is empty"
      color: Global.colors.outline
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      Layout.fillWidth: true
      Layout.fillHeight: true
      verticalAlignment: Text.AlignVCenter
    }

    ListView {
      id: clipList
      visible: clipboardRoot.filteredEntries.length > 0
      Layout.fillWidth: true
      Layout.fillHeight: true
      orientation: ListView.Horizontal
      spacing: Global.format.spacing_large
      clip: true
      currentIndex: clipboardRoot.currentIndex
      highlightMoveDuration: 0

      model: clipboardRoot.filteredEntries

      delegate: Row {
        required property string modelData
        required property int index
        spacing: Global.format.spacing_small
        height: clipList.height

        property string displayText: modelData.replace(/^\d+\t/, "")
        property string truncated: displayText.length > 40 ? displayText.substring(0, 40) + "…" : displayText

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: index === clipboardRoot.currentIndex
            ? "[" + parent.truncated + "]"
            : " " + parent.truncated + " "
          color: index === clipboardRoot.currentIndex ? Global.colors.primary : Global.colors.on_surface_variant
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: Global.format.text_size
          verticalAlignment: Text.AlignVCenter

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton
            onClicked: clipboardRoot.currentIndex = index
            onDoubleClicked: {
              clipboardRoot.selectEntry(modelData)
              clipboardRoot.close()
            }
            onWheel: (wheel) => {
              if (wheel.angleDelta.x < 0 || wheel.angleDelta.y < 0) {
                if (clipboardRoot.currentIndex < clipboardRoot.filteredEntries.length - 1)
                  clipboardRoot.currentIndex++
              } else {
                if (clipboardRoot.currentIndex > 0)
                  clipboardRoot.currentIndex--
              }
            }
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "󰩺"
          color: delMouse.containsMouse ? Global.colors.error : Global.colors.outline
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: Global.format.font_size_small
          verticalAlignment: Text.AlignVCenter

          MouseArea {
            id: delMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: clipboardRoot.deleteEntry(modelData)
          }
        }
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
      id: wipeBtn
      Layout.fillHeight: true
      Layout.preferredWidth: implicitWidth + Global.format.spacing_medium * 2
      text: "  󰩺 Clear  "
      color: wipeMouse.containsMouse ? Global.colors.error : Global.colors.on_surface_variant
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Global.format.text_size
      verticalAlignment: Text.AlignVCenter

      MouseArea {
        id: wipeMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: clipboardRoot.wipeAll()
      }
    }
  }
}
