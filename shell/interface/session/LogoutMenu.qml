import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs
import qs.components.widget
import qs.components.text

PanelWindow {
  id: root

  readonly property var actions: [
    {
      icon: "󰌾",
      text: "Lock",
      execute: function () {
        root.closeAll();
        Global.openLockScreen();
      }
    },
    {
      icon: "󰍃",
      text: "Logout",
      execute: function () {
        root.closeAll();
        Quickshell.execDetached(["loginctl", "terminate-session", Quickshell.env("XDG_SESSION_ID")]);
      }
    },
    {
      icon: "󰒲",
      text: "Suspend",
      execute: function () {
        Global.openLockScreen();
        root.closeAll();
        Quickshell.execDetached(["systemctl", "suspend"]);
      }
    },
    {
      icon: "󰋊",
      text: "Hibernate",
      execute: function () {
        Global.openLockScreen();
        root.closeAll();
        Quickshell.execDetached(["systemctl", "hibernate"]);
      }
    },
    {
      icon: "󰜉",
      text: "Reboot",
      execute: function () {
        root.closeAll();
        Quickshell.execDetached(["systemctl", "reboot"]);
      }
    },
    {
      icon: "󰐥",
      text: "Shutdown",
      execute: function () {
        root.closeAll();
        Quickshell.execDetached(["systemctl", "poweroff"]);
      }
    }
  ]
  property int currentIndex: 0

  function close() {
    root.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
    visible = false;
  }
  function closeAll() {
    Global.closeLogoutMenu();
  }
  function isPrimaryScreen(): bool {
    return Wm.isPrimaryScreen(screen.name);
  }
  function open() {
    visible = true;
    currentIndex = 0;
    if (root.isPrimaryScreen()) {
      card.forceActiveFocus();
      root.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
    }
  }

  WlrLayershell.layer: WlrLayer.Overlay
  aboveWindows: true
  color: "transparent"
  exclusiveZone: 0
  visible: false

  anchors {
    bottom: true
    left: true
    right: true
    top: true
  }

  Rectangle {
    id: scrim

    anchors.fill: parent
    color: Global.colors.scrim
    opacity: 0.6

    MouseArea {
      anchors.fill: parent

      onClicked: root.closeAll()
    }
  }

  Rectangle {
    id: card

    anchors.centerIn: parent
    color: Global.colors.surface_container
    focus: true
    implicitHeight: cardCol.implicitHeight + Global.format.spacing_large * 2
    implicitWidth: cardCol.implicitWidth + Global.format.spacing_large * 2
    visible: root.isPrimaryScreen()

    Keys.onDownPressed: {
      if (root.currentIndex < root.actions.length - 1)
        root.currentIndex++;
    }
    Keys.onEscapePressed: root.closeAll()
    Keys.onLeftPressed: {
      if (root.currentIndex > 0)
        root.currentIndex--;
    }
    Keys.onReturnPressed: {
      root.actions[root.currentIndex].execute();
    }
    Keys.onRightPressed: {
      if (root.currentIndex < root.actions.length - 1)
        root.currentIndex++;
    }
    Keys.onSpacePressed: {
      root.actions[root.currentIndex].execute();
    }
    Keys.onUpPressed: {
      if (root.currentIndex > 0)
        root.currentIndex--;
    }

    ColumnLayout {
      id: cardCol

      anchors.fill: parent
      anchors.margins: Global.format.spacing_large
      spacing: Global.format.spacing_medium

      StyledText {
        Layout.alignment: Qt.AlignHCenter
        color: Global.colors.primary
        font.bold: true
        text: "Session"
      }

      RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Global.format.spacing_large

        Repeater {
          model: root.actions

          delegate: ActionButton {
            required property int index
            required property var modelData

            icon: modelData.icon
            selected: root.currentIndex === index
            text: modelData.text

            onClicked: mouse => {
              root.currentIndex = index;
              modelData.execute();
            }
          }
        }
      }
    }
  }

  Connections {
    function onCloseLogoutMenu() {
      root.close();
    }
    function onOpenLogoutMenu() {
      root.open();
    }

    target: Global
  }
}
