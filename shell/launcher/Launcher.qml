//@ pragma UseQApplication
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import qs.components.widget
import qs

pragma Singleton

MenuPanel {
  id: launcherRoot

  WlrLayershell.layer: WlrLayer.Overlay

  anchors {
    bottom: true
  }


  function close(): void {
    launcherRoot.visible = false
  }

  function open(): void {
    searchBox.clear()
    launcherRoot.visible = !launcherRoot.visible
    searchBox.focus = true
    launcherRoot.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
  }

  Process {
    id: mathProc
    property string expr: ""
    property string res: ""
    command: [Global.config.launcher.qalcPath, expr]

    stdout: StdioCollector {
      onStreamFinished: {
        var res = this.text.trim()
        const lines = this.text.trim().split("\n")

        if (lines.length === 0) {
          return
        }

        const lastLine = lines[lines.length - 1]

        mathProc.res = lastLine
        console.log(this.text.trim())
      }
    }
  }

  property bool isCustomCommand: searchBox.text.length > 0 && searchBox.text[0] === ">"
  property bool isExpr: searchBox.text.length > 0 && searchBox.text[0] === "="

  property var customCommands: [
    {
      name: "Clip",
      description: "Open clipboard manager",
      icon: "edit-paste",
      execute: function () {
        ClipboardManager.open()
      },
      active: Global.config.clipboard.enabled
    },
    {
      name: "Wallpapers",
      description: "Open wallpaper selector",
      icon: "preferences-desktop-wallpaper-symbolic",
      execute: function () {
        WallpaperSelector.open()
      },
      active: Global.config.wallpaper.enabled
    }
  ]

  Rectangle {
    anchors{
      top: parent.top
      left: parent.left
      right: parent.right
      bottom: searchBox.top

      topMargin: Global.format.spacing_large
      bottomMargin: Global.format.spacing_large
      rightMargin: Global.format.spacing_large
      leftMargin: Global.format.spacing_large
    }
    radius: Global.format.radius_large
    color: Global.colors.surface

    ListView {
      id: appList
      anchors.fill: parent
      anchors.margins: Global.format.spacing_small
      spacing: Global.format.spacing_tiny
      clip: true
      highlightFollowsCurrentItem: true
      focus: false

      populate: Transition {
        NumberAnimation {
          property: "opacity"
          from: 0
          to: 1
          duration:  100
        }
      }

      model: {
        let entries = []
        let allEntries = []

        if (launcherRoot.isCustomCommand) {
          allEntries = launcherRoot.customCommands.filter(entry =>
            !('active' in entry) || entry.active === true
          )
        } else if (launcherRoot.isExpr) {
          return [{
            name: "minimaMathProc",
            description: "Copy to Clipbord",
            icon: "mathmode",
            execute: function () {
              Quickshell.execDetached("wl-copy","\""+mathProc.res+"\"")
            }
          }]
        } else {
          allEntries = DesktopEntries.applications.values
        }

        if (searchBox.text === "") {
          return allEntries
        }

        const searchTerm = isCustomCommand
          ? searchBox.text.slice(1).trim().toLowerCase()
          : searchBox.text.trim().toLowerCase()

        for (const entry of allEntries) {
          if (entry.name.toLowerCase().includes(searchTerm)) {
            entries.push(entry)
          }
        }

        return entries
      }

      delegate: Rectangle {
        id: appItem
        required property var modelData
        required property int index
        property bool selected: modelData == appList.currentItem
        focus: false
        width: appList.width - scrollBar.width
        height: 40
        radius: Global.format.radius_medium
        color: mouseArea.containsMouse || (appList.currentItem && appList.currentItem.modelData == modelData) ? Global.colors.surface_container_high : "transparent"

        Behavior on color {
          ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
          }
        }

        RowLayout {
          anchors.fill: parent
          anchors.margins: Global.format.spacing_small
          spacing: Global.format.spacing_medium

          IconImage {
            Layout.preferredWidth: Global.format.icon_size
            Layout.preferredHeight: Global.format.icon_size
            Layout.alignment: Qt.AlignVCenter
            source: appItem.modelData.icon ? Quickshell.iconPath(appItem.modelData.icon) : ""
          }

          ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
              Layout.fillWidth: true
              text: appItem.modelData.name === "minimaMathProc" ? mathProc.res : appItem.modelData.name
              color: Global.colors.on_surface_variant
              font.pixelSize: Global.format.text_size
              font.bold: true
              elide: Text.ElideRight
            }

            Text {
              Layout.fillWidth: true
              text: appItem.modelData.description || ""
              color: Global.colors.outline
              font.pixelSize: Global.format.font_size_small
              elide: Text.ElideRight
              visible: text !== ""
            }
          }
        }

        MouseArea {
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          propagateComposedEvents: true

          onClicked: (mouse) => {
            appList.currentIndex = appItem.index
          }

          onDoubleClicked: {
            if (appItem.modelData) {
              appItem.modelData?.execute()
              close()
            }
          }
        }
      }

      ScrollBar.vertical: ScrollBar {
        id: scrollBar
        policy: ScrollBar.AsNeeded
      }
    }
  }

  TextField {
    id: searchBox

    anchors{
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      bottomMargin: Global.format.spacing_medium
      topMargin: Global.format.spacing_large
      leftMargin: Global.format.spacing_large
      rightMargin: Global.format.spacing_large
    }

    implicitHeight: 39
    color: "white"
    font.pixelSize: Global.format.text_size
    placeholderText: "type > for command or = for calculator"

    onFocusChanged: {
      if (launcherRoot.visible) {
        focus = true
      }
    }

    onTextEdited: {
      if (launcherRoot.isExpr) {
        mathProc.expr = searchBox.text.slice(1)
        if (mathProc.expr.length === 0) {
          mathProc.expr = "0"
        }
        mathProc.running = true
      }
    }

    onAccepted: {
      if (appList.currentItem?.modelData) {
        appList.currentItem.modelData.execute()
      }
      close()
    }

    Keys.onPressed: (event) => {
      if (event.key === Qt.Key_Up) {
        appList.currentIndex -= 1
        event.accepted = true
      } else if (event.key === Qt.Key_Down) {
        appList.currentIndex += 1
        event.accepted = true
      } else if (event.key === Qt.Key_Escape) {
        close()
        event.accepted = true
      }
      if (appList.currentIndex < 0) appList.currentIndex = 0
      if (appList.currentIndex >= appList.count) appList.currentIndex = appList.count -1
    }

    background: Rectangle {
      anchors.fill: parent
      color: Global.colors.surface
      radius: Global.format.radius_large
    }
  }
}
