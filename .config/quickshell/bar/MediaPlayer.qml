import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.components

Item {
  id: mediaPlayerRoot
  property MprisPlayer player: Mpris.players.values[0]
  property real position: 0

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: panel.format.spacing_large
    spacing: panel.format.spacing_large

    RowLayout {
      id: tabLayout
      spacing: panel.format.spacing_medium
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top

      Repeater {
        model: Mpris.players
        Rectangle {
          id: tabRoot
          required property MprisPlayer modelData
          visible: modelData.trackArtUrl ? true : false
          implicitHeight: icon.height + panel.format.radius_small
          Layout.fillWidth: true
          radius: panel.format.radius_large
          color: mediaPlayerRoot.player === modelData ? panel.colors.dark_surface : (mouseArea.containsMouse ? panel.colors.dark_surface : panel.colors.dark_surface_variant)

          IconImage {
            id: icon
            anchors.centerIn: parent
            width: panel.format.big_icon_size
            height: panel.format.big_icon_size
            source: {
              if (modelData.desktopEntry) {
                var desktopEntry = DesktopEntries.byId(modelData.desktopEntry);
                if (desktopEntry && desktopEntry.icon) {
                  console.log("Using desktop entry icon:", desktopEntry.icon);
                  return Quickshell.iconPath(desktopEntry.icon);
                }
              }
              if (modelData.identity) {
                var identityIcon = modelData.identity.toLowerCase();
                console.log("Trying identity as icon:", identityIcon);
                return Quickshell.iconPath(identityIcon, "audio-player");
              }
              console.log("Using fallback media icon");
              return Quickshell.iconPath("media-player") || Quickshell.iconPath("audio-player") || "no-icon";
            }
          }

          Behavior on color {
            ColorAnimation {
              duration: 150
              easing.type: Easing.OutCubic
            }
          }

          MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
              mediaPlayerRoot.player = modelData
              mouse.accepted = true
            }
          }
        }
      }
    }

    Rectangle {
      id: controllerRoot
      Layout.fillHeight: true
      Layout.fillWidth: true
      radius: panel.format.radius_large
      color: panel.colors.dark_surface_variant

      RowLayout {
        anchors.fill: parent
        anchors.margins: panel.format.spacing_large
        spacing: panel.format.spacing_medium

        // Album Art
        Rectangle {
          Layout.preferredWidth: parent.height * 0.8
          Layout.preferredHeight: parent.height * 0.8
          Layout.alignment: Qt.AlignVCenter
          radius: panel.format.radius_medium
          color: panel.colors.dark_surface
          clip: true

          Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: mediaPlayerRoot.player?.trackArtUrl ?? ""
            
            // Fallback icon when no art is available
            IconImage {
              anchors.centerIn: parent
              width: parent.width * 0.5
              height: parent.height * 0.5
              source: Quickshell.iconPath("media-album-cover") || Quickshell.iconPath("audio-x-generic")
              visible: parent.source === ""
              opacity: 0.3
            }
          }
        }

        // Track Info and Controls
        ColumnLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: panel.format.spacing_small

          // Track Info
          ColumnLayout {
            Layout.fillWidth: true
            spacing: panel.format.spacing_tiny

            Text {
              id: trackTitle
              Layout.fillWidth: true
              text: mediaPlayerRoot.player?.trackTitle ?? "No track"
              color: panel.colors.dark_on_surface_variant
              font.pixelSize: panel.format.text_size
              font.bold: true
              elide: Text.ElideRight
              maximumLineCount: 1
            }

            Text {
              id: trackArtist
              Layout.fillWidth: true
              text: mediaPlayerRoot.player?.trackArtists ?? "Unknown artist"
              color: panel.colors.dark_outline
              font.pixelSize: panel.format.text_size
              elide: Text.ElideRight
              maximumLineCount: 1
            }

            Text {
              id: trackAlbum
              Layout.fillWidth: true
              text: mediaPlayerRoot.player?.trackAlbum ?? ""
              color: panel.colors.dark_surface_bright
              font.pixelSize: panel.format.text_size
              elide: Text.ElideRight
              maximumLineCount: 1
              visible: text !== ""
            }
          }

          // Progress Bar
          ColumnLayout {
            Layout.fillWidth: true
            spacing: panel.format.spacing_tiny
            visible: mediaPlayerRoot.player?.length > 0

            Rectangle {
              Layout.fillWidth: true
              height: 4
              radius: 2
              color: panel.colors.dark_surface

              Rectangle {
                width: parent.width * (mediaPlayerRoot.position ?? 0) / (mediaPlayerRoot.player?.length ?? 1)
                height: parent.height
                radius: parent.radius
                color: panel.colors.accent_primary
                
                Behavior on width {
                  NumberAnimation {
                    duration: 1000
                    easing.type: Easing.OutCubic
                  }
                }
              }
            }

            RowLayout {
              Layout.fillWidth: true

              Text {
                text: formatTime(mediaPlayerRoot.position ?? 0)
                color: panel.colors.text_tertiary
                font.pixelSize: panel.format.text_tiny
              }

              Item { Layout.fillWidth: true }

              Text {
                text: formatTime(mediaPlayerRoot.player?.length ?? 0)
                color: panel.colors.text_tertiary
                font.pixelSize: panel.format.text_tiny
              }
            }
          }

          // Control Buttons
          RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: panel.format.spacing_medium

            IconButton {
              width: panel.format.icon_size
              height: panel.format.icon_size
              icon: mediaPlayerRoot.player?.shuffle ? Quickshell.iconPath("media-playlist-shuffle") : Quickshell.iconPath("media-playlist-no-shuffle")
              enabled: mediaPlayerRoot.player?.shuffleSupported
              onClicked: {
                mediaPlayerRoot.player.shuffle = !mediaPlayerRoot.player.shuffle
              }
            }

            IconButton {
              width: panel.format.icon_size
              height: panel.format.icon_size
              icon: Quickshell.iconPath("media-skip-backward")
              enabled: mediaPlayerRoot.player?.canGoPrevious ?? false
              onClicked: mediaPlayerRoot.player?.previous()
            }

            IconButton {
              width: panel.format.big_icon_size
              height: panel.format.big_icon_size
              icon: {
                if (mediaPlayerRoot.player?.playbackState === MprisPlaybackState.Playing) {
                  return Quickshell.iconPath("media-playback-pause")
                } else {
                  return Quickshell.iconPath("media-playback-start")
                }
              }
              enabled: mediaPlayerRoot.player?.canPause || mediaPlayerRoot.player?.canPlay
              onClicked: mediaPlayerRoot.player?.togglePlaying() 
            }

            IconButton {
              width: panel.format.icon_size
              height: panel.format.icon_size
              icon: Quickshell.iconPath("media-skip-forward")
              enabled: mediaPlayerRoot.player?.canGoNext ?? false
              onClicked: mediaPlayerRoot.player?.next()
            }

            IconButton {
              width: panel.format.icon_size
              height: panel.format.icon_size
              icon: {
                if(mediaPlayerRoot.player?.loopState === MprisLoopState.Playlist) {
                  return Quickshell.iconPath("media-playlist-repeat")
                }
                else if (mediaPlayerRoot.player?.loopState === MprisLoopState.Track) {
                  return Quickshell.iconPath("media-repeat-single")
                }
                else if(mediaPlayerRoot.player?.loopState === MprisLoopState.None) {
                  return Quickshell.iconPath("media-repeat-none")
                }
              }
              enabled: mediaPlayerRoot.player?.loopSupported
              onClicked: {
                if(mediaPlayerRoot.player?.loopState === MprisLoopState.Playlist) {
                  mediaPlayerRoot.player.loopState = MprisLoopState.Track
                }
                else if (mediaPlayerRoot.player?.loopState === MprisLoopState.Track) {
                  mediaPlayerRoot.player.loopState = MprisLoopState.None
                }
                else if(mediaPlayerRoot.player?.loopState === MprisLoopState.None) {
                  mediaPlayerRoot.player.loopState = MprisLoopState.Playlist
                }
              }
            }
          }
        }
      }
    }
  }

  Timer {
    running: true
    repeat: true
    interval: 100

    onTriggered: {
      mediaPlayerRoot.position = mediaPlayerRoot.player?.position
    }
  }

  // Helper function to format time
  function formatTime(seconds) {
    var minutes = Math.floor(seconds / 60);
    var hours = Math.floor(minutes / 60);
    minutes = minutes % 60;
    seconds = seconds % 60;
    return (hours > 0 ?? hours + ":") + minutes + ":" + (seconds < 10 ? "0" : "") + Math.floor(seconds);
  }
}