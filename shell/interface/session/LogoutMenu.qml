import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs
import qs.components.widget
import qs.components.text

PanelWindow {
  id: root

  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  WlrLayershell.layer: WlrLayer.Overlay
  exclusiveZone: 0
  aboveWindows: true
  color: "transparent"
  visible: false

  function isFocusedScreen(): bool {
    return Wm.isFocused(screen.name);
  }

  function open() {
    if (!root.isFocusedScreen())
      return;
    visible = true;
    card.forceActiveFocus();
    root.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
  }

  function close() {
    root.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
    visible = false;
  }

  function trigger(command: var) {
    root.close();
    Quickshell.execDetached(command);
  }

  readonly property var actions: [
    {
      icon: "󰌾",
      text: "Lock",
      execute: function () {
        root.close();
        Global.openLockScreen();
      }
    },
    {
      icon: "󰍃",
      text: "Logout",
      execute: function () {
        root.trigger(["loginctl", "terminate-session", Quickshell.env("XDG_SESSION_ID")]);
      }
    },
    {
      icon: "󰒲",
      text: "Suspend",
      execute: function () {
        root.trigger(["systemctl", "suspend"]);
      }
    },
    {
      icon: "󰋊",
      text: "Hibernate",
      execute: function () {
        root.trigger(["systemctl", "hibernate"]);
      }
    },
    {
      icon: "󰜉",
      text: "Reboot",
      execute: function () {
        root.trigger(["systemctl", "reboot"]);
      }
    },
    {
      icon: "󰐥",
      text: "Shutdown",
      execute: function () {
        root.trigger(["systemctl", "poweroff"]);
      }
    }
  ]

  Rectangle {
    id: scrim
    anchors.fill: parent
    color: Global.colors.scrim
    opacity: 0.6

    MouseArea {
      anchors.fill: parent
      onClicked: root.close()
    }
  }

  Rectangle {
    id: card
    anchors.centerIn: parent
    color: Global.colors.surface_container
    implicitWidth: cardCol.implicitWidth + Global.format.spacing_large * 2
    implicitHeight: cardCol.implicitHeight + Global.format.spacing_large * 2
    focus: true

    Keys.onEscapePressed: root.close()

    ColumnLayout {
      id: cardCol
      anchors.fill: parent
      anchors.margins: Global.format.spacing_large
      spacing: Global.format.spacing_medium

      StyledText {
        text: "Session"
        font.bold: true
        color: Global.colors.primary
        Layout.alignment: Qt.AlignHCenter
      }

      RowLayout {
        spacing: Global.format.spacing_large
        Layout.alignment: Qt.AlignHCenter

        Repeater {
          model: root.actions

          delegate: ActionButton {
            required property var modelData
            icon: modelData.icon
            text: modelData.text

            onClicked: mouse => modelData.execute()
          }
        }
      }
    }
  }

  Connections {
    target: Global

    function onOpenLogoutMenu() {
      root.open();
    }
  }
}
