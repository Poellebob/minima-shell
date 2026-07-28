import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs
import qs.components.text
import qs.components.widget

Item {
  id: root

  implicitHeight: Global.format.module_height
  implicitWidth: row.implicitWidth + Global.format.spacing_medium * 2

  property MprisPlayer player: null
  property int playerCount: 0

  signal showPlayerMenu()

  visible: player !== null

  function _syncPlayer() {
    var players = Mpris.players.values
    root.playerCount = players.length
    if (players.length === 0) {
      root.player = null
    } else if (root.player === null) {
      root.player = players[0]
    } else {
      var found = false
      for (var i = 0; i < players.length; i++) {
        if (players[i] === root.player) {
          found = true
          break
        }
      }
      if (!found) root.player = players[0]
    }
  }

  function formatTime(seconds) {
    var totalSecs = Math.max(0, Math.floor(seconds ?? 0))
    var mins = Math.floor(totalSecs / 60)
    var hrs = Math.floor(mins / 60)
    mins = mins % 60
    var secs = totalSecs % 60
    return (hrs > 0 ? hrs + ":" + (mins < 10 ? "0" : "") + mins + ":" : mins + ":") + (secs < 10 ? "0" : "") + secs
  }

  Timer {
    interval: 500
    running: true
    repeat: true
    onTriggered: root._syncPlayer()
  }

  Timer {
    interval: 1000
    running: player?.playbackState === MprisPlaybackState.Playing
    repeat: true

    onTriggered: {
      slider.value = player?.position ?? 0
      posText.text = formatTime(player?.position ?? 0)
    }
  }

  Component.onCompleted: root._syncPlayer()

  RowLayout {
    id: row

    anchors.fill: parent
    anchors.leftMargin: Global.format.spacing_medium
    anchors.rightMargin: Global.format.spacing_medium

    spacing: Global.format.spacing_medium

    MouseArea {
      visible: root.playerCount > 1
      implicitWidth: switchLabel.implicitWidth + Global.format.spacing_small
      implicitHeight: parent.height
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor

      StyledText {
        id: switchLabel
        anchors.centerIn: parent
        text: ""
      }

      onClicked: root.showPlayerMenu()
    }

    MouseArea {
      implicitWidth: shuffleLabel.implicitWidth + Global.format.spacing_small
      implicitHeight: parent.height
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      enabled: player?.shuffleSupported ?? false
      onClicked: {
        if (player)
          player.shuffle = !player.shuffle
      }

      StyledText {
        id: shuffleLabel
        anchors.centerIn: parent
        text: "󰒞"
        color: player?.shuffle
          ? Global.colors.primary
          : Global.colors.on_surface_variant
      }
    }

    MouseArea {
      implicitWidth: prevLabel.implicitWidth + Global.format.spacing_small
      implicitHeight: parent.height
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      enabled: player?.canGoPrevious ?? false
      onClicked: player?.previous()

      StyledText {
        id: prevLabel
        anchors.centerIn: parent
        text: "󰒮"
        color: player?.canGoPrevious
          ? Global.colors.on_surface_variant
          : Global.colors.outline
      }
    }

    MouseArea {
      implicitWidth: playLabel.implicitWidth + Global.format.spacing_small
      implicitHeight: parent.height
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      enabled: player?.canPause || player?.canPlay
      onClicked: player?.togglePlaying()

      StyledText {
        id: playLabel
        anchors.centerIn: parent
        text: player?.playbackState === MprisPlaybackState.Playing
          ? "󰏤"
          : "󰐊"
        color: (player?.canPause || player?.canPlay)
          ? Global.colors.on_surface_variant
          : Global.colors.outline
      }
    }

    MouseArea {
      implicitWidth: nextLabel.implicitWidth + Global.format.spacing_small
      implicitHeight: parent.height
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      enabled: player?.canGoNext ?? false
      onClicked: player?.next()

      StyledText {
        id: nextLabel
        anchors.centerIn: parent
        text: "󰒭"
        color: player?.canGoNext
          ? Global.colors.on_surface_variant
          : Global.colors.outline
      }
    }

    MouseArea {
      implicitWidth: loopLabel.implicitWidth + Global.format.spacing_small
      implicitHeight: parent.height
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      enabled: player?.loopSupported ?? false

      onClicked: {
        if (!player)
          return

        if (player.loopState === MprisLoopState.Playlist)
          player.loopState = MprisLoopState.Track
        else if (player.loopState === MprisLoopState.Track)
          player.loopState = MprisLoopState.None
        else
          player.loopState = MprisLoopState.Playlist
      }

      StyledText {
        id: loopLabel
        anchors.centerIn: parent
        text: player?.loopState === MprisLoopState.Playlist
          ? "󰑖"
          : player?.loopState === MprisLoopState.Track
            ? "󰑘"
            : "󰑗"

        color: player?.loopState !== MprisLoopState.None
          ? Global.colors.primary
          : Global.colors.on_surface_variant
      }
    }

    StyledText {
      text: player?.trackTitle ?? ""
      Layout.maximumWidth: 220
      elide: Text.ElideRight
      clip: true
    }

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      RowLayout {
        anchors.fill: parent
        spacing: Global.format.spacing_small

        StyledText {
          id: posText
          text: formatTime(player?.position ?? 0)
          font.pixelSize: Global.format.text_size
        }

        StyledSlider {
          id: slider
          from: 0
          to: player?.length ?? 1
          enabled: player?.canSeek ?? false
          visible: root.width > 520

          Layout.fillWidth: true
          Layout.preferredWidth: 0

          onDoneMoving: (value) => {
            if (player?.canSeek && player?.positionSupported)
              player.position = value
          }
        }

        StyledText {
          text: "-"
          font.pixelSize: Global.format.text_size
          visible: root.width <= 520
        }

        StyledText {
          text: formatTime(player?.length ?? 0)
          font.pixelSize: Global.format.text_size
        }

        Item {
          Layout.fillWidth: true
          visible: root.width <= 520
        }
      }
    }
  }
}
