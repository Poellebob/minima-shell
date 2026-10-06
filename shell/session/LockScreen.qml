import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs
import qs.components.text

Item {
  id: root

  property bool locked: false

  function lock() {
    root.locked = true;
  }

  function unlock() {
    root.locked = false;
  }

  function tryUnlock(response: string): void {
  if (!pam.responseRequired)
  return;
  pam.respond(response);
}

  onLockedChanged: {
    if (locked) {
      pam.start();
    } else if (pam.active) {
      pam.abort();
    }
  }

  PamContext {
    id: pam
    config: "login"

    onCompleted: result => {
      if (result === PamResult.Success) {
        root.unlock();
      } else if (lockSurface.isPrimaryScreen) {
        passwordInput.forceActiveFocus();
      }
    }
  }

  WlSessionLock {
    id: sessionLock
    locked: root.locked

    WlSessionLockSurface {
      id: lockSurface
      color: Global.colors.background

      readonly property bool isPrimaryScreen: Wm.isPrimaryScreen(
                                                  lockSurface.screen.name)

      SystemClock {
        id: clock
        precision: SystemClock.Seconds
      }

      ColumnLayout {
        anchors.centerIn: parent
        spacing: Global.format.spacing_large

        StyledText {
          text: Qt.formatDateTime(clock.date, "HH:mm")
          font.pixelSize: Global.format.font_size_xlarge
          color: Global.colors.on_background
          Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
          text: Qt.formatDateTime(clock.date, "dddd d MMMM")
          font.pixelSize: Global.format.font_size_large
          color: Global.colors.on_surface_variant
          Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
          visible: lockSurface.isPrimaryScreen
          color: "transparent"
          border.color: Global.colors.outline
          border.width: 1
          implicitWidth: promptCol.implicitWidth + Global.format.spacing_large
                         * 2
          implicitHeight: promptCol.implicitHeight
                          + Global.format.spacing_large * 2

          ColumnLayout {
            id: promptCol
            anchors.fill: parent
            anchors.margins: Global.format.spacing_large
            spacing: Global.format.spacing_medium

            StyledText {
              text: Quickshell.env("USER")
              font.bold: true
              color: Global.colors.primary
            }

            RowLayout {
              spacing: Global.format.spacing_medium

              StyledText {
                text: pam.message
                color: pam.messageIsError ? Global.colors.error :
                                            Global.colors.on_surface_variant
              }

              TextInput {
                id: passwordInput
                color: Global.colors.on_surface_variant
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Global.format.text_size
                echoMode: TextInput.Password
                passwordCharacter: "*"
                font.features: {
                  "calt": 0,
                  "liga": 0
                }
                clip: true
                focus: true
                verticalAlignment: Text.AlignVCenter
                Layout.preferredWidth: 220

                onAccepted: {
                  root.tryUnlock(passwordInput.text);
                  passwordInput.text = "";
                }

                Keys.onEscapePressed: passwordInput.text = ""

                Component.onCompleted: {
                  if (lockSurface.isPrimaryScreen)
                    passwordInput.forceActiveFocus();
                }
              }
            }
          }
        }
      }
    }
  }

  Connections {
    target: Global

    function onOpenLockScreen() {
      root.lock();
    }
  }
}
