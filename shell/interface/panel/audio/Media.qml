import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs
import qs.components.text
import qs.components.widget

Item {
  id: root

  property MprisPlayer player: null

  signal closed

  function open() {
    _syncPlayer();
  }

  function close() {
    closed();
  }

  function _syncPlayer() {
    var players = Mpris.players.values;
    if (players.length === 0) {
      root.player = null;
    } else if (root.player === null) {
      root.player = players[0];
    } else {
      var found = false;
      for (var i = 0; i < players.length; i++) {
        if (players[i] === root.player) {
          found = true;
          break;
        }
      }
      if (!found)
        root.player = players[0];
    }
  }

  function formatTime(seconds) {
    var totalSecs = Math.max(0, Math.floor(seconds ?? 0));
    var mins = Math.floor(totalSecs / 60);
    var hrs = Math.floor(mins / 60);
    mins = mins % 60;
    var secs = totalSecs % 60;
    return (hrs > 0 ? hrs + ":" + (mins < 10 ? "0" : "") + mins + ":" : mins
                      + ":") + (secs < 10 ? "0" : "") + secs;
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
      slider.value = player?.position ?? 0;
      posText.text = formatTime(player?.position ?? 0);
    }
  }

  Component.onCompleted: root._syncPlayer()

  StyledText {
    anchors.centerIn: parent
    text: "No media playing"
    color: Global.colors.outline
    visible: root.player === null
  }

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.leftMargin: Global.format.spacing_medium
    anchors.rightMargin: Global.format.spacing_medium
    spacing: Global.format.spacing_medium
    visible: root.player !== null

    ClickableText {
      text: player?.shuffle ? "󰒟" : "󰒞"
      mouseEnabled: player?.shuffleSupported ?? false
      Layout.preferredWidth: contentWidth + Global.format.spacing_small
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      Layout.fillHeight: true

      onClicked: {
        if (player)
          player.shuffle = !player.shuffle;
      }
    }

    ClickableText {
      text: "󰒮"
      baseColor: player?.canGoPrevious ? Global.colors.on_surface_variant :
                                         Global.colors.outline

      mouseEnabled: player?.canGoPrevious ?? false
      Layout.preferredWidth: contentWidth + Global.format.spacing_small
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      Layout.fillHeight: true

      onClicked: player?.previous()
    }

    ClickableText {
      text: player?.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
      baseColor: (player?.canPause || player?.canPlay)
                 ? Global.colors.on_surface_variant : Global.colors.outline

      mouseEnabled: (player?.canPause || player?.canPlay) ?? false
      Layout.preferredWidth: contentWidth + Global.format.spacing_small
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      Layout.fillHeight: true

      onClicked: player?.togglePlaying()
    }

    ClickableText {
      text: "󰒭"
      baseColor: player?.canGoNext ? Global.colors.on_surface_variant :
                                     Global.colors.outline

      mouseEnabled: player?.canGoNext ?? false
      Layout.preferredWidth: contentWidth + Global.format.spacing_small
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      Layout.fillHeight: true

      onClicked: player?.next()
    }

    ClickableText {
      text: player?.loopState === MprisLoopState.Playlist ? "󰑖" : player
                                                            ?.loopState
                                                            === MprisLoopState.Track
                                                            ? "󰑘" : "󰑗"
      baseColor: player?.loopState !== MprisLoopState.None
                 ? Global.colors.primary : Global.colors.on_surface_variant

      mouseEnabled: player?.loopSupported ?? false
      Layout.preferredWidth: contentWidth + Global.format.spacing_small
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      Layout.fillHeight: true

      onClicked: {
        if (!player)
          return;
        if (player.loopState === MprisLoopState.Playlist)
          player.loopState = MprisLoopState.Track;
        else if (player.loopState === MprisLoopState.Track)
          player.loopState = MprisLoopState.None;
        else
          player.loopState = MprisLoopState.Playlist;
      }
    }

    StyledText {
      text: player?.trackTitle ?? ""
      Layout.maximumWidth: 200
      elide: Text.ElideRight
      clip: true
    }

    Item {
      id: time
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
          visible: time.width > 300

          Layout.fillWidth: true
          Layout.preferredWidth: 0

          onDoneMoving: value => {
                          if (player?.canSeek && player?.positionSupported)
                          player.position = value;
                        }
        }

        StyledText {
          text: "-"
          font.pixelSize: Global.format.text_size
          visible: time.width <= 300
        }

        StyledText {
          text: formatTime(player?.length ?? 0)
          font.pixelSize: Global.format.text_size
        }

        Item {
          Layout.fillWidth: true
          visible: time.width <= 300
        }
      }
    }
  }
}
