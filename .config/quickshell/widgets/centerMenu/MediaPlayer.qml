import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.components.widget
import qs

Item {
  id: mediaPlayerRoot

  property MprisPlayer player: Mpris.players.values[0]
  property real position: 0

  onPlayerChanged: {
    mediaPlayerRoot.position = mediaPlayerRoot.player?.position
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Global.format.spacing_large
    spacing: Global.format.spacing_large

    RowLayout {
      id: tabLayout
      spacing: Global.format.spacing_medium
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      height: Global.format.big_icon_size + Global.format.radius_small
      visible: tabs.count ? true : false

      Tabbar {
        id: tabs
        model: Mpris.players
        delegate: Tab {
          iconSource: {
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

          onClicked: mediaPlayerRoot.player = modelData
        } 
      }
    }

    Rectangle {
      id: controllerRoot
      Layout.fillHeight: true
      Layout.fillWidth: true
      radius: Global.format.radius_large
      color: Global.colors.surface_variant

      RowLayout {
        anchors.fill: parent
        anchors.margins: Global.format.spacing_large
        spacing: Global.format.spacing_medium

        // Album Art
        Rectangle {
          Layout.preferredWidth: parent.height * 0.8
          Layout.preferredHeight: parent.height * 0.8
          Layout.alignment: Qt.AlignVCenter
          radius: Global.format.radius_medium
          color: Global.colors.surface
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
          spacing: Global.format.spacing_small

          // Track Info
          ColumnLayout {
            Layout.fillWidth: true
            spacing: Global.format.spacing_tiny

            Text {
              id: trackTitle
              Layout.fillWidth: true
              text: mediaPlayerRoot.player?.trackTitle ?? "No track"
              color: Global.colors.on_surface_variant
              font.pixelSize: Global.format.text_size
              font.bold: true
              elide: Text.ElideRight
              maximumLineCount: 1
            }

            Text {
              id: trackArtist
              Layout.fillWidth: true
              text: mediaPlayerRoot.player?.trackArtists ?? "Unknown artist"
              color: Global.colors.outline
              font.pixelSize: Global.format.text_size
              elide: Text.ElideRight
              maximumLineCount: 1
            }

            Text {
              id: trackAlbum
              Layout.fillWidth: true
              text: mediaPlayerRoot.player?.trackAlbum ?? ""
              color: Global.colors.surface_bright
              font.pixelSize: Global.format.text_size
              elide: Text.ElideRight
              maximumLineCount: 1
              visible: text !== ""
            }
          }

          // Progress Bar
          ColumnLayout {
            Layout.fillWidth: true
            spacing: Global.format.spacing_tiny
            visible: mediaPlayerRoot.player?.length > 0

            Rectangle {
              Layout.fillWidth: true
              height: 4
              radius: 2
              color: Global.colors.surface

              Rectangle {
                width: parent.width * (mediaPlayerRoot.position ?? 0) / (mediaPlayerRoot.player?.length ?? 1)
                height: parent.height
                radius: parent.radius
                color: Global.colors.primary
                
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
                color: Global.colors.on_surface_variant
                font.pixelSize: Global.format.font_size_small
              }

              Item { Layout.fillWidth: true }

              Text {
                text: formatTime(mediaPlayerRoot.player?.length ?? 0)
                color: Global.colors.on_surface_variant
                font.pixelSize: Global.format.font_size_small
              }
            }
          }

          // Control Buttons
          RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Global.format.spacing_medium

            IconButton {
              width: Global.format.icon_size
              height: Global.format.icon_size
              icon: mediaPlayerRoot.player?.shuffle ? Quickshell.iconPath("media-playlist-shuffle") : Quickshell.iconPath("media-playlist-no-shuffle")
              enabled: mediaPlayerRoot.player?.shuffleSupported
              onClicked: {
                mediaPlayerRoot.player.shuffle = !mediaPlayerRoot.player.shuffle
              }
            }

            IconButton {
              width: Global.format.icon_size
              height: Global.format.icon_size
              icon: Quickshell.iconPath("media-skip-backward")
              enabled: mediaPlayerRoot.player?.canGoPrevious ?? false
              onClicked: mediaPlayerRoot.player?.previous()
            }

            IconButton {
              width: Global.format.big_icon_size
              height: Global.format.big_icon_size
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
              width: Global.format.icon_size
              height: Global.format.icon_size
              icon: Quickshell.iconPath("media-skip-forward")
              enabled: mediaPlayerRoot.player?.canGoNext ?? false
              onClicked: mediaPlayerRoot.player?.next()
            }

            IconButton {
              width: Global.format.icon_size
              height: Global.format.icon_size
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
    interval: 1000

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
    return (hours > 0 ? hours + ":" : "") + minutes + ":" + (seconds < 10 ? "0" : "") + Math.floor(seconds);
  }
}

